// =============================================================================
// AXI5-Stream Master VIP — Driver
// Drives the Transmitter side. NEVER drives TREADY or TREADYCHK: those are
// DUT-owned inputs that this VIP only observes (role-safety rule).
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_DRIVER_SV
`define AXI_STREAM_MASTER_VIP_DRIVER_SV

class axi_stream_master_vip_driver extends uvm_driver #(axi_stream_master_vip_seq_item);
  `uvm_component_utils(axi_stream_master_vip_driver)
  `uvm_register_cb(axi_stream_master_vip_driver, axi_stream_master_vip_callback)

  axi_stream_master_vip_agent_config cfg;

  protected virtual axi_stream_master_vip_if #(
    .DATA_W(`AXI_DATA_W), .ID_W(`AXI_ID_W), .DEST_W(`AXI_DEST_W),
    .USER_W(`AXI_USER_W), .HAS_PAR(`AXI_HAS_PAR), .HAS_WAKE(`AXI_HAS_WAKE)
  ) vif;

  protected int unsigned pkt_count;
  protected bit          in_reset;

  // ── Protocol tracker (uvc_generator SKILL §2) ─────────────────────────────
  // Separate instance from the monitor's: this records what the VIP DROVE,
  // the monitor records what was OBSERVED on the wire. Comparing the two files
  // is how you localise a driver bug versus a sampling bug.
  uvm_tracker trk;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(axi_stream_master_vip_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("DRV/NOCFG", "agent_config not found in ConfigDB")
    if (cfg.vif == null)
      `uvm_fatal("DRV/NOVIF", "agent_config.vif is null")
    vif = cfg.vif;
    trk = uvm_tracker::type_id::create("trk");
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    if (cfg.enable_tracker) begin
      // Driver tracker layout (SKILL: "Driver Tracker Layout")
      trk.add_column("TIME",    14, "%t");
      trk.add_column("PKT",      6, "%0d");
      trk.add_column("BEAT",     8, "%s");
      trk.add_column("TDATA",   `TRK_COLW(`AXI_DATA_W), "%0h");
      trk.add_column("KEEP",    `TRK_COLW(`AXI_STRB_W), "%0b");
      trk.add_column("STRB",    `TRK_COLW(`AXI_STRB_W), "%0b");
      trk.add_column("LAST",     5, "%0b");
      trk.add_column("TID",     `TRK_COLW(`AXI_ID_W),   "%0h");
      trk.add_column("DEST",    `TRK_COLW(`AXI_DEST_W), "%0h");
      trk.add_column("DATACHK", `TRK_COLW(`AXI_STRB_W), "%0b");
      trk.add_column("STALL",    6, "%0d");
      trk.add_column("WAKE",     5, "%0b");
      trk.add_column("INJECT",  10, "%s");
      trk.add_column("RESULT",  10, "%s");
      trk.open(get_full_name());
    end
  endfunction

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    if (cfg.enable_tracker) trk.close();
  endfunction

  // One row per driven beat, and one at handshake completion / abort.
  protected function void trk_row(axi_stream_master_vip_seq_item item,
                                  int i, string beat_s,
                                  logic [`AXI_DATA_W-1:0] d,
                                  logic [`AXI_STRB_W-1:0] k,
                                  logic [`AXI_STRB_W-1:0] st,
                                  logic                   last_b,
                                  logic [`AXI_STRB_W-1:0] chk,
                                  int unsigned stall, string result);
    string vals[$];
    string inj;
    if (!cfg.enable_tracker) return;

    inj = "-";
    if (item.inject_tvalid_drop)    inj = "VDROP";
    if (item.inject_parity_fault)   inj = "PARITY";
    if (item.inject_reserved_qual)  inj = "RESVD";
    if (item.inject_payload_mutate) inj = "MUTATE";

    vals.push_back($sformatf("%0t", $time));
    vals.push_back($sformatf("%0d", pkt_count));
    vals.push_back(beat_s);
    vals.push_back($sformatf("%0h", d));
    vals.push_back($sformatf("%0b", k));
    vals.push_back($sformatf("%0b", st));
    vals.push_back($sformatf("%0b", last_b));
    vals.push_back($sformatf("%0h", item.id));
    vals.push_back($sformatf("%0h", item.dest));
    vals.push_back($sformatf("%0b", chk));
    vals.push_back($sformatf("%0d", stall));
    vals.push_back($sformatf("%0b", cfg.has_twakeup));
    vals.push_back(inj);
    vals.push_back(result);
    trk.write_row(vals);
  endfunction

  // ── Odd parity (Section 5.3, Page 46) ─────────────────────────────────────
  // Odd parity: the number of asserted bits across signal+check is always odd.
  // For an 8-bit lane, ^lane is 1 when the lane has an odd count, so the check
  // bit is its inversion.
  protected function logic odd_parity_byte(logic [7:0] b);
    return ~(^b);
  endfunction

  // Parity is computed over ALL byte lanes, including lanes whose TKEEP is 0.
  // Section 5.5, Page 48: "all bits of TDATACHK must be driven correctly, even
  // if some bytes are not data bytes." Qualifier-conditional parity is a bug.
  protected function logic [`AXI_STRB_W-1:0] tdatachk_of(logic [`AXI_DATA_W-1:0] d);
    logic [`AXI_STRB_W-1:0] chk;
    for (int b = 0; b < `AXI_STRB_W; b++)
      chk[b] = odd_parity_byte(d[8*b +: 8]);
    return chk;
  endfunction

  protected task drive_idle();
    vif.cb_drv.TVALID     <= 1'b0;
    vif.cb_drv.TLAST      <= 1'b0;
    vif.cb_drv.TDATA      <= '0;
    vif.cb_drv.TKEEP      <= '0;
    vif.cb_drv.TSTRB      <= '0;
    vif.cb_drv.TID        <= '0;
    vif.cb_drv.TDEST      <= '0;
    vif.cb_drv.TUSER      <= '0;
    vif.cb_drv.TVALIDCHK  <= ~1'b0;   // parity of TVALID=0
    vif.cb_drv.TLASTCHK   <= ~1'b0;
    vif.cb_drv.TDATACHK   <= tdatachk_of('0);
  endtask

  // ── Reset handling (REQ_MST_05, Section 2.8.2 Page 28) ────────────────────
  // TVALID must be LOW on every cycle ARESETn is LOW. This process runs in
  // parallel with the drive loop and has priority over it: reset is
  // unconditional, and any in-flight beat is abandoned rather than completed.
  protected task reset_handler();
    forever begin
      // Wait for reset to be ASSERTED — but only if it is not already asserted.
      // At time 0 ARESETn is already LOW, and a bare @(negedge) would block
      // forever waiting for a falling edge that never comes, leaving in_reset
      // stuck at 1 and the drive loop parked on wait(!in_reset).
      if (vif.ARESETn !== 1'b0)
        @(negedge vif.ARESETn);

      in_reset = 1'b1;
      vif.cb_drv.TVALID  <= 1'b0;
      vif.cb_drv.TWAKEUP <= 1'b0;
      `uvm_info("DRV/RESET", "ARESETn asserted — TVALID forced LOW, in-flight beat abandoned",
                UVM_LOW)

      @(posedge vif.ARESETn);
      // REQ_MST_06 (Section 2.8.2): TVALID may only rise on an ACLK edge
      // FOLLOWING the edge at which ARESETn is sampled HIGH — the mandatory
      // one-cycle quiescent gap.
      @(vif.cb_drv);
      in_reset = 1'b0;
      `uvm_info("DRV/RESET", "ARESETn deasserted — quiescent gap observed, driver armed",
                UVM_LOW)
    end
  endtask

  task run_phase(uvm_phase phase);
    in_reset = !vif.ARESETn;
    drive_idle();
    vif.cb_drv.TWAKEUP    <= 1'b0;
    vif.cb_drv.TWAKEUPCHK <= ~1'b0;

    fork
      reset_handler();
      drive_loop();
    join_none

    wait fork;
  endtask

  protected task drive_loop();
    forever begin
      // Never start driving while reset is active or the quiescent gap is pending.
      wait (!in_reset);

      // Logged BEFORE the blocking call, per coding_guideline rule 5. If the
      // driver stalls inside get_next_item awaiting a sequence, the trace shows
      // it entered — an after-the-call log would print nothing and the hang
      // would be invisible.
      `uvm_info("DRV_FLOW", "[HS] step=CALLING get_next_item", UVM_DEBUG)
      seq_item_port.get_next_item(req);
      `uvm_info("DRV_FLOW", "[HS] step=ITEM_RECEIVED from sequencer", UVM_DEBUG)

      `uvm_info("DRV_FLOW", "[HS] step=CALLING pre_drive callbacks", UVM_DEBUG)
      `uvm_do_callbacks(axi_stream_master_vip_driver, axi_stream_master_vip_callback,
                        pre_drive(this, req))

      drive_packet(req);

      `uvm_info("DRV_FLOW", "[HS] step=CALLING post_drive callbacks", UVM_DEBUG)
      `uvm_do_callbacks(axi_stream_master_vip_driver, axi_stream_master_vip_callback,
                        post_drive(this, req))

      `uvm_info("DRV_FLOW", "[HS] step=CALLING item_done", UVM_DEBUG)
      seq_item_port.item_done();
      `uvm_info("DRV_FLOW", "[HS] step=ITEM_DONE returned to sequencer", UVM_DEBUG)
    end
  endtask

  protected task drive_packet(axi_stream_master_vip_seq_item item);
    pkt_count++;
    // Packet header + full payload data: UVM_FULL (coding_guideline 1b).
    `uvm_info("DRV", $sformatf(
      "[START PACKET %0d]\n  beats  : %0d\n  TID    : 0x%0h\n  TDEST  : 0x%0h\n  TUSER  : 0x%0h\n  data_bytes: %0d\n  wake_lead: %0d\n  knobs  : drop=%0b parity=%0b resvd=%0b mutate=%0b",
      pkt_count, item.packet_beats, item.id, item.dest, item.user, item.data_byte_count(),
      item.wakeup_lead_cycles,
      item.inject_tvalid_drop, item.inject_parity_fault,
      item.inject_reserved_qual, item.inject_payload_mutate), UVM_FULL)

    // ── TWAKEUP lead (REQ_MST_12, Section 2.3 Page 20) ───────────────────────
    // TWAKEUP is asserted at least one cycle PRIOR to TVALID. A Receiver is
    // permitted to wait for TWAKEUP before asserting TREADY, so asserting
    // TVALID without a leading TWAKEUP risks permanent deadlock.
    if (cfg.has_twakeup) begin
      vif.cb_drv.TWAKEUP    <= 1'b1;
      vif.cb_drv.TWAKEUPCHK <= ~1'b1;
      `uvm_info(get_type_name(), $sformatf(
        "[HS] step=TWAKEUP_ASSERTED lead=%0d cycles before TVALID", item.wakeup_lead_cycles),
        UVM_DEBUG)
      repeat (item.wakeup_lead_cycles) @(vif.cb_drv);
    end

    foreach (item.data[i]) begin
      drive_beat(item, i);
      if (in_reset) begin
        `uvm_info("DRV", $sformatf("[ABORT PACKET %0d] reset during beat %0d", pkt_count, i),
                  UVM_MEDIUM)
        return;
      end
    end

    drive_idle();

    // TWAKEUP deasserted once no further transfers are required.
    if (cfg.has_twakeup) begin
      vif.cb_drv.TWAKEUP    <= 1'b0;
      vif.cb_drv.TWAKEUPCHK <= ~1'b0;
    end

    `uvm_info("DRV", $sformatf("[END PACKET %0d] %0d beats accepted", pkt_count,
                               item.packet_beats), UVM_FULL)
  endtask

  protected task drive_beat(axi_stream_master_vip_seq_item item, int i);
    logic [`AXI_DATA_W-1:0] beat_data;
    logic [`AXI_STRB_W-1:0] beat_keep, beat_strb, beat_chk;
    logic                   beat_last;
    int unsigned            stall;

    beat_data = item.data[i];
    beat_keep = item.keep[i];
    beat_strb = item.strb[i];
    beat_last = (i == item.packet_beats - 1);

    // TC_MST_039: reserved qualifier encoding TKEEP=0 with TSTRB=1.
    if (item.inject_reserved_qual) begin
      beat_keep[0] = 1'b0;
      beat_strb[0] = 1'b1;
    end

    // Inter-beat idle gap (TVALID LOW) before presenting this beat.
    if (item.inter_beat_delay[i] > 0) begin
      vif.cb_drv.TVALID    <= 1'b0;
      vif.cb_drv.TVALIDCHK <= ~1'b0;
      repeat (item.inter_beat_delay[i]) @(vif.cb_drv);
      if (in_reset) return;
    end

    beat_chk = tdatachk_of(beat_data);
    // TC_MST_048: flip a single TDATACHK bit to break the odd-parity invariant.
    if (item.inject_parity_fault) beat_chk[0] = ~beat_chk[0];

    // Present the beat and assert TVALID.
    vif.cb_drv.TDATA     <= beat_data;
    vif.cb_drv.TKEEP     <= beat_keep;
    vif.cb_drv.TSTRB     <= beat_strb;
    vif.cb_drv.TLAST     <= beat_last;
    vif.cb_drv.TID       <= item.id;
    vif.cb_drv.TDEST     <= item.dest;
    vif.cb_drv.TUSER     <= item.user;
    if (cfg.has_parity) begin
      vif.cb_drv.TDATACHK  <= beat_chk;
      vif.cb_drv.TVALIDCHK <= ~1'b1;          // parity of TVALID=1
      vif.cb_drv.TLASTCHK  <= ~beat_last;
    end
    vif.cb_drv.TVALID <= 1'b1;

    // Beat data dump: UVM_FULL (coding_guideline 1b) — data payload mandatory.
    `uvm_info("DRV", $sformatf(
      "[BEAT %0d/%0d] TDATA=0x%08h TKEEP=0b%04b TSTRB=0b%04b TLAST=%0b TID=0x%0h TDEST=0x%0h TUSER=0x%0h TDATACHK=0b%04b",
      i + 1, item.packet_beats, beat_data, beat_keep, beat_strb, beat_last,
      item.id, item.dest, item.user, beat_chk), UVM_FULL)

    `uvm_info(get_type_name(), "[HS] step=PAYLOAD_PRESENTED, TVALID asserted", UVM_DEBUG)

    // Trigger 1 of 2: the beat as DRIVEN onto the pins (SKILL: "[BEAT n/m]").
    trk_row(item, i, $sformatf("%0d/%0d", i + 1, item.packet_beats),
            beat_data, beat_keep, beat_strb, beat_last, beat_chk, 0, "DRIVEN");

    @(vif.cb_drv);
    if (in_reset) return;

    // ── Wait for TREADY, holding payload frozen (REQ_MST_02, REQ_MST_03) ────
    stall = 0;
    while (vif.cb_drv.TREADY !== 1'b1) begin

      // TC_MST_006: retract TVALID mid-stall without waiting for TREADY.
      // Illegal by construction — exercises the monitor's stability checker.
      if (item.inject_tvalid_drop && stall >= 2) begin
        `uvm_info("DRV/NEG", "inject_tvalid_drop: retracting TVALID before TREADY (ILLEGAL)",
                  UVM_MEDIUM)
        vif.cb_drv.TVALID    <= 1'b0;
        vif.cb_drv.TVALIDCHK <= ~1'b0;
        @(vif.cb_drv);
        return;
      end

      // TC_MST_010: mutate the payload while the handshake is outstanding.
      // Illegal by construction — exercises the payload-stability checker.
      if (item.inject_payload_mutate && stall == 1) begin
        `uvm_info("DRV/NEG", "inject_payload_mutate: changing TDATA/TKEEP mid-stall (ILLEGAL)",
                  UVM_MEDIUM)
        vif.cb_drv.TDATA <= ~beat_data;
        vif.cb_drv.TKEEP <= ~beat_keep;
      end

      // Otherwise the payload is NOT re-driven here: it stays frozen at the
      // values latched above, which is exactly what REQ_MST_03 requires.

      @(vif.cb_drv);
      if (in_reset) return;

      stall++;
      if (stall > cfg.watchdog_cycles) begin
        `uvm_error("DRV/WATCHDOG", $sformatf(
          "TREADY not observed within %0d cycles — DUT deadlock. Packet %0d beat %0d.",
          cfg.watchdog_cycles, pkt_count, i))
        trk_row(item, i, $sformatf("%0d/%0d", i + 1, item.packet_beats),
                beat_data, beat_keep, beat_strb, beat_last, beat_chk, stall, "ABORTED");
        vif.cb_drv.TVALID <= 1'b0;
        return;
      end

      // Per-cycle handshake step trace: UVM_DEBUG (coding_guideline 1c).
      // Every stall cycle is traced — this is exactly the "each step of the
      // handshake" the level exists for, so it is NOT sampled or throttled.
      `uvm_info(get_type_name(), $sformatf(
        "[HS] step=WAIT_READY stall_cycle=%0d TVALID=1 TREADY=%0b (pkt %0d beat %0d)",
        stall, vif.cb_drv.TREADY, pkt_count, i + 1), UVM_DEBUG)
    end

    `uvm_info(get_type_name(), $sformatf(
      "[HS] step=HANDSHAKE_COMPLETE after %0d stall cycle(s)", stall), UVM_DEBUG)

    `uvm_info("DRV", $sformatf(
      "[BEAT %0d/%0d ACCEPTED] TDATA=0x%08h TKEEP=0b%04b TSTRB=0b%04b TLAST=%0b TDATACHK=0b%04b stall=%0d",
      i + 1, item.packet_beats, beat_data, beat_keep, beat_strb, beat_last, beat_chk, stall),
      UVM_FULL)

    trk_row(item, i, $sformatf("%0d/%0d", i + 1, item.packet_beats),
            beat_data, beat_keep, beat_strb, beat_last, beat_chk, stall, "ACCEPTED");

    vif.cb_drv.TVALID <= 1'b0;
  endtask

endclass

`endif
