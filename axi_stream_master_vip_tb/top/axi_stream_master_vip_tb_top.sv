// AXI-Stream Master VIP TB Top
// Role: MASTER VIP (Transmitter) — DUT is SLAVE (Receiver)
// Instantiates the DUT stub (passive slave), generates clock/reset, sets up VIF.
`timescale 1ns/1ps
`include "axi_stream_master_vip_defines.sv"

import uvm_pkg::*;
`include "uvm_macros.svh"
import axi_stream_master_vip_pkg::*;

module axi_stream_master_vip_tb_top;

  // ── Clock and reset ────────────────────────────────────────────────────────────
  logic ACLK    = 1'b0;
  logic ARESETn = 1'b0;

  always #(`CLK_PERIOD/2) ACLK = ~ACLK;

  initial begin
    ARESETn = 1'b0;
    repeat(10) @(posedge ACLK);  // hold reset for 10 cycles
    @(posedge ACLK);
    ARESETn = 1'b1;
    `uvm_info("TB_TOP", "ARESETn deasserted — DUT and VIP out of reset", UVM_NONE)
  end

  // ── Interface instantiation ────────────────────────────────────────────────────
  axi_stream_master_vip_if dut_if(.ACLK(ACLK), .ARESETn(ARESETn));

  // ── DUT Slave stub (passive TREADY driver) ────────────────────────────────────
  // A minimal AXI-Stream Slave that randomly asserts TREADY and drives TREADYCHK.
  // Replace this module with the actual DUT under test.
  axi_stream_slave_dut_stub dut (
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

  // ── VIF registration ──────────────────────────────────────────────────────────
  initial begin
    uvm_config_db #(virtual axi_stream_master_vip_if)::set(
      null, "uvm_test_top", "vif", dut_if);
    run_test();
  end

  // ── UVM timeout ───────────────────────────────────────────────────────────────
  initial begin
    // 100µs timeout: 100000000 ps with 1ns/1ps timescale
    uvm_top.set_timeout(100000000, 1);
  end

  // ── Waveform dump ─────────────────────────────────────────────────────────────
  initial begin
    if ($test$plusargs("WAVES")) begin
      $shm_open("waves.shm");
      $shm_probe("AS");
    end
  end

endmodule

// ── AXI-Stream Slave DUT Stub ─────────────────────────────────────────────────
// Randomized back-pressure. Drives TREADY randomly, computes TREADYCHK = ~TREADY.
// Replace with actual silicon DUT when available.
module axi_stream_slave_dut_stub (
  input  logic                        ACLK,
  input  logic                        ARESETn,
  input  logic                        TVALID,
  input  logic [`TDATA_WIDTH-1:0]     TDATA,
  input  logic [`TSTRB_WIDTH-1:0]     TSTRB,
  input  logic [`TSTRB_WIDTH-1:0]     TKEEP,
  input  logic                        TLAST,
  input  logic [`TID_WIDTH-1:0]       TID,
  input  logic [`TDEST_WIDTH-1:0]     TDEST,
  input  logic [`TUSER_WIDTH-1:0]     TUSER,
  input  logic                        TWAKEUP,
  input  logic                        TVALIDCHK,
  input  logic [`TSTRB_WIDTH-1:0]     TDATACHK,
  input  logic                        TLASTCHK,
  input  logic                        TWAKEUPCHK,
  output logic                        TREADY,
  output logic                        TREADYCHK
);

  int stall_cnt  = 0;
  int stall_max  = 0;
  bit ready_reg  = 1'b0;

  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      ready_reg <= 1'b0;
      stall_cnt  <= 0;
      stall_max  <= 0;
    end else begin
      if (stall_cnt == 0) begin
        ready_reg <= 1'b1;  // assert TREADY
        if (TVALID && ready_reg) begin
          // Handshake completed — pick new random stall
          stall_max = $urandom_range(0, `TREADY_STALL_MAX);
          stall_cnt = stall_max;
          if (stall_max > 0) ready_reg <= 1'b0;
        end
      end else begin
        stall_cnt--;
        if (stall_cnt == 0) ready_reg <= 1'b1;
      end
    end
  end

  assign TREADY    = ARESETn ? ready_reg : 1'b0;
  assign TREADYCHK = ~TREADY;  // odd parity of 1-bit TREADY

endmodule
