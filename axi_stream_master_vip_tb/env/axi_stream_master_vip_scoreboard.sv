// =============================================================================
// AXI5-Stream Master VIP — Scoreboard
// Reference model is a per-stream queue keyed by {TID,TDEST}. A single global
// queue would hide cross-stream leakage, which is exactly the REQ_MST_08 /
// REQ_MST_11 failure mode we need to be able to see.
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_SCOREBOARD_SV
`define AXI_STREAM_MASTER_VIP_SCOREBOARD_SV

`uvm_analysis_imp_decl(_obs)

class axi_stream_master_vip_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_stream_master_vip_scoreboard)

  uvm_analysis_imp_obs #(axi_stream_master_vip_seq_item,
                         axi_stream_master_vip_scoreboard) obs_export;

  axi_stream_master_vip_env_config cfg;

  // Reference model: expected packets, keyed by {TID,TDEST}.
  protected axi_stream_master_vip_seq_item exp_q[string][$];

  protected int unsigned expected_packets;
  protected int unsigned observed_packets;
  protected int unsigned matched_packets;
  protected int unsigned mismatched_packets;

  // Set once an ARESETn pulse is seen. Reset abandons in-flight packets by
  // design (Section 2.8.2), so packet-level accounting across the reset
  // boundary is not well-defined and becomes ADVISORY. The protocol checkers
  // in the monitor stay live — they are what the reset tests actually assert.
  protected bit          reset_seen;
  protected int unsigned resets_observed;

  // PERF_THROUGHPUT (REQ_MST_04)
  protected int unsigned perf_beats;
  protected int unsigned perf_stall_cycles;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    obs_export = new("obs_export", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(uvm_config_db #(axi_stream_master_vip_env_config)::get(this, "", "cfg", cfg));
  endfunction

  protected function string key_of(logic [`AXI_ID_W-1:0] id, logic [`AXI_DEST_W-1:0] dest);
    return $sformatf("%0h_%0h", id, dest);
  endfunction

  // Called by the sequences (via the env) as each packet is emitted.
  function void expect_packet(axi_stream_master_vip_seq_item item);
    string k = key_of(item.id, item.dest);
    axi_stream_master_vip_seq_item cloned;
    if (!$cast(cloned, item.clone())) begin
      `uvm_error("SB/CLONE", "Failed to clone expected packet")
      return;
    end
    exp_q[k].push_back(cloned);
    expected_packets++;
  endfunction

  // Called by the monitor on each ARESETn assertion. Flushes the reference
  // model: packets the sequence registered but that reset discarded were never
  // going to arrive, and holding them would report phantom "stranded" packets.
  function void note_reset();
    resets_observed++;
    reset_seen = 1;
    exp_q.delete();
    expected_packets = 0;
    observed_packets = 0;
    `uvm_info("SB/RESET", $sformatf(
      "ARESETn pulse %0d observed — reference model flushed, packet accounting is now advisory",
      resets_observed), UVM_MEDIUM)
  endfunction

  // ── Observed packet from the monitor ──────────────────────────────────────
  function void write_obs(axi_stream_master_vip_seq_item item);
    string k = key_of(item.id, item.dest);
    axi_stream_master_vip_seq_item exp;

    observed_packets++;

    foreach (item.inter_beat_delay[i]) perf_stall_cycles += item.inter_beat_delay[i];
    perf_beats += item.packet_beats;

    if (!exp_q.exists(k) || exp_q[k].size() == 0) begin
      if (reset_seen)
        `uvm_info("SB/UNEXPECTED", $sformatf(
          "Packet on stream TID=0x%0h TDEST=0x%0h has no expectation — attributable to the reset flush; advisory only.",
          item.id, item.dest), UVM_MEDIUM)
      else
        `uvm_error("SB/UNEXPECTED", $sformatf(
          "Observed a packet on stream TID=0x%0h TDEST=0x%0h with no matching expected packet. Either a packet leaked between streams (REQ_MST_08) or a spurious packet was emitted.",
          item.id, item.dest))
      mismatched_packets++;
      return;
    end

    exp = exp_q[k].pop_front();

    // Comparison is TKEEP-masked: raw-bus comparison would raise false
    // mismatches on null-byte lanes of legal sparse traffic (REQ_MST_09).
    if (exp.compare_masked(item)) begin
      matched_packets++;
      `uvm_info("SB/MATCH", $sformatf(
        "Packet MATCH on stream 0x%0h/0x%0h — beats=%0d data_bytes=%0d",
        item.id, item.dest, item.packet_beats, item.data_byte_count()), UVM_MEDIUM)
    end else begin
      mismatched_packets++;
      `uvm_error("SB/MISMATCH", $sformatf(
        "Packet MISMATCH on stream 0x%0h/0x%0h\n  expected: %s\n  observed: %s",
        item.id, item.dest, exp.convert2string(), item.convert2string()))
    end
  endfunction

  function void check_phase(uvm_phase phase);
    int unsigned leftover;
    real bpc;
    super.check_phase(phase);

    // ── REQ_MST_07: packet-count preservation (Section 2.6, Page 26) ────────
    if (observed_packets != expected_packets) begin
      if (reset_seen)
        `uvm_info("SB/PKT_COUNT", $sformatf(
          "Packet count expected %0d / observed %0d — a reset discarded in-flight packets; advisory only.",
          expected_packets, observed_packets), UVM_MEDIUM)
      else
        `uvm_error("SB/PKT_COUNT", $sformatf(
          "Packet count not preserved: expected %0d, observed %0d. TLAST assertions must be preserved between Transmitter and Receiver (Section 2.6).",
          expected_packets, observed_packets))
    end

    // ── REQ_MST_08: no packet left stranded in a per-stream queue ───────────
    foreach (exp_q[k])
      if (exp_q[k].size() != 0) begin
        leftover += exp_q[k].size();
        if (reset_seen)
          `uvm_info("SB/STRANDED", $sformatf(
            "Stream %s has %0d unobserved packet(s) — attributable to the reset flush; advisory only.",
            k, exp_q[k].size()), UVM_MEDIUM)
        else
          `uvm_error("SB/STRANDED", $sformatf(
            "Stream %s has %0d expected packet(s) never observed — packets were emitted but lost, or landed in the wrong stream.",
            k, exp_q[k].size()))
      end

    // ── REQ_MST_04 / PERF_THROUGHPUT ───────────────────────────────────────
    if (cfg != null && cfg.check_throughput && perf_beats > 0) begin
      bpc = real'(perf_beats) / real'(perf_beats + perf_stall_cycles);
      if (bpc < 1.0)
        `uvm_error("SB/THROUGHPUT", $sformatf(
          "Zero-delay throughput target missed: achieved %.3f beats/cycle, target 1.0. A pipeline bubble between beats violates no pointwise rule but halves bandwidth (REQ_MST_04).",
          bpc))
      else
        `uvm_info("SB/THROUGHPUT", $sformatf("Throughput %.3f beats/cycle — target met", bpc),
                  UVM_LOW)
    end

    `uvm_info("SB/SUMMARY", $sformatf(
      "\n  expected packets : %0d\n  observed packets : %0d\n  matched          : %0d\n  mismatched       : %0d\n  stranded         : %0d",
      expected_packets, observed_packets, matched_packets, mismatched_packets, leftover),
      UVM_LOW)
  endfunction

endclass

`endif
