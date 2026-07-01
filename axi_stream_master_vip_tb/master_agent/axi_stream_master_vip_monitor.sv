// AXI-Stream Master VIP Monitor
// Observes all driven Master VIP outputs and DUT Slave TREADY.
// Checks: TVALID stability, parity correctness, TWAKEUP rules, TSTRB/TKEEP law.
// Drives 12 functional coverage groups.
class axi_stream_master_vip_monitor extends uvm_monitor;
  `uvm_component_utils(axi_stream_master_vip_monitor)

  virtual axi_stream_master_vip_if vif;
  axi_stream_master_vip_agent_config cfg;
  uvm_analysis_port #(axi_stream_master_vip_seq_item) ap;

  // ── Payload snapshot (captured on first TVALID=1 per beat) ───────────────────
  logic [AXI_DATA_W-1:0]   snap_tdata;
  logic [AXI_STRB_W-1:0]   snap_tkeep, snap_tstrb;
  logic                     snap_tlast;
  logic [AXI_ID_W-1:0]     snap_tid;
  logic [AXI_DEST_W-1:0]   snap_tdest;
  logic [AXI_USER_W-1:0]   snap_tuser;
  bit                       snap_valid = 0;

  // ── Coverage tracking variables ───────────────────────────────────────────────
  int  tready_stall_depth       = 0;  // cycles TVALID=1, TREADY=0
  int  pkt_beat_count           = 0;
  bit  pkt_back_to_back         = 0;
  bit  prev_tlast               = 1;  // treat start as if prior packet ended
  int  twakeup_lead_cycles      = 0;
  bit  twakeup_seen             = 0;
  bit  twakeup_active           = 0;
  int  active_tid_count         = 1;
  int  null_pkt_ctx             = 0;  // 0=isolated 1=after-data 2=before-data 3=b2b-null
  bit  prev_pkt_was_null        = 0;
  int  stall_beat_position      = 0;  // 0=first 1=mid 2=last
  bit  continuous_pkt_viol      = 0;
  int  handshake_ordering       = 0;  // 0=TVALID-first 1=TREADY-first 2=simultaneous
  int  parity_error_count       = 0;
  bit  prev_tvalid              = 0;

  // ── Packet tracker ─────────────────────────────────────────────────────────────
  int tracker_fd;
  int pkt_count   = 0;
  int null_count  = 0;
  int total_beats = 0;

  // ── Coverage Groups ───────────────────────────────────────────────────────────

  // REQ_MST_01: TVALID stability
  covergroup cg_tvalid_stability;
    cp_stall: coverpoint tready_stall_depth {
      bins zero_stall  = {0};
      bins short_stall = {[1:5]};
      bins mid_stall   = {[6:20]};
      bins long_stall  = {[21:100]};
    }
  endgroup

  // REQ_MST_02 + REQ_MST_03: Handshake scenarios
  covergroup cg_handshake_scenarios;
    cp_order: coverpoint handshake_ordering {
      bins tvalid_first  = {0};
      bins tready_first  = {1};
      bins simultaneous  = {2};
    }
    cp_pkt_len: coverpoint pkt_beat_count {
      bins single   = {1};
      bins short_p  = {[2:8]};
      bins mid_p    = {[9:64]};
      bins long_p   = {[65:256]};
    }
    cx_order_len: cross cp_order, cp_pkt_len;
  endgroup

  // REQ_MST_04 + REQ_MST_05: Packet boundaries and null termination
  covergroup cg_packet_boundary;
    cp_len: coverpoint pkt_beat_count {
      bins single_beat = {1};
      bins short_burst = {[2:8]};
      bins mid_burst   = {[9:64]};
      bins long_burst  = {[65:256]};
    }
    cp_b2b: coverpoint pkt_back_to_back {
      bins isolated     = {0};
      bins back_to_back = {1};
    }
    cp_null_term: coverpoint null_pkt_ctx {
      bins isolated  = {0};
      bins after_data= {1};
      bins b2b_null  = {3};
    }
    cx_len_b2b: cross cp_len, cp_b2b;
  endgroup

  // REQ_MST_06: TKEEP null-byte patterns
  covergroup cg_tkeep_patterns;
    cp_tkeep: coverpoint snap_tkeep {
      bins all_high  = {4'b1111};
      bins all_low   = {4'b0000};
      bins alt_5555  = {4'b0101};
      bins alt_AAAA  = {4'b1010};
    }
    cp_tlast_state: coverpoint snap_tlast {
      bins mid_packet  = {0};
      bins boundary    = {1};
    }
    cx_keep_tlast: cross cp_tkeep, cp_tlast_state;
  endgroup

  // REQ_MST_07: TSTRB qualification
  covergroup cg_tstrb_qualification;
    cp_combo: coverpoint {snap_tkeep[0], snap_tstrb[0]} {
      bins data_byte     = {2'b11};  // TKEEP=1, TSTRB=1
      bins position_byte = {2'b10};  // TKEEP=1, TSTRB=0
      bins null_byte     = {2'b00};  // TKEEP=0, TSTRB=0
      // 2'b01 (reserved) should NEVER appear
    }
  endgroup

  // REQ_MST_08: TID stream interleaving
  covergroup cg_stream_interleaving;
    cp_tid: coverpoint snap_tid {
      bins single_stream  = {0};
      bins stream_2       = {1};
      bins stream_3       = {2};
      bins stream_4plus   = {[3:255]};
    }
    cp_pkt_len: coverpoint pkt_beat_count {
      bins short_p = {[1:8]};
      bins mid_p   = {[9:64]};
      bins long_p  = {[65:256]};
    }
    cx_tid_len: cross cp_tid, cp_pkt_len;
  endgroup

  // REQ_MST_09: Continuous packet mode
  covergroup cg_continuous_packets;
    cp_enabled: coverpoint cfg.continuous_pkt_mode {
      bins disabled = {0};
      bins enabled  = {1};
    }
    cp_viol: coverpoint continuous_pkt_viol {
      bins no_viol    = {0};
      bins tid_change = {1};
      bins null_byte  = {2};
    }
    cx_mode_viol: cross cp_enabled, cp_viol;
  endgroup

  // REQ_MST_10: Reset scenarios
  covergroup cg_reset_scenarios;
    cp_reset_ctx: coverpoint null_pkt_ctx {
      bins idle     = {0};
      bins mid_pkt  = {1};
      bins at_xfer  = {2};
    }
    cp_pkt_cnt: coverpoint pkt_count {
      bins first_pkt  = {0};
      bins mid_sess   = {[1:10]};
      bins late_sess  = {[11:100]};
    }
  endgroup

  // REQ_MST_11: TWAKEUP timing
  covergroup cg_twakeup_timing;
    cp_lead: coverpoint twakeup_lead_cycles {
      bins simultaneous  = {0};
      bins one_cycle_pre = {1};
      bins two_or_more   = {[2:8]};
    }
    cp_active: coverpoint twakeup_active {
      bins inactive = {0};
      bins active   = {1};
    }
  endgroup

  // REQ_MST_12: Parity signals
  covergroup cg_parity_signals;
    cp_err_cnt: coverpoint parity_error_count {
      bins no_errors = {0};
      bins errors    = {[1:100]};
    }
    cp_treadychk: coverpoint vif.cb_mon.TREADYCHK {
      bins zero = {0};
      bins one  = {1};
    }
  endgroup

  // Cross-cutting: data bus width
  covergroup cg_data_bus_width;
    cp_width: coverpoint AXI_DATA_W {
      bins w32  = {32};
      bins w64  = {64};
      bins w128 = {128};
    }
    cp_tkeep_density: coverpoint $countones(snap_tkeep) {
      bins empty   = {0};
      bins partial = {[1:3]};
      bins full    = {4};
    }
    cx_width_density: cross cp_width, cp_tkeep_density;
  endgroup

  // Negative violations tracker
  covergroup cg_negative_violations;
    cp_viol_type: coverpoint continuous_pkt_viol {
      bins no_viol       = {0};
      bins tvalid_drop   = {1};
      bins tstrb_illegal = {2};
      bins tid_mid_pkt   = {3};
    }
    cp_parity_err: coverpoint parity_error_count {
      bins no_parity_err = {0};
      bins parity_err    = {[1:$]};
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_tvalid_stability    = new();
    cg_handshake_scenarios = new();
    cg_packet_boundary     = new();
    cg_tkeep_patterns      = new();
    cg_tstrb_qualification = new();
    cg_stream_interleaving = new();
    cg_continuous_packets  = new();
    cg_reset_scenarios     = new();
    cg_twakeup_timing      = new();
    cg_parity_signals      = new();
    cg_data_bus_width      = new();
    cg_negative_violations = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual axi_stream_master_vip_if)::get(this, "", "vif", vif))
      `uvm_fatal("CFG", "No VIF for axi_stream_master_vip_monitor")
    if (!uvm_config_db #(axi_stream_master_vip_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("CFG", "No CFG for axi_stream_master_vip_monitor")
  endfunction

  // ── Odd parity helpers ────────────────────────────────────────────────────────
  function automatic logic byte_odd_parity(logic [7:0] b);
    return ~^b;
  endfunction

  function automatic logic [AXI_STRB_W-1:0] compute_tdatachk(logic [AXI_DATA_W-1:0] d);
    logic [AXI_STRB_W-1:0] chk;
    for (int i = 0; i < AXI_STRB_W; i++)
      chk[i] = byte_odd_parity(d[8*i +: 8]);
    return chk;
  endfunction

  // ── Parity verification ────────────────────────────────────────────────────────
  task verify_parity_signals();
    logic [AXI_STRB_W-1:0] exp_datachk;
    logic exp_validchk, exp_lastchk, exp_wakeupchk, exp_readychk;

    exp_validchk  = ~vif.cb_mon.TVALID;
    exp_wakeupchk = ~vif.cb_mon.TWAKEUP;
    exp_readychk  = ~vif.cb_mon.TREADY;  // DUT-driven parity check

    // Check TVALIDCHK (always when ARESETn=1)
    if (vif.cb_mon.TVALIDCHK !== exp_validchk) begin
      `uvm_error("MON_PAR", $sformatf(
        "TVALIDCHK_PARITY_ERROR: got=%0b expected=%0b",
        vif.cb_mon.TVALIDCHK, exp_validchk))
      parity_error_count++;
    end

    // Check TWAKEUPCHK
    if (cfg.has_twakeup && vif.cb_mon.TWAKEUPCHK !== exp_wakeupchk) begin
      `uvm_error("MON_PAR", $sformatf(
        "TWAKEUPCHK_PARITY_ERROR: got=%0b expected=%0b",
        vif.cb_mon.TWAKEUPCHK, exp_wakeupchk))
      parity_error_count++;
    end

    // Check TREADYCHK (DUT output)
    if (vif.cb_mon.TREADYCHK !== exp_readychk) begin
      `uvm_error("MON_PAR", $sformatf(
        "TREADYCHK_PARITY_ERROR (DUT): got=%0b expected=%0b",
        vif.cb_mon.TREADYCHK, exp_readychk))
      parity_error_count++;
    end

    // Data-dependent checks (only valid when TVALID=1)
    if (vif.cb_mon.TVALID === 1'b1) begin
      exp_datachk  = compute_tdatachk(vif.cb_mon.TDATA);
      exp_lastchk  = ~vif.cb_mon.TLAST;

      if (vif.cb_mon.TDATACHK !== exp_datachk) begin
        `uvm_error("MON_PAR", $sformatf(
          "TDATACHK_PARITY_ERROR: got=0x%0h expected=0x%0h TDATA=0x%08h",
          vif.cb_mon.TDATACHK, exp_datachk, vif.cb_mon.TDATA))
        parity_error_count++;
      end
      if (vif.cb_mon.TLASTCHK !== exp_lastchk) begin
        `uvm_error("MON_PAR", $sformatf(
          "TLASTCHK_PARITY_ERROR: got=%0b expected=%0b TLAST=%0b",
          vif.cb_mon.TLASTCHK, exp_lastchk, vif.cb_mon.TLAST))
        parity_error_count++;
      end
    end
  endtask

  // ── Main run phase ────────────────────────────────────────────────────────────
  task run_phase(uvm_phase phase);
    axi_stream_master_vip_seq_item item;

    if (cfg.enable_tracker) begin
      tracker_fd = $fopen("master_vip_packet_tracker.log", "w");
      $fwrite(tracker_fd, "== AXI-Stream Master VIP Packet Tracker ==\n");
    end

    @(posedge vif.ARESETn);
    @(vif.cb_mon);

    forever begin
      @(vif.cb_mon);

      // ── Reset handling ────────────────────────────────────────────────────────
      if (vif.cb_mon.ARESETn === 1'b0) begin
        if (vif.cb_mon.TVALID === 1'b1)
          `uvm_error("MON_RST", "TVALID_DURING_RESET: Master VIP must drive TVALID=0 during reset!")
        snap_valid         = 0;
        tready_stall_depth = 0;
        prev_tvalid        = 0;
        continue;
      end

      // ── Parity checks every ARESETn=1 cycle ──────────────────────────────────
      if (cfg.has_parity)
        verify_parity_signals();

      // ── TWAKEUP tracking ──────────────────────────────────────────────────────
      if (cfg.has_twakeup) begin
        if (vif.cb_mon.TWAKEUP === 1'b1) begin
          twakeup_active = 1;
          if (!twakeup_seen) twakeup_seen = 1;
          // Check: if TVALID=1 and TREADY=0, TWAKEUP must stay HIGH
          if (vif.cb_mon.TVALID === 1'b1 && vif.cb_mon.TREADY !== 1'b1)
            ;  // TWAKEUP is currently HIGH — correct
        end else begin
          if (twakeup_active && vif.cb_mon.TVALID === 1'b1 && vif.cb_mon.TREADY !== 1'b1) begin
            `uvm_error("MON_WKP",
              "TWAKEUP_DROPPED_BEFORE_TREADY: TWAKEUP deasserted while TVALID=1 and TREADY=0!")
          end
          twakeup_active = 0;
        end
        if (vif.cb_mon.TWAKEUP === 1'b0 && vif.cb_mon.TVALID === 1'b1 && !twakeup_seen)
          twakeup_lead_cycles = 0;
      end

      // ── TVALID window: stability and stall tracking ───────────────────────────
      if (vif.cb_mon.TVALID === 1'b1 && vif.cb_mon.TREADY !== 1'b1) begin
        tready_stall_depth++;

        if (snap_valid) begin
          // Payload stability check — must not change while waiting for TREADY
          if (vif.cb_mon.TDATA  !== snap_tdata  ||
              vif.cb_mon.TKEEP  !== snap_tkeep  ||
              vif.cb_mon.TSTRB  !== snap_tstrb  ||
              vif.cb_mon.TLAST  !== snap_tlast  ||
              vif.cb_mon.TID    !== snap_tid    ||
              vif.cb_mon.TDEST  !== snap_tdest  ||
              vif.cb_mon.TUSER  !== snap_tuser) begin
            `uvm_error("MON_STAB", $sformatf(
              "TVALID_STABILITY_VIOLATION: signal changed during stall! " +
              "TDATA: 0x%08h->0x%08h TKEEP: 0b%04b->0b%04b TID: 0x%0h->0x%0h",
              snap_tdata, vif.cb_mon.TDATA, snap_tkeep, vif.cb_mon.TKEEP,
              snap_tid, vif.cb_mon.TID))
          end
        end else begin
          // First cycle of TVALID=1 — take snapshot
          snap_tdata  = vif.cb_mon.TDATA;
          snap_tkeep  = vif.cb_mon.TKEEP;
          snap_tstrb  = vif.cb_mon.TSTRB;
          snap_tlast  = vif.cb_mon.TLAST;
          snap_tid    = vif.cb_mon.TID;
          snap_tdest  = vif.cb_mon.TDEST;
          snap_tuser  = vif.cb_mon.TUSER;
          snap_valid  = 1;

          handshake_ordering = 0;  // TVALID first
          stall_beat_position = (pkt_beat_count == 0) ? 0 : 1;
        end

        // TSTRB/TKEEP reserved combination check (per-bit)
        for (int i = 0; i < AXI_STRB_W; i++) begin
          if (vif.cb_mon.TKEEP[i] === 1'b0 && vif.cb_mon.TSTRB[i] === 1'b1)
            `uvm_fatal("MON_QUAL", $sformatf(
              "RESERVED_QUALIFIER: TKEEP[%0d]=0 with TSTRB[%0d]=1 (Table 2-3 violation)", i, i))
        end

        // Continuous packet mode checks
        if (cfg.continuous_pkt_mode && snap_valid && vif.cb_mon.TLAST !== 1'b1) begin
          if (vif.cb_mon.TID !== snap_tid) begin
            `uvm_error("MON_CONT", "CONTINUOUS_PKT_TID_CHANGE_VIOLATION: TID changed while TLAST=0!")
            continuous_pkt_viol = 1;
          end
          if (vif.cb_mon.TKEEP !== {(AXI_STRB_W){1'b1}}) begin
            `uvm_error("MON_CONT", "CONTINUOUS_PKTS_NULL_BYTE_VIOLATION: TKEEP not all-1 while TLAST=0!")
            continuous_pkt_viol = 2;
          end
        end

        cg_tvalid_stability.sample();
      end  // TVALID pending window

      // ── Handshake completion ──────────────────────────────────────────────────
      if (vif.cb_mon.TVALID === 1'b1 && vif.cb_mon.TREADY === 1'b1) begin
        total_beats++;
        pkt_beat_count++;

        // TREADY-first detection
        if (!snap_valid && prev_tvalid === 1'b0)
          handshake_ordering = 1;  // TREADY was pre-asserted
        else if (tready_stall_depth == 0)
          handshake_ordering = 2;  // simultaneous

        // Capture snapshot for first-cycle handshakes
        if (!snap_valid) begin
          snap_tdata  = vif.cb_mon.TDATA;
          snap_tkeep  = vif.cb_mon.TKEEP;
          snap_tstrb  = vif.cb_mon.TSTRB;
          snap_tlast  = vif.cb_mon.TLAST;
          snap_tid    = vif.cb_mon.TID;
          snap_tdest  = vif.cb_mon.TDEST;
          snap_tuser  = vif.cb_mon.TUSER;
          snap_valid  = 1;
        end

        // Create and broadcast received item to scoreboard
        item = axi_stream_master_vip_seq_item::type_id::create("rx_item");
        item.tdata = vif.cb_mon.TDATA;
        item.tkeep = vif.cb_mon.TKEEP;
        item.tstrb = vif.cb_mon.TSTRB;
        item.tlast = vif.cb_mon.TLAST;
        item.tid   = vif.cb_mon.TID;
        item.tdest = vif.cb_mon.TDEST;
        item.tuser = vif.cb_mon.TUSER;
        ap.write(item);

        // Sample beat-level coverage
        cg_tvalid_stability.sample();
        cg_handshake_scenarios.sample();
        cg_tkeep_patterns.sample();
        cg_tstrb_qualification.sample();
        cg_stream_interleaving.sample();
        cg_parity_signals.sample();

        `uvm_info("MON", $sformatf(
          "[MON] BEAT#%0d COMPLETE | TDATA=0x%08h TKEEP=0b%04b TLAST=%0b TID=0x%0h stall=%0d",
          pkt_beat_count, vif.cb_mon.TDATA, vif.cb_mon.TKEEP,
          vif.cb_mon.TLAST, vif.cb_mon.TID, tready_stall_depth), UVM_HIGH)

        // Packet boundary
        if (vif.cb_mon.TLAST === 1'b1) begin
          pkt_count++;
          pkt_back_to_back = !prev_tlast;

          // Null packet check (all TKEEP=0)
          if (vif.cb_mon.TKEEP === {(AXI_STRB_W){1'b0}}) begin
            null_count++;
            null_pkt_ctx = (prev_pkt_was_null) ? 3 : (pkt_beat_count == 1 ? 0 : 1);
            prev_pkt_was_null = 1;
          end else begin
            null_pkt_ctx = (prev_pkt_was_null) ? 2 : 0;
            prev_pkt_was_null = 0;
          end

          cg_packet_boundary.sample();
          cg_continuous_packets.sample();
          cg_twakeup_timing.sample();
          cg_reset_scenarios.sample();
          cg_negative_violations.sample();
          cg_data_bus_width.sample();

          if (cfg.enable_tracker)
            $fwrite(tracker_fd, "PKT#%0d: beats=%0d null=%0b TID=0x%0h TDEST=0x%0h stall_max=%0d\n",
                    pkt_count, pkt_beat_count,
                    (vif.cb_mon.TKEEP === {(AXI_STRB_W){1'b0}}),
                    vif.cb_mon.TID, vif.cb_mon.TDEST, tready_stall_depth);

          `uvm_info("MON", $sformatf(
            "[MON] PKT#%0d COMPLETE | beats=%0d null_term=%0b TID=0x%0h B2B=%0b",
            pkt_count, pkt_beat_count,
            (vif.cb_mon.TKEEP === {(AXI_STRB_W){1'b0}}),
            vif.cb_mon.TID, pkt_back_to_back), UVM_MEDIUM)

          pkt_beat_count  = 0;
          prev_tlast      = 1;
          continuous_pkt_viol = 0;
        end else begin
          prev_tlast = 0;
        end

        // Reset per-beat tracking
        snap_valid         = 0;
        tready_stall_depth = 0;
        stall_beat_position = (pkt_beat_count == 0) ? 0 : (vif.cb_mon.TLAST ? 2 : 1);
        twakeup_seen       = 0;

      end else if (vif.cb_mon.TVALID !== 1'b1 && prev_tvalid === 1'b1) begin
        // TVALID dropped. Only flag if there's an un-handshaked snapshot AND
        // it was NOT a TLAST beat (which legitimately deasserts TVALID).
        if (snap_valid && snap_tlast !== 1'b1) begin
          `uvm_fatal("MON_STAB",
            "TVALID_RETRACTION_VIOLATION: TVALID deasserted before TREADY was seen!")
        end
        snap_valid = 0;
      end

      prev_tvalid = vif.cb_mon.TVALID;
    end  // forever
  endtask

  function void final_phase(uvm_phase phase);
    `uvm_info("MON", $sformatf(
      "[MON] FINAL: total_beats=%0d pkts=%0d null_pkts=%0d parity_errs=%0d",
      total_beats, pkt_count, null_count, parity_error_count), UVM_NONE)
    if (cfg.enable_tracker) $fclose(tracker_fd);
  endfunction

endclass
