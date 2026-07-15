// =============================================================================
// AXI5-Stream Slave VIP — Driver
// Drives ONLY TREADY and TREADYCHK (role-safety). Realizes the back-pressure
// profile in the seq_item; OBSERVES TVALID/payload to know when a beat is
// accepted. NEVER drives any Transmitter-owned signal.
// =============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_DRIVER_SV
`define AXI_STREAM_SLAVE_VIP_DRIVER_SV

class axi_stream_slave_vip_driver extends uvm_driver #(axi_stream_slave_vip_seq_item);
  `uvm_component_utils(axi_stream_slave_vip_driver)
  `uvm_register_cb(axi_stream_slave_vip_driver, axi_stream_slave_vip_callback)

  axi_stream_slave_vip_agent_config cfg;

  protected virtual axi_stream_slave_vip_if #(
    .DATA_W(`AXI_DATA_W), .ID_W(`AXI_ID_W), .DEST_W(`AXI_DEST_W),
    .USER_W(`AXI_USER_W), .HAS_PAR(`AXI_HAS_PAR), .HAS_WAKE(`AXI_HAS_WAKE)
  ) vif;

  // Driver tracker (SKILL §289: one tracker per driver, under the agent folder).
  uvm_tracker trk;

  protected int unsigned accept_count;
  protected bit          in_reset;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(axi_stream_slave_vip_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("DRV/NOCFG", "agent_config not found in ConfigDB")
    if (cfg.vif == null) `uvm_fatal("DRV/NOVIF", "agent_config.vif is null")
    vif = cfg.vif;
    trk = uvm_tracker::type_id::create("trk");
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    if (cfg.enable_tracker) begin
      trk.add_column("TIME",    14, "%t");
      trk.add_column("BEAT",     8, "%s");
      trk.add_column("TDATA",   `TRK_COLW(`AXI_DATA_W), "%0h");
      trk.add_column("KEEP",    `TRK_COLW(`AXI_STRB_W), "%0b");
      trk.add_column("LAST",     5, "%0b");
      trk.add_column("TID",     `TRK_COLW(`AXI_ID_W),   "%0h");
      trk.add_column("STALL",    6, "%0d");
      trk.add_column("WAKE",     5, "%0b");
      trk.add_column("INJECT",  10, "%s");
      trk.add_column("RESULT",  10, "%s");
      trk.open(get_full_name(), cfg.tracker_dir);
    end
  endfunction

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    if (cfg.enable_tracker) trk.close();
  endfunction

  protected function void trk_row(int unsigned beat, string result,
                                  int unsigned stall, string inj);
    string vals[$];
    if (!cfg.enable_tracker) return;
    vals.push_back($sformatf("%0t", $time));
    vals.push_back($sformatf("%0d", beat));
    vals.push_back($sformatf("%0h", vif.cb_drv.TDATA));
    vals.push_back($sformatf("%0b", vif.cb_drv.TKEEP));
    vals.push_back($sformatf("%0b", vif.cb_drv.TLAST));
    vals.push_back($sformatf("%0h", vif.cb_drv.TID));
    vals.push_back($sformatf("%0d", stall));
    vals.push_back($sformatf("%0b", vif.cb_drv.TWAKEUP));
    vals.push_back(inj);
    vals.push_back(result);
    trk.write_row(vals);
  endfunction

  // TREADYCHK is odd parity over the single-bit TREADY: the inversion.
  protected function logic readychk_of(logic tready, bit fault);
    return fault ? tready : ~tready;   // fault => wrong polarity
  endfunction

  protected task drive_ready(logic v, bit fault = 0);
    vif.cb_drv.TREADY    <= v;
    vif.cb_drv.TREADYCHK <= readychk_of(v, fault);
  endtask

  // ── Reset handling (REQ_SLV_06) ───────────────────────────────────────────
  protected task reset_handler();
    forever begin
      if (vif.ARESETn !== 1'b0) @(negedge vif.ARESETn);
      in_reset = 1'b1;
      drive_ready(1'b0);   // defined level during reset
      `uvm_info("DRV/RESET", "ARESETn asserted — TREADY driven LOW", UVM_LOW)
      @(posedge vif.ARESETn);
      @(vif.cb_drv);
      in_reset = 1'b0;
      `uvm_info("DRV/RESET", "ARESETn deasserted — driver armed", UVM_LOW)
    end
  endtask

  task run_phase(uvm_phase phase);
    in_reset = !vif.ARESETn;
    drive_ready(1'b0);
    fork
      reset_handler();
      drive_loop();
    join_none
    wait fork;
  endtask

  protected task drive_loop();
    forever begin
      wait (!in_reset);
      `uvm_info("DRV_FLOW", "[HS] step=CALLING get_next_item", UVM_DEBUG)
      seq_item_port.get_next_item(req);
      `uvm_info("DRV_FLOW", "[HS] step=ITEM_RECEIVED", UVM_DEBUG)

      `uvm_do_callbacks(axi_stream_slave_vip_driver, axi_stream_slave_vip_callback,
                        pre_drive(this, req))
      apply_profile(req);
      `uvm_do_callbacks(axi_stream_slave_vip_driver, axi_stream_slave_vip_callback,
                        post_drive(this, req))

      `uvm_info("DRV_FLOW", "[HS] step=CALLING item_done", UVM_DEBUG)
      seq_item_port.item_done();
    end
  endtask

  // Realize the back-pressure profile over num_beats_to_accept accepted beats.
  protected task apply_profile(axi_stream_slave_vip_seq_item item);
    `uvm_info("DRV", $sformatf(
      "[START PROFILE] mode=%s beats=%0d period=%0d fault=%0b",
      item.mode.name(), item.num_beats_to_accept, item.period, item.inject_readychk_fault),
      UVM_FULL)

    for (int b = 0; b < item.num_beats_to_accept; b++) begin
      accept_one_beat(item, b);
      if (in_reset) begin
        `uvm_info("DRV", $sformatf("[ABORT PROFILE] reset during beat %0d", b), UVM_FULL)
        return;
      end
    end
    drive_ready(1'b0);
    `uvm_info("DRV", "[END PROFILE]", UVM_FULL)
  endtask

  protected task accept_one_beat(axi_stream_slave_vip_seq_item item, int b);
    int unsigned stall = 0;
    int unsigned pre_delay = (b < item.ready_delay.size()) ? item.ready_delay[b] : 0;

    // ── Pre-accept back-pressure: hold TREADY low for the profile's delay ────
    case (item.mode)
      READY_CONTINUOUS:   pre_delay = 0;
      READY_SINGLE_PULSE: pre_delay = (pre_delay == 0) ? 1 : pre_delay;
      default: ; // PERIODIC/SPARSE/WAKEUP_GATED use ready_delay[b] as-is
    endcase

    repeat (pre_delay) begin
      drive_ready(1'b0);
      @(vif.cb_drv);
      if (in_reset) return;
    end

    // ── Wakeup-gated: withhold TREADY until observed TWAKEUP (REQ_SLV_12) ────
    if (item.mode == READY_WAKEUP_GATED || cfg.wakeup_gated_ready) begin
      while (vif.cb_drv.TWAKEUP !== 1'b1) begin
        drive_ready(1'b0);
        @(vif.cb_drv);
        if (in_reset) return;
      end
    end

    // ── Assert TREADY and wait for the DUT's TVALID (watchdog-guarded) ───────
    drive_ready(1'b1, item.inject_readychk_fault);
    `uvm_info("DRV_FLOW", "[HS] step=TREADY_ASSERTED, awaiting TVALID", UVM_DEBUG)

    @(vif.cb_drv);
    while (vif.cb_drv.TVALID !== 1'b1) begin
      if (in_reset) return;
      stall++;
      if (stall > cfg.tvalid_watchdog_cycles) begin
        `uvm_error("DRV/WATCHDOG", $sformatf(
          "TVALID not observed within %0d cycles — DUT (Master) stalled. Beat %0d.",
          cfg.tvalid_watchdog_cycles, b))
        trk_row(b + 1, "ABORTED", stall, item.inject_readychk_fault ? "RCHK" : "-");
        return;
      end
      `uvm_info("DRV_FLOW", $sformatf(
        "[HS] step=WAIT_VALID stall=%0d TREADY=1 TVALID=%0b", stall, vif.cb_drv.TVALID),
        UVM_DEBUG)
      @(vif.cb_drv);
    end

    // Beat accepted: TVALID && TREADY both HIGH on this edge.
    `uvm_info("DRV", $sformatf(
      "[BEAT %0d ACCEPTED] TDATA=0x%08h TKEEP=0b%04b TLAST=%0b TID=0x%0h stall=%0d",
      b + 1, vif.cb_drv.TDATA, vif.cb_drv.TKEEP, vif.cb_drv.TLAST, vif.cb_drv.TID, stall),
      UVM_FULL)
    trk_row(b + 1, "ACCEPTED", stall, item.inject_readychk_fault ? "RCHK" : "-");
    accept_count++;

    // Single-pulse: drop TREADY immediately after the accept.
    if (item.mode == READY_SINGLE_PULSE) drive_ready(1'b0);
  endtask

endclass

`endif
