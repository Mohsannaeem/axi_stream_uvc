// =============================================================================
// AXI5-Stream Slave VIP — Monitor
// Observes the full interface, reconstructs received packets, runs the DUT
// (Master) compliance checkers, samples functional coverage, and drives a
// tracker. A beat is ACCEPTED when observed TVALID && TREADY on a rising edge.
// =============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_MONITOR_SV
`define AXI_STREAM_SLAVE_VIP_MONITOR_SV

typedef class axi_stream_slave_vip_scoreboard;

class axi_stream_slave_vip_monitor extends uvm_monitor;
  `uvm_component_utils(axi_stream_slave_vip_monitor)

  uvm_analysis_port #(axi_stream_slave_vip_seq_item) ap;
  axi_stream_slave_vip_agent_config cfg;

  protected virtual axi_stream_slave_vip_if #(
    .DATA_W(`AXI_DATA_W), .ID_W(`AXI_ID_W), .DEST_W(`AXI_DEST_W),
    .USER_W(`AXI_USER_W), .HAS_PAR(`AXI_HAS_PAR), .HAS_WAKE(`AXI_HAS_WAKE)
  ) vif;

  protected axi_stream_slave_vip_scoreboard sb_h;
  uvm_tracker trk;

  // ── Reconstruction + coverage state ───────────────────────────────────────
  protected int unsigned obs_packets, obs_beats, obs_txns;
  protected bit          in_reset_prev;
  protected int unsigned cov_stall, cov_pkt_len, cov_wake_lead;
  protected int unsigned cov_ready_mode;      // sampled from a config/observed hint
  protected int unsigned cov_reset_ctx;       // 0 idle,1 mid-packet,2 mid-handshake
  protected int unsigned cov_clk_gap;         // clock-off window (REQ_SLV_15)
  protected logic [`AXI_STRB_W-1:0] cov_keep, cov_strb;
  protected logic [`AXI_ID_W-1:0]   cov_id;
  protected logic [`AXI_DEST_W-1:0] cov_dest;
  protected bit          cov_parity_bad, cov_id_changed, cov_gap_zero;

  // ── Covergroups: one per plan coverage_group (10 total) ───────────────────
  covergroup cg_tready_profile;
    option.per_instance = 1;
    cp_mode  : coverpoint cov_ready_mode { bins b_m[] = {[0:4]}; }
    cp_stall : coverpoint cov_stall {
      bins b_zero={0}; bins b_one={1}; bins b_short={[2:15]};
      bins b_med={[16:99]}; bins b_long={[100:$]}; }
    x_mode_stall : cross cp_mode, cp_stall;
  endgroup
  covergroup cg_dut_tvalid_stability;
    option.per_instance = 1;
    cp_hold : coverpoint cov_stall { bins b_none={0}; bins b_brief={[1:15]}; bins b_long={[16:$]}; }
  endgroup
  covergroup cg_dut_payload_stability;
    option.per_instance = 1;
    cp_hold : coverpoint cov_stall { bins b_none={0}; bins b_brief={[1:5]}; bins b_long={[6:$]}; }
    cp_sparse : coverpoint cov_keep { bins b_ones={'1}; bins b_zero={'0}; bins b_sparse=default; }
    x_hold_sparse : cross cp_hold, cp_sparse;
  endgroup
  covergroup cg_reset;
    option.per_instance = 1;
    cp_ctx : coverpoint cov_reset_ctx { bins b_idle={0}; bins b_mid_pkt={1}; bins b_mid_hs={2}; }
  endgroup
  covergroup cg_packet_length;
    option.per_instance = 1;
    cp_len : coverpoint cov_pkt_len {
      bins b_one={1}; bins b_two={2}; bins b_small={[3:15]};
      bins b_med={[16:63]}; bins b_large={[64:255]}; bins b_max={`MAX_PACKET_BEATS}; }
  endgroup
  covergroup cg_stream_recon;
    option.per_instance = 1;
    cp_gap : coverpoint cov_gap_zero { bins b_zero_gap={1}; bins b_gap={0}; }
    cp_idc : coverpoint cov_id_changed { bins b_same={0}; bins b_changed={1}; }
    x_merge : cross cp_gap, cp_idc;
  endgroup
  covergroup cg_byte_qualifiers;
    option.per_instance = 1;
    cp_keep : coverpoint cov_keep { bins b_ones={'1}; bins b_zero={'0}; bins b_sparse=default; }
    cp_strb : coverpoint cov_strb { bins b_ones={'1}; bins b_zero={'0}; bins b_sparse=default; }
    x_qual : cross cp_keep, cp_strb;
  endgroup
  covergroup cg_wakeup;
    option.per_instance = 1;
    cp_lead : coverpoint cov_wake_lead { bins b_one={1}; bins b_two={2}; bins b_few={[3:7]}; bins b_many={[8:$]}; }
  endgroup
  covergroup cg_parity;
    option.per_instance = 1;
    cp_detect : coverpoint cov_parity_bad { bins b_ok={0}; bins b_fault={1}; }
    cp_dens   : coverpoint cov_keep { bins b_dense={'1}; bins b_null={'0}; bins b_sparse=default; }
    x_par : cross cp_detect, cp_dens;
  endgroup
  covergroup cg_recovery;
    option.per_instance = 1;
    cp_gap : coverpoint cov_clk_gap { bins b_none={0}; bins b_short={[1:99]}; bins b_long={[100:$]}; }
    cp_ctx : coverpoint cov_reset_ctx { bins b_idle={0}; bins b_mid_pkt={1}; bins b_mid_hs={2}; }
    x_recov : cross cp_gap, cp_ctx;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
    cg_tready_profile=new(); cg_dut_tvalid_stability=new(); cg_dut_payload_stability=new();
    cg_reset=new(); cg_packet_length=new(); cg_stream_recon=new(); cg_byte_qualifiers=new();
    cg_wakeup=new(); cg_parity=new(); cg_recovery=new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(axi_stream_slave_vip_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("MON/NOCFG", "agent_config not found in ConfigDB")
    vif = cfg.vif;
    trk = uvm_tracker::type_id::create("trk");
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    void'(uvm_config_db #(axi_stream_slave_vip_scoreboard)::get(null, "*", "sb", sb_h));
    if (cfg.enable_tracker) begin
      trk.add_column("TIME",  14, "%t");
      trk.add_column("KIND",   6, "%s");
      trk.add_column("PKT",    6, "%0d");
      trk.add_column("BEAT",   6, "%0d");
      trk.add_column("TDATA", `TRK_COLW(`AXI_DATA_W), "%0h");
      trk.add_column("KEEP",  `TRK_COLW(`AXI_STRB_W), "%0b");
      trk.add_column("STRB",  `TRK_COLW(`AXI_STRB_W), "%0b");
      trk.add_column("LAST",   5, "%0b");
      trk.add_column("TID",   `TRK_COLW(`AXI_ID_W),   "%0h");
      trk.add_column("STALL",  6, "%0d");
      trk.add_column("PAR",    5, "%s");
      trk.add_column("NOTE",  22, "%s");
      trk.open(get_full_name(), cfg.tracker_dir);
    end
  endfunction

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    if (cfg.enable_tracker) trk.close();
  endfunction

  protected function void trk_row(string kind, int unsigned pkt, int unsigned beat,
                                  int unsigned stall, string note);
    string vals[$];
    if (!cfg.enable_tracker) return;
    vals.push_back($sformatf("%0t", $time));
    vals.push_back(kind);
    vals.push_back($sformatf("%0d", pkt));
    vals.push_back($sformatf("%0d", beat));
    vals.push_back($sformatf("%0h", vif.cb_mon.TDATA));
    vals.push_back($sformatf("%0b", vif.cb_mon.TKEEP));
    vals.push_back($sformatf("%0b", vif.cb_mon.TSTRB));
    vals.push_back($sformatf("%0b", vif.cb_mon.TLAST));
    vals.push_back($sformatf("%0h", vif.cb_mon.TID));
    vals.push_back($sformatf("%0d", stall));
    vals.push_back(cov_parity_bad ? "BAD" : "OK");
    vals.push_back(note);
    trk.write_row(vals);
  endfunction

  protected function logic odd_parity_byte(logic [7:0] b); return ~(^b); endfunction

  task run_phase(uvm_phase phase);
    fork
      chk_reset_tvalid();
      chk_wakeup_lead();
      observe();
    join_none
  endtask

  // ── chk_reset_tvalid (REQ_SLV_06) ─────────────────────────────────────────
  protected task chk_reset_tvalid();
    forever begin
      @(vif.cb_mon);
      if (vif.cb_mon.ARESETn === 1'b0 && vif.cb_mon.TVALID === 1'b1)
        `uvm_error("CHK/RESET_TVALID",
                   "DUT drove TVALID HIGH while ARESETn LOW — Section 2.8.2")
    end
  endtask

  // ── chk_wakeup_lead / hold (REQ_SLV_12) ───────────────────────────────────
  protected task chk_wakeup_lead();
    bit prev_valid, prev_wake;
    if (!cfg.has_twakeup) return;
    forever begin
      @(vif.cb_mon);
      if (vif.cb_mon.TVALID === 1'b1 && prev_valid === 1'b0 && prev_wake !== 1'b1)
        `uvm_error("CHK/WAKE_LEAD",
                   "DUT asserted TVALID without a leading TWAKEUP — Section 2.3")
      if (prev_wake === 1'b1 && vif.cb_mon.TWAKEUP === 1'b0 &&
          vif.cb_mon.TVALID === 1'b1 && vif.cb_mon.TREADY !== 1'b1)
        `uvm_error("CHK/WAKE_HOLD",
                   "DUT dropped TWAKEUP while TVALID HIGH and TREADY not yet asserted — Section 2.3")
      if (vif.cb_mon.TVALID === 1'b1 && prev_valid === 1'b0) cov_wake_lead = 1;
      prev_valid = vif.cb_mon.TVALID;
      prev_wake  = vif.cb_mon.TWAKEUP;
    end
  endtask

  // ── Main observation loop ─────────────────────────────────────────────────
  protected task observe();
    logic [`AXI_DATA_W-1:0] latched_data; logic [`AXI_STRB_W-1:0] latched_keep, latched_strb;
    logic latched_last; logic [`AXI_ID_W-1:0] latched_id; logic [`AXI_DEST_W-1:0] latched_dest;
    bit valid_pending, prev_valid; int unsigned stall, gap;
    logic [`AXI_ID_W-1:0] last_id; logic [`AXI_DEST_W-1:0] last_dest; bit have_last;
    int unsigned pkt_beats;

    new_packet_ctx(pkt_beats);
    forever begin
      @(vif.cb_mon);

      if (vif.cb_mon.ARESETn !== 1'b1) begin
        if (valid_pending || pkt_beats > 0) cov_reset_ctx = valid_pending ? 2 : 1;
        cg_reset.sample();
        if (!in_reset_prev) begin
          in_reset_prev = 1;
          if (sb_h != null) sb_h.note_reset();
          trk_row("RST", obs_packets, pkt_beats, stall, "reset flush");
        end
        valid_pending = 0; prev_valid = 0; stall = 0;
        new_packet_ctx(pkt_beats);
        continue;
      end
      in_reset_prev = 0;

      // TVALID rising edge: latch payload for the stability checks.
      if (vif.cb_mon.TVALID === 1'b1 && prev_valid === 1'b0) begin
        latched_data=vif.cb_mon.TDATA; latched_keep=vif.cb_mon.TKEEP; latched_strb=vif.cb_mon.TSTRB;
        latched_last=vif.cb_mon.TLAST; latched_id=vif.cb_mon.TID; latched_dest=vif.cb_mon.TDEST;
        valid_pending = 1; stall = 0;
      end

      // chk_tvalid_stability (REQ_SLV_04): DUT must hold TVALID until TREADY.
      if (valid_pending && prev_valid === 1'b1 && vif.cb_mon.TVALID === 1'b0) begin
        `uvm_error("CHK/TVALID_STABILITY", $sformatf(
          "DUT dropped TVALID before TREADY (after %0d stall cycles) — Section 2.2", stall))
        trk_row("BEAT", obs_packets + 1, obs_beats + 1, stall, "CHK/TVALID_STABILITY");
        valid_pending = 0;
      end

      // chk_payload_stability (REQ_SLV_05): payload frozen while VIP stalls.
      if (valid_pending && vif.cb_mon.TVALID === 1'b1 && stall > 0) begin
        if (vif.cb_mon.TDATA!==latched_data || vif.cb_mon.TKEEP!==latched_keep ||
            vif.cb_mon.TSTRB!==latched_strb || vif.cb_mon.TLAST!==latched_last ||
            vif.cb_mon.TID!==latched_id     || vif.cb_mon.TDEST!==latched_dest) begin
          `uvm_error("CHK/PAYLOAD_STABILITY", $sformatf(
            "DUT mutated payload while TVALID HIGH and handshake outstanding (stall=%0d) — Section 2.2.1",
            stall))
          trk_row("BEAT", obs_packets + 1, obs_beats + 1, stall, "CHK/PAYLOAD_STABILITY");
        end
      end

      // chk_reserved_qual (REQ_SLV_10): TKEEP=0 & TSTRB=1 is reserved.
      if (vif.cb_mon.TVALID === 1'b1) begin
        if ((vif.cb_mon.TSTRB & ~vif.cb_mon.TKEEP) != '0) begin
          `uvm_error("CHK/RESERVED_QUAL",
                     "DUT drove reserved TKEEP=0/TSTRB=1 — Section 2.5")
          trk_row("BEAT", obs_packets + 1, obs_beats + 1, stall, "CHK/RESERVED_QUAL");
        end
      end

      // chk_parity (REQ_SLV_14): recompute odd parity over ALL lanes.
      cov_parity_bad = 0;
      if (cfg.has_parity && vif.cb_mon.TVALID === 1'b1) begin
        logic [`AXI_STRB_W-1:0] exp_chk;
        for (int i = 0; i < `AXI_STRB_W; i++) exp_chk[i] = odd_parity_byte(vif.cb_mon.TDATA[8*i +: 8]);
        if (vif.cb_mon.TDATACHK !== exp_chk) begin
          cov_parity_bad = 1;
          `uvm_error("CHK/PARITY", $sformatf(
            "DUT TDATACHK odd-parity mismatch: obs 0b%04b exp 0b%04b — Section 5.3",
            vif.cb_mon.TDATACHK, exp_chk))
          trk_row("BEAT", obs_packets + 1, obs_beats + 1, stall, "CHK/PARITY");
        end
        if (vif.cb_mon.TVALIDCHK !== ~vif.cb_mon.TVALID)
          `uvm_error("CHK/PARITY", "DUT TVALIDCHK not the inversion of TVALID — Section 5.3")
      end

      // ── Beat accepted: TVALID && TREADY on this edge ─────────────────────
      if (vif.cb_mon.TVALID === 1'b1 && vif.cb_mon.TREADY === 1'b1) begin
        obs_txns++;
        // chk_id_constant (REQ_SLV_11)
        if (obs_beats > 0) begin
          if (vif.cb_mon.TID !== last_id || vif.cb_mon.TDEST !== last_dest)
            `uvm_error("CHK/ID_CONSTANT", $sformatf(
              "DUT changed TID/TDEST mid-packet (beat %0d) — Section 2.7", obs_beats))
        end else begin
          last_id = vif.cb_mon.TID; last_dest = vif.cb_mon.TDEST;
        end
        pkt_beats++; obs_beats++;

        `uvm_info(get_type_name(), $sformatf(
          "[TXN %0d] TDATA=0x%08h TKEEP=0b%04b TSTRB=0b%04b TLAST=%0b TID=0x%0h TDEST=0x%0h",
          obs_txns, vif.cb_mon.TDATA, vif.cb_mon.TKEEP, vif.cb_mon.TSTRB, vif.cb_mon.TLAST,
          vif.cb_mon.TID, vif.cb_mon.TDEST), UVM_HIGH)

        cov_stall=stall; cov_keep=vif.cb_mon.TKEEP; cov_strb=vif.cb_mon.TSTRB; cov_ready_mode=0;
        cg_tready_profile.sample(); cg_dut_tvalid_stability.sample();
        cg_dut_payload_stability.sample(); cg_byte_qualifiers.sample(); cg_parity.sample();
        if (cfg.has_twakeup) cg_wakeup.sample();
        trk_row("BEAT", obs_packets + 1, pkt_beats, stall, "");

        valid_pending = 0;

        // chk_packet_framing (REQ_SLV_07): runaway packet (no TLAST by the bound).
        if (pkt_beats > cfg.max_packet_beats)
          `uvm_error("CHK/PKT_FRAMING", $sformatf(
            "Runaway packet: %0d beats accepted with no TLAST (bound %0d) — Section 2.6",
            pkt_beats, cfg.max_packet_beats))

        // TLAST: close the packet (REQ_SLV_07).
        if (vif.cb_mon.TLAST === 1'b1) begin
          obs_packets++;
          cov_pkt_len=pkt_beats; cov_id=last_id; cov_dest=last_dest;
          cov_gap_zero = (gap == 0);
          cov_id_changed = have_last ? ((last_id!==cov_id)||(last_dest!==cov_dest)) : 1'b0;
          cg_packet_length.sample(); cg_stream_recon.sample();
          `uvm_info("MON", $sformatf(
            "[PACKET %0d RECEIVED] beats=%0d TID=0x%0h TDEST=0x%0h gap=%0d",
            obs_packets, pkt_beats, last_id, last_dest, gap), UVM_HIGH)
          trk_row("PKT", obs_packets, pkt_beats, 0, "packet complete");
          if (sb_h != null) sb_h.note_received(last_id, last_dest, pkt_beats);
          have_last = 1; gap = 0;
          new_packet_ctx(pkt_beats);
        end
      end
      else if (pkt_beats == 0 && have_last && vif.cb_mon.TVALID !== 1'b1) gap++;

      if (valid_pending && vif.cb_mon.TVALID === 1'b1 && vif.cb_mon.TREADY !== 1'b1) stall++;
      prev_valid = vif.cb_mon.TVALID;
    end
  endtask

  protected function void new_packet_ctx(ref int unsigned pkt_beats);
    pkt_beats = 0; obs_beats = 0;
  endfunction

  function int unsigned get_observed_packets(); return obs_packets; endfunction

endclass

`endif
