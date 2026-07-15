// =============================================================================
// AXI5-Stream Master VIP — TB Top
// Role: MASTER VIP (Transmitter). DUT is the SLAVE (Receiver).
// =============================================================================
`timescale 1ns/1ps

`include "axi_stream_master_vip_defines.sv"

import axi_stream_master_vip_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module axi_stream_master_vip_tb_top;

  // ── Clock and reset ────────────────────────────────────────────────────────
  logic ACLK    = 1'b0;
  logic ARESETn = 1'b0;

  // Module-scope: a declaration-with-initializer inside an initial block is
  // implicitly static, which vlog rejects (vlog-2244).
  int unsigned rst_pulse_n;

  always #(`CLK_PERIOD_PS / 2.0) ACLK = ~ACLK;

  // Power-on reset, then service any mid-simulation reset requests from a test.
  // ARESETn is deasserted SYNCHRONOUSLY to the rising ACLK edge (Section 2.8.2).
  initial begin
    ARESETn = 1'b0;
    repeat (10) @(posedge ACLK);
    @(posedge ACLK);
    ARESETn = 1'b1;
    `uvm_info("TB_TOP", "ARESETn deasserted — VIP and DUT out of reset", UVM_LOW)

    forever begin
      @(posedge ACLK);
      if (axi_stream_master_vip_reset_ctl::pulse_cycles > 0) begin
        rst_pulse_n = axi_stream_master_vip_reset_ctl::pulse_cycles;
        axi_stream_master_vip_reset_ctl::pulse_cycles = 0;
        `uvm_info("TB_TOP", $sformatf("Mid-sim reset pulse: %0d cycles", rst_pulse_n), UVM_LOW)
        ARESETn = 1'b0;
        repeat (rst_pulse_n) @(posedge ACLK);
        @(posedge ACLK);
        ARESETn = 1'b1;
        `uvm_info("TB_TOP", "Mid-sim reset released", UVM_LOW)
      end
    end
  end

  // ── Interface instance ─────────────────────────────────────────────────────
  // The explicit #(...) binding is MANDATORY. A bare instantiation would take
  // the interface's own defaults, so a macro change in defines.sv would NOT
  // reach the signal widths — and defines.sv would stop being a source of truth.
  axi_stream_master_vip_if #(
    .DATA_W  (`AXI_DATA_W),
    .ID_W    (`AXI_ID_W),
    .DEST_W  (`AXI_DEST_W),
    .USER_W  (`AXI_USER_W),
    .HAS_PAR (`AXI_HAS_PAR),
    .HAS_WAKE(`AXI_HAS_WAKE)
  ) dut_if (
    .ACLK   (ACLK),
    .ARESETn(ARESETn)
  );

  // ── DUT: AXI-Stream Slave Receiver (the OPPOSITE role to the VIP) ─────────
  axi_stream_slave_dut_stub #(
    .DATA_W(`AXI_DATA_W),
    .ID_W  (`AXI_ID_W),
    .DEST_W(`AXI_DEST_W),
    .USER_W(`AXI_USER_W)
  ) dut (
    .ACLK      (ACLK),
    .ARESETn   (ARESETn),
    .TVALID    (dut_if.TVALID),
    .TDATA     (dut_if.TDATA),
    .TSTRB     (dut_if.TSTRB),
    .TKEEP     (dut_if.TKEEP),
    .TLAST     (dut_if.TLAST),
    .TID       (dut_if.TID),
    .TDEST     (dut_if.TDEST),
    .TUSER     (dut_if.TUSER),
    .TWAKEUP   (dut_if.TWAKEUP),
    .TVALIDCHK (dut_if.TVALIDCHK),
    .TDATACHK  (dut_if.TDATACHK),
    .TLASTCHK  (dut_if.TLASTCHK),
    .TWAKEUPCHK(dut_if.TWAKEUPCHK),
    .TREADY    (dut_if.TREADY),
    .TREADYCHK (dut_if.TREADYCHK)
  );

  // ── UVM launch ─────────────────────────────────────────────────────────────
  initial begin
    uvm_config_db #(virtual axi_stream_master_vip_if #(
      .DATA_W(`AXI_DATA_W), .ID_W(`AXI_ID_W), .DEST_W(`AXI_DEST_W),
      .USER_W(`AXI_USER_W), .HAS_PAR(`AXI_HAS_PAR), .HAS_WAKE(`AXI_HAS_WAKE)
    ))::set(null, "uvm_test_top", "vif", dut_if);

    // 100us in ps units (1ns/1ps timescale → precision is ps).
    uvm_top.set_timeout(100000000, 1);

    run_test();
  end

  // ── Waveform dump ──────────────────────────────────────────────────────────
  initial begin
    if ($test$plusargs("WAVES")) begin
      $wlfdumpvars(0, axi_stream_master_vip_tb_top);
    end
  end

endmodule

// =============================================================================
// AXI-Stream Slave DUT stub (Receiver)
// Randomized back-pressure. Drives TREADY and TREADYCHK; consumes everything
// else. Replace with the real DUT when available.
// =============================================================================
module axi_stream_slave_dut_stub #(
  parameter int DATA_W = 32,
  parameter int ID_W   = 8,
  parameter int DEST_W = 4,
  parameter int USER_W = 4
)(
  input  logic                ACLK,
  input  logic                ARESETn,
  input  logic                TVALID,
  input  logic [DATA_W-1:0]   TDATA,
  input  logic [DATA_W/8-1:0] TSTRB,
  input  logic [DATA_W/8-1:0] TKEEP,
  input  logic                TLAST,
  input  logic [ID_W-1:0]     TID,
  input  logic [DEST_W-1:0]   TDEST,
  input  logic [USER_W-1:0]   TUSER,
  input  logic                TWAKEUP,
  input  logic                TVALIDCHK,
  input  logic [DATA_W/8-1:0] TDATACHK,
  input  logic                TLASTCHK,
  input  logic                TWAKEUPCHK,
  output logic                TREADY,
  output logic                TREADYCHK
);

  int unsigned stall_cnt;
  logic        ready_reg;
  bit          no_backpressure;

  // +NO_BACKPRESSURE makes the Receiver permanently ready. Required by the
  // throughput test: beats-per-cycle conflates VIP pipeline bubbles with
  // DUT-imposed TREADY stalls, so a 1.0 target is only meaningful against a
  // receiver that never stalls.
  initial no_backpressure = $test$plusargs("NO_BACKPRESSURE");

  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      ready_reg <= 1'b0;
      stall_cnt <= 0;
    end
    else if (no_backpressure) begin
      ready_reg <= 1'b1;
      stall_cnt <= 0;
    end
    else if (stall_cnt > 0) begin
      stall_cnt <= stall_cnt - 1;
      ready_reg <= (stall_cnt == 1);   // re-assert on the last stall cycle
    end
    else begin
      ready_reg <= 1'b1;
      // On an accepted beat, pick a fresh random back-pressure interval.
      if (TVALID && ready_reg) begin
        stall_cnt <= $urandom_range(0, 100);
        if (stall_cnt > 0) ready_reg <= 1'b0;
      end
    end
  end

  assign TREADY    = ARESETn ? ready_reg : 1'b0;
  assign TREADYCHK = ~TREADY;   // single odd-parity bit = inversion (Section 5.3)

endmodule
