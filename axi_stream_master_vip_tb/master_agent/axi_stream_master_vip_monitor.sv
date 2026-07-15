// =============================================================================
// AXI5-Stream Master VIP — Monitor
// Passive observation + protocol checkers + functional coverage.
// Assembles beats into packets on TLAST and broadcasts them to the scoreboard.
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_MONITOR_SV
`define AXI_STREAM_MASTER_VIP_MONITOR_SV

// The package includes the agent (and this monitor) BEFORE the scoreboard, so
// the type is not yet declared here. A forward typedef keeps the reset
// notification working without reordering the include dependency graph.
typedef class axi_stream_master_vip_scoreboard;

class axi_stream_master_vip_monitor extends uvm_monitor;
  `uvm_component_utils(axi_stream_master_vip_monitor)

  uvm_analysis_port #(axi_stream_master_vip_seq_item) ap;

  axi_stream_master_vip_agent_config cfg;

  protected virtual axi_stream_master_vip_if #(
    .DATA_W(`AXI_DATA_W), .ID_W(`AXI_ID_W), .DEST_W(`AXI_DEST_W),
    .USER_W(`AXI_USER_W), .HAS_PAR(`AXI_HAS_PAR), .HAS_WAKE(`AXI_HAS_WAKE)
  ) vif;

  // ── Observed-packet assembly state ────────────────────────────────────────
  protected axi_stream_master_vip_seq_item cur;
  protected int unsigned obs_packets;
  protected int unsigned obs_beats;
  protected int unsigned obs_txns;
  protected bit          in_reset_prev;

  // ── Coverage sampling variables ───────────────────────────────────────────
  protected int unsigned cov_stall;
  protected int unsigned cov_pkt_len;
  protected int unsigned cov_gap;
  protected int unsigned cov_wake_lead;
  protected bit          cov_id_changed;
  protected bit          cov_parity_bad;
  protected logic [`AXI_STRB_W-1:0] cov_keep, cov_strb;
  protected logic [`AXI_ID_W-1:0]   cov_id;
  protected logic [`AXI_DEST_W-1:0] cov_dest;
  protected bit          cov_valid_first, cov_ready_first, cov_same_cycle;
  protected bit          cov_reset_ctx_mid;

  // ── Covergroups (one per plan coverage_groups entry) ──────────────────────
  covergroup cg_handshake;
    option.per_instance = 1;
    cp_order : coverpoint {cov_valid_first, cov_ready_first, cov_same_cycle} {
      bins valid_first = {3'b100};
      bins ready_first = {3'b010};
      bins same_cycle  = {3'b001};
    }
    // NOTE: `small`, `medium` and `large` are reserved SystemVerilog keywords
    // (trireg charge strengths) and cannot be used as bin names. Hence b_* here.
    cp_stall : coverpoint cov_stall {
      bins b_zero  = {0};
      bins b_one   = {1};
      bins b_short = {[2:15]};
      bins b_med   = {[16:99]};
      bins b_long  = {[100:$]};
    }
    x_order_stall : cross cp_order, cp_stall;
  endgroup

  covergroup cg_payload_stability;
    option.per_instance = 1;
    cp_hold : coverpoint cov_stall {
      bins b_none  = {0};
      bins b_brief = {[1:5]};
      bins b_long  = {[6:$]};
    }
    cp_sparse : coverpoint cov_keep {
      bins b_all_ones = {'1};
      bins b_all_zero = {'0};
      bins b_sparse   = default;
    }
    x_hold_sparse : cross cp_hold, cp_sparse;
  endgroup

  covergroup cg_reset;
    option.per_instance = 1;
    cp_ctx : coverpoint cov_reset_ctx_mid {
      bins b_idle     = {0};
      bins b_mid_xfer = {1};
    }
  endgroup

  covergroup cg_packet_length;
    option.per_instance = 1;
    cp_len : coverpoint cov_pkt_len {
      bins b_one     = {1};
      bins b_two     = {2};
      bins b_small   = {[3:15]};
      bins b_med     = {[16:63]};
      bins b_large   = {[64:255]};
      bins b_maximal = {`MAX_PACKET_BEATS};
    }
  endgroup

  covergroup cg_packet_boundary;
    option.per_instance = 1;
    cp_gap : coverpoint cov_gap {
      bins b_zero = {0};
      bins b_one  = {1};
      bins b_more = {[2:$]};
    }
    cp_id_change : coverpoint cov_id_changed { bins b_same = {0}; bins b_changed = {1}; }
    // The zero-gap / same-ID bin is the REQ_MST_08 merging corner case.
    x_merge : cross cp_gap, cp_id_change;
  endgroup

  covergroup cg_byte_qualifiers;
    option.per_instance = 1;
    cp_keep : coverpoint cov_keep {
      bins b_all_ones = {'1};
      bins b_all_zero = {'0};
      bins b_sparse   = default;
    }
    cp_strb : coverpoint cov_strb {
      bins b_all_ones = {'1};
      bins b_all_zero = {'0};
      bins b_sparse   = default;
    }
    x_qual : cross cp_keep, cp_strb;
  endgroup

  covergroup cg_stream_identity;
    option.per_instance = 1;
    cp_id   : coverpoint cov_id   { bins b_lo = {[0:63]}; bins b_mid = {[64:191]}; bins b_hi = {[192:255]}; }
    cp_dest : coverpoint cov_dest { bins b_all[] = {[0:15]}; }
  endgroup

  covergroup cg_wakeup;
    option.per_instance = 1;
    cp_lead : coverpoint cov_wake_lead {
      bins b_one  = {1};
      bins b_two  = {2};
      bins b_few  = {[3:7]};
      bins b_many = {[8:$]};
    }
  endgroup

  covergroup cg_parity;
    option.per_instance = 1;
    cp_detect : coverpoint cov_parity_bad { bins b_ok = {0}; bins b_fault_detected = {1}; }
    cp_dens   : coverpoint cov_keep {
      bins b_dense  = {'1};
      bins b_null   = {'0};
      bins b_sparse = default;
    }
    // Parity must hold over null-byte lanes too (REQ_MST_14).
    x_parity_density : cross cp_detect, cp_dens;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
    cg_handshake         = new();
    cg_payload_stability = new();
    cg_reset             = new();
    cg_packet_length     = new();
    cg_packet_boundary   = new();
    cg_byte_qualifiers   = new();
    cg_stream_identity   = new();
    cg_wakeup            = new();
    cg_parity            = new();
  endfunction

  // Fetched lazily: the env publishes the scoreboard in connect_phase, which
  // runs AFTER this component's build_phase.
  protected axi_stream_master_vip_scoreboard sb_h;

  // ── Protocol tracker (uvc_generator SKILL §2) ─────────────────────────────
  // Schema-driven uvm_tracker instance, separate from the driver's. This one
  // records what was OBSERVED on the wire; the driver's records what was DRIVEN.
  // Orthogonal to verbosity: rows are written even at UVM_MEDIUM.
  uvm_tracker trk;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(axi_stream_master_vip_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("MON/NOCFG", "agent_config not found in ConfigDB")
    vif = cfg.vif;
    trk = uvm_tracker::type_id::create("trk");
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    void'(uvm_config_db #(axi_stream_master_vip_scoreboard)::get(null, "*", "sb", sb_h));

    if (cfg.enable_tracker) begin
      // Monitor tracker layout (SKILL: "Monitor Tracker Layout")
      trk.add_column("TIME",   14, "%t");
      trk.add_column("KIND",    6, "%s");
      trk.add_column("PKT",     6, "%0d");
      trk.add_column("BEAT",    6, "%0d");
      trk.add_column("TDATA",  `TRK_COLW(`AXI_DATA_W), "%0h");
      trk.add_column("KEEP",   `TRK_COLW(`AXI_STRB_W), "%0b");
      trk.add_column("STRB",   `TRK_COLW(`AXI_STRB_W), "%0b");
      trk.add_column("LAST",    5, "%0b");
      trk.add_column("TID",    `TRK_COLW(`AXI_ID_W),   "%0h");
      trk.add_column("DEST",   `TRK_COLW(`AXI_DEST_W), "%0h");
      trk.add_column("STALL",   6, "%0d");
      trk.add_column("GAP",     5, "%0d");
      trk.add_column("PAR",     5, "%s");
      trk.add_column("NOTE",   22, "%s");
      trk.open(get_full_name());
    end
  endfunction

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    if (cfg.enable_tracker) trk.close();
  endfunction

  // KIND="BEAT" per collected beat; KIND="PKT" when a packet is finalized.
  // NOTE carries the checker id on a violation, per the skill's layout.
  protected function void trk_row(string kind, int unsigned pkt, int unsigned beat,
                                  int unsigned stall, int unsigned gap, string note);
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
    vals.push_back($sformatf("%0h", vif.cb_mon.TDEST));
    vals.push_back($sformatf("%0d", stall));
    vals.push_back($sformatf("%0d", gap));
    vals.push_back(cov_parity_bad ? "BAD" : "OK");
    vals.push_back(note);
    trk.write_row(vals);
  endfunction

  protected function logic odd_parity_byte(logic [7:0] b);
    return ~(^b);
  endfunction

  task run_phase(uvm_phase phase);
    fork
      chk_reset_tvalid();
      chk_reset_exit();
      chk_wakeup_lead();
      observe();
    join_none
  endtask

  // ── chk_reset_tvalid (REQ_MST_05, Section 2.8.2 Page 28) ──────────────────
  protected task chk_reset_tvalid();
    forever begin
      @(vif.cb_mon);
      if (vif.cb_mon.ARESETn === 1'b0 && vif.cb_mon.TVALID === 1'b1)
        `uvm_error("CHK/RESET_TVALID",
                   "TVALID is HIGH while ARESETn is LOW — Section 2.8.2 requires TVALID LOW during reset")
    end
  endtask

  // ── chk_reset_exit (REQ_MST_06, Section 2.8.2 Page 28) ────────────────────
  // TVALID may only rise on an ACLK edge FOLLOWING the edge at which ARESETn
  // samples HIGH. Same-edge assertion is a race against a DUT still leaving reset.
  protected task chk_reset_exit();
    bit reset_released_this_edge;
    bit prev_resetn;
    forever begin
      @(vif.cb_mon);
      reset_released_this_edge = (prev_resetn === 1'b0) && (vif.cb_mon.ARESETn === 1'b1);
      if (reset_released_this_edge && vif.cb_mon.TVALID === 1'b1)
        `uvm_error("CHK/RESET_EXIT",
                   "TVALID asserted on the same edge ARESETn sampled HIGH — the mandatory one-cycle gap was not observed")
      prev_resetn = vif.cb_mon.ARESETn;
    end
  endtask

  // ── chk_wakeup_lead / chk_wakeup_hold (REQ_MST_12, Section 2.3 Page 20) ───
  protected task chk_wakeup_lead();
    bit prev_valid, prev_wake;
    if (!cfg.has_twakeup) return;
    forever begin
      @(vif.cb_mon);
      // Every TVALID rising edge must be preceded by >=1 full cycle of TWAKEUP HIGH.
      if (vif.cb_mon.TVALID === 1'b1 && prev_valid === 1'b0 && prev_wake !== 1'b1)
        `uvm_error("CHK/WAKE_LEAD",
                   "TVALID rose without TWAKEUP asserted for at least one prior cycle — Section 2.3")
      // TWAKEUP must not fall while a handshake is outstanding.
      if (prev_wake === 1'b1 && vif.cb_mon.TWAKEUP === 1'b0 &&
          vif.cb_mon.TVALID === 1'b1 && vif.cb_mon.TREADY !== 1'b1)
        `uvm_error("CHK/WAKE_HOLD",
                   "TWAKEUP deasserted while TVALID is HIGH and TREADY not yet observed — Section 2.3")
      if (vif.cb_mon.TVALID === 1'b1 && prev_valid === 1'b0)
        cov_wake_lead = 1;    // conservative: lead was at least one cycle
      prev_valid = vif.cb_mon.TVALID;
      prev_wake  = vif.cb_mon.TWAKEUP;
    end
  endtask

  // ── Main observation loop ─────────────────────────────────────────────────
  protected task observe();
    logic [`AXI_DATA_W-1:0] latched_data;
    logic [`AXI_STRB_W-1:0] latched_keep, latched_strb;
    logic                   latched_last;
    logic [`AXI_ID_W-1:0]   latched_id;
    logic [`AXI_DEST_W-1:0] latched_dest;
    bit                     handshake_pending;
    bit                     prev_valid;
    int unsigned            stall;
    int unsigned            gap;
    logic [`AXI_ID_W-1:0]   last_pkt_id;
    logic [`AXI_DEST_W-1:0] last_pkt_dest;
    bit                     have_last_pkt;

    new_packet();

    forever begin
      @(vif.cb_mon);

      if (vif.cb_mon.ARESETn !== 1'b1) begin
        // Abandon any partially-assembled packet: reset discards in-flight beats.
        if (handshake_pending || obs_beats > 0) cov_reset_ctx_mid = 1;
        cg_reset.sample();

        // Notify the scoreboard once per reset assertion so it can flush the
        // expectations that this reset just discarded.
        if (!in_reset_prev) begin
          in_reset_prev = 1;
          if (sb_h != null) sb_h.note_reset();
        end

        handshake_pending = 0;
        prev_valid        = 0;
        stall             = 0;
        new_packet();
        continue;
      end
      in_reset_prev = 0;

      // ── TVALID rising edge: latch the payload for the stability checks ────
      if (vif.cb_mon.TVALID === 1'b1 && prev_valid === 1'b0) begin
        latched_data = vif.cb_mon.TDATA;
        latched_keep = vif.cb_mon.TKEEP;
        latched_strb = vif.cb_mon.TSTRB;
        latched_last = vif.cb_mon.TLAST;
        latched_id   = vif.cb_mon.TID;
        latched_dest = vif.cb_mon.TDEST;
        handshake_pending = 1;
        stall             = 0;
        cov_valid_first   = (vif.cb_mon.TREADY !== 1'b1);
        cov_same_cycle    = (vif.cb_mon.TREADY === 1'b1);
        cov_ready_first   = 0;
      end

      // ── chk_tvalid_stability (REQ_MST_02) ───────────────────────────────
      if (handshake_pending && prev_valid === 1'b1 && vif.cb_mon.TVALID === 1'b0) begin
        `uvm_error("CHK/TVALID_STABILITY", $sformatf(
          "TVALID deasserted before TREADY was observed HIGH (after %0d stall cycles) — Section 2.2",
          stall))
          trk_row("BEAT", obs_packets + 1, obs_beats, stall, 0, "CHK/TVALID_STABILITY");
        handshake_pending = 0;
      end

      // ── chk_payload_stability (REQ_MST_03) ──────────────────────────────
      // Qualifiers are checked too: a mutating TKEEP relocates byte boundaries
      // without altering TDATA, and would otherwise slip through.
      if (handshake_pending && vif.cb_mon.TVALID === 1'b1 && stall > 0) begin
        if (vif.cb_mon.TDATA !== latched_data ||
            vif.cb_mon.TKEEP !== latched_keep ||
            vif.cb_mon.TSTRB !== latched_strb ||
            vif.cb_mon.TLAST !== latched_last ||
            vif.cb_mon.TID   !== latched_id   ||
            vif.cb_mon.TDEST !== latched_dest)
          begin
            `uvm_error("CHK/PAYLOAD_STABILITY", $sformatf(
              "Payload changed while TVALID HIGH and handshake outstanding (stall=%0d) — Section 2.2.1",
              stall))
          trk_row("BEAT", obs_packets + 1, obs_beats, stall, 0, "CHK/PAYLOAD_STABILITY");
          end
      end

      // ── chk_reserved_qual (REQ_MST_10, Section 2.5 Page 24) ─────────────
      // begin/end is load-bearing: without it the second statement escapes the
      // if-guard and executes every cycle, idle ones included.
      if (vif.cb_mon.TVALID === 1'b1) begin
        if ((vif.cb_mon.TSTRB & ~vif.cb_mon.TKEEP) != '0) begin
          `uvm_error("CHK/RESERVED_QUAL",
                     "Reserved byte-qualifier encoding TKEEP=0 with TSTRB=1 — Section 2.5")
          trk_row("BEAT", obs_packets + 1, obs_beats, stall, 0, "CHK/RESERVED_QUAL");
        end
      end

      // ── chk_parity (REQ_MST_13 / REQ_MST_14, Sections 5.3 / 5.5) ────────
      // Recomputed over ALL lanes including null lanes.
      cov_parity_bad = 0;
      if (cfg.has_parity && vif.cb_mon.TVALID === 1'b1) begin
        logic [`AXI_STRB_W-1:0] exp_chk;
        for (int b = 0; b < `AXI_STRB_W; b++)
          exp_chk[b] = odd_parity_byte(vif.cb_mon.TDATA[8*b +: 8]);
        if (vif.cb_mon.TDATACHK !== exp_chk) begin
          cov_parity_bad = 1;
          `uvm_error("CHK/PARITY", $sformatf(
            "TDATACHK odd-parity mismatch: observed 0b%04b, expected 0b%04b (TDATA=0x%08h) — Section 5.3",
            vif.cb_mon.TDATACHK, exp_chk, vif.cb_mon.TDATA))
          trk_row("BEAT", obs_packets + 1, obs_beats, stall, 0, "CHK/PARITY");
        end
        if (vif.cb_mon.TVALIDCHK !== ~vif.cb_mon.TVALID)
          `uvm_error("CHK/PARITY", "TVALIDCHK is not the inversion of TVALID — Section 5.3")
        if (vif.cb_mon.TLASTCHK !== ~vif.cb_mon.TLAST)
          `uvm_error("CHK/PARITY", "TLASTCHK is not the inversion of TLAST — Section 5.3")
      end

      // ── Beat accepted: TVALID && TREADY on this edge ─────────────────────
      if (vif.cb_mon.TVALID === 1'b1 && vif.cb_mon.TREADY === 1'b1) begin

        // chk_id_constant (REQ_MST_11, Section 2.7 Page 27)
        if (obs_beats > 0) begin
          if (vif.cb_mon.TID !== cur.id || vif.cb_mon.TDEST !== cur.dest)
            `uvm_error("CHK/ID_CONSTANT", $sformatf(
              "TID/TDEST changed mid-packet (beat %0d): observed 0x%0h/0x%0h, packet is 0x%0h/0x%0h — Section 2.7",
              obs_beats, vif.cb_mon.TID, vif.cb_mon.TDEST, cur.id, cur.dest))
        end else begin
          cur.id   = vif.cb_mon.TID;
          cur.dest = vif.cb_mon.TDEST;
          cur.user = vif.cb_mon.TUSER;
        end

        cur.data.push_back(vif.cb_mon.TDATA);
        cur.keep.push_back(vif.cb_mon.TKEEP);
        cur.strb.push_back(vif.cb_mon.TSTRB);
        cur.inter_beat_delay.push_back(stall);
        obs_beats++;
        obs_txns++;

        // Transaction logging: UVM_HIGH (coding_guideline 1a).
        // EVERY observed transaction — never conditional, never sampled.
        `uvm_info(get_type_name(), $sformatf(
          "[TXN %0d] TDATA=0x%08h TKEEP=0b%04b TSTRB=0b%04b TLAST=%0b TID=0x%0h TDEST=0x%0h TUSER=0x%0h",
          obs_txns, vif.cb_mon.TDATA, vif.cb_mon.TKEEP, vif.cb_mon.TSTRB, vif.cb_mon.TLAST,
          vif.cb_mon.TID, vif.cb_mon.TDEST, vif.cb_mon.TUSER), UVM_HIGH)

        // Beat-level interface data: UVM_FULL (coding_guideline 1b).
        `uvm_info(get_type_name(), $sformatf(
          "[BEAT %0d of packet %0d] TDATA=0x%08h TDATACHK=0b%04b TVALIDCHK=%0b TLASTCHK=%0b TWAKEUP=%0b stall=%0d",
          obs_beats, obs_packets + 1, vif.cb_mon.TDATA, vif.cb_mon.TDATACHK,
          vif.cb_mon.TVALIDCHK, vif.cb_mon.TLASTCHK, vif.cb_mon.TWAKEUP, stall), UVM_FULL)

        trk_row("BEAT", obs_packets + 1, obs_beats, stall, 0, "");

        // Coverage sampling for this beat.
        cov_stall = stall;
        cov_keep  = vif.cb_mon.TKEEP;
        cov_strb  = vif.cb_mon.TSTRB;
        cg_handshake.sample();
        cg_payload_stability.sample();
        cg_byte_qualifiers.sample();
        cg_parity.sample();
        if (cfg.has_twakeup) cg_wakeup.sample();

        handshake_pending = 0;

        // ── TLAST: close the packet (REQ_MST_07, Section 2.6 Page 26) ──────
        if (vif.cb_mon.TLAST === 1'b1) begin
          cur.packet_beats = obs_beats;
          obs_packets++;

          cov_pkt_len    = obs_beats;
          cov_gap        = gap;
          cov_id         = cur.id;
          cov_dest       = cur.dest;
          cov_id_changed = have_last_pkt ? ((cur.id !== last_pkt_id) ||
                                            (cur.dest !== last_pkt_dest)) : 1'b0;
          cg_packet_length.sample();
          cg_packet_boundary.sample();
          cg_stream_identity.sample();

          // Packet assembly boundary: UVM_HIGH (coding_guideline 1a).
          `uvm_info("MON", $sformatf(
            "[PACKET %0d OBSERVED] beats=%0d TID=0x%0h TDEST=0x%0h data_bytes=%0d gap=%0d",
            obs_packets, cur.packet_beats, cur.id, cur.dest, cur.data_byte_count(), gap),
            UVM_HIGH)

          trk_row("PKT", obs_packets, cur.packet_beats, 0, gap, "packet complete");
          ap.write(cur);

          last_pkt_id   = cur.id;
          last_pkt_dest = cur.dest;
          have_last_pkt = 1;
          gap           = 0;
          new_packet();
        end
      end
      else if (obs_beats == 0) begin
        // Count idle cycles between packets for the boundary covergroup.
        if (have_last_pkt && vif.cb_mon.TVALID !== 1'b1) gap++;
      end

      if (handshake_pending && vif.cb_mon.TVALID === 1'b1 &&
          vif.cb_mon.TREADY !== 1'b1) begin
        stall++;
        if (stall == 1) cov_ready_first = 0;
      end

      prev_valid = vif.cb_mon.TVALID;
    end
  endtask

  protected function void new_packet();
    cur = axi_stream_master_vip_seq_item::type_id::create("obs_pkt");
    cur.data.delete();
    cur.keep.delete();
    cur.strb.delete();
    cur.inter_beat_delay.delete();
    obs_beats = 0;
  endfunction

  function int unsigned get_observed_packets();
    return obs_packets;
  endfunction

endclass

`endif
