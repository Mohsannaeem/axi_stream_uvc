// =============================================================================
// AXI5-Stream Slave VIP — Scoreboard
// Tracks packets RECEIVED by the VIP, keyed per {TID,TDEST} stream. The DUT
// Master owns payload generation; exact payload comparison requires the DUT stub
// to publish a golden emitted-record (a documented hook — see check_phase note).
// This scoreboard verifies liveness, per-stream reception, and reset-aware
// accounting; the monitor's protocol checkers verify DUT correctness.
// =============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_SCOREBOARD_SV
`define AXI_STREAM_SLAVE_VIP_SCOREBOARD_SV

class axi_stream_slave_vip_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_stream_slave_vip_scoreboard)

  axi_stream_slave_vip_env_config cfg;

  protected int unsigned received_packets;
  protected int unsigned received_beats;
  protected int unsigned per_stream_pkts[string];
  protected bit          reset_seen;
  protected int unsigned resets_observed;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(uvm_config_db #(axi_stream_slave_vip_env_config)::get(this, "", "cfg", cfg));
  endfunction

  protected function string key_of(logic [`AXI_ID_W-1:0] id, logic [`AXI_DEST_W-1:0] dest);
    return $sformatf("%0h_%0h", id, dest);
  endfunction

  // Called by the monitor when a packet is fully received.
  function void note_received(logic [`AXI_ID_W-1:0] id, logic [`AXI_DEST_W-1:0] dest,
                              int unsigned beats);
    string k = key_of(id, dest);
    received_packets++;
    received_beats += beats;
    if (per_stream_pkts.exists(k)) per_stream_pkts[k]++; else per_stream_pkts[k] = 1;
    `uvm_info("SB/RX", $sformatf("Received packet on stream %s (beats=%0d)", k, beats), UVM_MEDIUM)
  endfunction

  // Called by the monitor on each ARESETn assertion.
  function void note_reset();
    resets_observed++;
    reset_seen = 1;
    `uvm_info("SB/RESET", $sformatf(
      "ARESETn pulse %0d — packet accounting is now advisory across the boundary", resets_observed),
      UVM_MEDIUM)
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    // Liveness: a non-reset-only run must have received at least one packet.
    if (received_packets == 0 && !reset_seen)
      `uvm_error("SB/LIVENESS",
                 "No packets received — DUT emitted nothing or the VIP never accepted a beat.")
    `uvm_info("SB/SUMMARY", $sformatf(
      "\n  received packets : %0d\n  received beats   : %0d\n  streams          : %0d\n  resets observed  : %0d",
      received_packets, received_beats, per_stream_pkts.size(), resets_observed), UVM_LOW)
    // NOTE: exact accepted-vs-emitted comparison (PERF_BACKPRESSURE_ACCURACY) requires
    // the DUT master stub to publish its emitted-beat count; wire that record here when
    // the stub is replaced by golden-model or real RTL.
  endfunction

endclass

`endif
