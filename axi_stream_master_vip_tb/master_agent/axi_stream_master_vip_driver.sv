// AXI-Stream Master VIP Driver
// Drives TVALID, TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER, TWAKEUP.
// Drives all AXI5 parity check signals (TVALIDCHK, TDATACHK, TLASTCHK, TWAKEUPCHK).
// Holds all output signals stable from TVALID assertion until handshake completes.
class axi_stream_master_vip_driver extends uvm_driver #(axi_stream_master_vip_seq_item);
  `uvm_component_utils(axi_stream_master_vip_driver)

  virtual axi_stream_master_vip_if vif;
  axi_stream_master_vip_agent_config cfg;

  int packet_count = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual axi_stream_master_vip_if)::get(this, "", "vif", vif))
      `uvm_fatal("CFG", "No VIF for axi_stream_master_vip_driver")
    if (!uvm_config_db #(axi_stream_master_vip_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("CFG", "No CFG for axi_stream_master_vip_driver")
  endfunction

  // ── Odd parity computation helpers ────────────────────────────────────────────
  function automatic logic compute_valid_chk(logic v);
    return ~v;  // odd parity of 1-bit signal
  endfunction

  function automatic logic compute_last_chk(logic l);
    return ~l;
  endfunction

  function automatic logic compute_wakeup_chk(logic w);
    return ~w;
  endfunction

  function automatic logic [`TSTRB_WIDTH-1:0] compute_datachk(logic [`TDATA_WIDTH-1:0] d);
    logic [`TSTRB_WIDTH-1:0] chk;
    for (int i = 0; i < `TSTRB_WIDTH; i++)
      chk[i] = ~^d[8*i +: 8];  // ~(XOR reduction) = odd parity per byte
    return chk;
  endfunction

  // ── Drive all parity signals for current cycle ────────────────────────────────
  task drive_parity(
    logic tvalid_val,
    logic [`TDATA_WIDTH-1:0] tdata_val,
    logic tlast_val,
    logic twakeup_val,
    bit inject_err, int err_byte_idx
  );
    logic [`TSTRB_WIDTH-1:0] dchk;
    dchk = compute_datachk(tdata_val);
    if (inject_err && err_byte_idx < `TSTRB_WIDTH)
      dchk[err_byte_idx] = ~dchk[err_byte_idx];  // flip one parity bit

    vif.cb_drv.TVALIDCHK  <= compute_valid_chk(tvalid_val);
    vif.cb_drv.TDATACHK   <= dchk;
    vif.cb_drv.TLASTCHK   <= compute_last_chk(tlast_val);
    vif.cb_drv.TWAKEUPCHK <= compute_wakeup_chk(twakeup_val);
  endtask

  // ── TWAKEUP management ────────────────────────────────────────────────────────
  task assert_twakeup_before_tvalid();
    if (cfg.has_twakeup) begin
      vif.cb_drv.TWAKEUP <= 1'b1;
      if (cfg.has_parity)
        vif.cb_drv.TWAKEUPCHK <= compute_wakeup_chk(1'b1);
      @(vif.cb_drv);  // at least 1 cycle lead before TVALID
    end
  endtask

  task deassert_twakeup();
    if (cfg.has_twakeup) begin
      vif.cb_drv.TWAKEUP    <= 1'b0;
      vif.cb_drv.TWAKEUPCHK <= compute_wakeup_chk(1'b0);
    end
  endtask

  // ── Reset handling: idle output during reset ──────────────────────────────────
  task wait_for_reset_done();
    vif.cb_drv.TVALID    <= 1'b0;
    vif.cb_drv.TDATA     <= '0;
    vif.cb_drv.TSTRB     <= '0;
    vif.cb_drv.TKEEP     <= '0;
    vif.cb_drv.TLAST     <= 1'b0;
    vif.cb_drv.TID       <= '0;
    vif.cb_drv.TDEST     <= '0;
    vif.cb_drv.TUSER     <= '0;
    vif.cb_drv.TWAKEUP   <= 1'b0;
    vif.cb_drv.TVALIDCHK <= 1'b1;  // odd parity of TVALID=0 → ~0=1
    vif.cb_drv.TDATACHK  <= '1;
    vif.cb_drv.TLASTCHK  <= 1'b1;
    vif.cb_drv.TWAKEUPCHK<= 1'b1;
    @(posedge vif.ARESETn);
    @(vif.cb_drv);  // wait one cycle after ARESETn goes high (spec: TVALID cannot go HIGH same cycle as ARESETn)
    `uvm_info("DRV", "[DRV] Reset complete — Master VIP ready to transmit", UVM_MEDIUM)
  endtask

  // ── Main run phase ─────────────────────────────────────────────────────────────
  task run_phase(uvm_phase phase);
    axi_stream_master_vip_seq_item req;
    wait_for_reset_done();

    forever begin
      seq_item_port.get_next_item(req);
      drive_packet(req);
      seq_item_port.item_done();
    end
  endtask

  // ── Drive a complete packet (all beats, TLAST on final beat) ─────────────────
  task drive_packet(axi_stream_master_vip_seq_item item);
    logic [`TDATA_WIDTH-1:0]  beat_tdata;
    logic [`TSTRB_WIDTH-1:0]  beat_tstrb, beat_tkeep;
    logic [`TID_WIDTH-1:0]    beat_tid;
    logic                     beat_tlast;
    logic                     current_twakeup = 1'b0;
    int   watchdog_cnt;

    packet_count++;
    `uvm_info("DRV", $sformatf(
      "[DRV] [PKT#%0d START] len=%0d TID=0x%0h TDEST=0x%0h",
      packet_count, item.packet_length, item.tid, item.tdest), UVM_MEDIUM)

    // TWAKEUP pre-assertion (recommended: at least 1 cycle before TVALID)
    assert_twakeup_before_tvalid();
    current_twakeup = 1'b1;

    for (int beat = 1; beat <= item.packet_length; beat++) begin
      beat_tlast = (beat == item.packet_length) ? 1'b1 : 1'b0;
      beat_tdata = $urandom();
      beat_tkeep = item.tkeep;
      beat_tstrb = item.tstrb;
      beat_tid   = item.tid;

      // TC_MST_029 - Change TID mid-packet (violation knob)
      if (item.change_tid_mid_packet && beat == 2 && item.packet_length > 2)
        beat_tid = item.tid ^ 8'hFF;

      // TC_MST_024 - Inject invalid TSTRB/TKEEP (reserved combination)
      if (item.inject_invalid_tstrb_tkeep && beat == 1) begin
        beat_tstrb[0] = 1'b1;
        beat_tkeep[0] = 1'b0;  // TSTRB=1, TKEEP=0 — reserved/illegal
      end

      // Advance clock, then assert TVALID with all beat signals.
      // The previous beat's handshake already deasserted TVALID at this same
      // clock edge (without waiting), so monitor sees a clean TVALID=0 cycle
      // between beats before we re-assert here.
      @(vif.cb_drv);
      vif.cb_drv.TVALID <= 1'b1;
      vif.cb_drv.TDATA  <= beat_tdata;
      vif.cb_drv.TSTRB  <= beat_tstrb;
      vif.cb_drv.TKEEP  <= beat_tkeep;
      vif.cb_drv.TLAST  <= beat_tlast;
      vif.cb_drv.TID    <= beat_tid;
      vif.cb_drv.TDEST  <= item.tdest;
      vif.cb_drv.TUSER  <= item.tuser;
      vif.cb_drv.TWAKEUP<= current_twakeup;

      if (cfg.has_parity)
        drive_parity(1'b1, beat_tdata, beat_tlast, current_twakeup,
                     item.parity_inject_error && beat == 8,
                     item.parity_error_byte_idx);

      `uvm_info("DRV", $sformatf(
        "[DRV] [PKT#%0d BEAT#%0d/%0d] TDATA=0x%08h TKEEP=0b%04b TLAST=%0b TID=0x%0h",
        packet_count, beat, item.packet_length, beat_tdata, beat_tkeep, beat_tlast, beat_tid),
        UVM_HIGH)

      // TC_MST_004 - Drop TVALID early before handshake (violation)
      if (item.drop_valid_early && beat == 3) begin
        `uvm_info("DRV", "[DRV] VIOLATION: Dropping TVALID before handshake (TC_MST_004)", UVM_LOW)
        vif.cb_drv.TVALID <= 1'b0;
        if (cfg.has_parity)
          drive_parity(1'b0, beat_tdata, beat_tlast, current_twakeup, 0, 0);
        @(vif.cb_drv);  // consume the deassert cycle
        break;
      end

      // Hold all signals stable until TREADY handshake.
      // TREADY is read from the clocking block's input (sampled at posedge).
      watchdog_cnt = 0;
      while (vif.cb_drv.TREADY !== 1'b1) begin
        @(vif.cb_drv);
        watchdog_cnt++;
        // Re-drive identical values to guarantee stability during stall
        vif.cb_drv.TVALID <= 1'b1;
        vif.cb_drv.TDATA  <= beat_tdata;
        vif.cb_drv.TSTRB  <= beat_tstrb;
        vif.cb_drv.TKEEP  <= beat_tkeep;
        vif.cb_drv.TLAST  <= beat_tlast;
        vif.cb_drv.TID    <= beat_tid;
        vif.cb_drv.TDEST  <= item.tdest;
        vif.cb_drv.TUSER  <= item.tuser;
        vif.cb_drv.TWAKEUP<= current_twakeup;
        if (cfg.has_parity)
          drive_parity(1'b1, beat_tdata, beat_tlast, current_twakeup, 0, 0);
        if (watchdog_cnt > cfg.tready_watchdog_cycles)
          `uvm_fatal("DRV", $sformatf(
            "[DRV] WATCHDOG: TREADY never asserted for beat %0d of PKT#%0d",
            beat, packet_count))
      end

      `uvm_info("DRV", $sformatf(
        "[DRV] [PKT#%0d BEAT#%0d] HANDSHAKE COMPLETE (stall=%0d cycles)",
        packet_count, beat, watchdog_cnt), UVM_HIGH)

      // IMMEDIATELY deassert TVALID after handshake — NO preceding @(cb_drv).
      // The CB output skew places this deassert at posedge+1step, so the monitor
      // sees TVALID=0 at the very next clock edge, preventing a false stall snapshot
      // on inter-beat or inter-packet transitions.
      vif.cb_drv.TVALID <= 1'b0;
      if (cfg.has_parity)
        drive_parity(1'b0, '0, 1'b0, current_twakeup, 0, 0);
    end

    // TVALID already deasserted inside the loop after the last beat's handshake.
    // Just advance one clock so the deassert is observed, then handle TWAKEUP.
    @(vif.cb_drv);
    deassert_twakeup();

    `uvm_info("DRV", $sformatf(
      "[DRV] [PKT#%0d END] All %0d beats transmitted", packet_count, item.packet_length),
      UVM_MEDIUM)
  endtask

endclass
