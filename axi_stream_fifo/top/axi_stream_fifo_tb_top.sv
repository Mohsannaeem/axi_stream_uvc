// ─────────────────────────────────────────────────────────────────────────────
// AXI-Stream FIFO Testbench Top
//
// DUT: axis_data_fifo_v2_0_0_top  (Xilinx AXI4-Stream FIFO, behavioral stub)
//
// Connectivity:
//
//   ┌─────────────────────────────────────────────────────────────────────┐
//   │                axi_stream_fifo_tb_top                               │
//   │                                                                     │
//   │  ┌───────────────────┐       ┌──────────┐    ┌─────────────────┐   │
//   │  │ Master VIP (ACTV) │──────▶│   FIFO   │───▶│ Slave VIP (ACTV)│  │
//   │  │ axi_stream_master │ s_axis│  DUT     │m_ax│ axi_stream_slave│  │
//   │  │ _vip_if (mst_if)  │◀──────│          │───▶│ _vip_if (slv_if)│  │
//   │  │                   │ TREADY│          │TREA│                 │  │
//   │  └───────────────────┘       └──────────┘    └─────────────────┘  │
//   │                                                                     │
//   │  AXI5 parity signals (TVALIDCHK, TDATACHK, etc.) are NOT generated │
//   │  by the AXI4-Stream FIFO.  This tb_top computes them from the      │
//   │  live signal values and injects them into the VIP interfaces.       │
//   └─────────────────────────────────────────────────────────────────────┘
//
// ─────────────────────────────────────────────────────────────────────────────
`timescale 1ns/1ps
import axi_stream_master_vip_pkg::*;
import axi_stream_slave_vip_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"
import axi_stream_fifo_pkg::*;

module axi_stream_fifo_tb_top;

  // ── Shared clock and reset ──────────────────────────────────────────────────
  logic ACLK    = 1'b0;
  logic ARESETn = 1'b0;

  always #5 ACLK = ~ACLK;

  initial begin
    ARESETn = 1'b0;
    repeat (10) @(posedge ACLK);
    @(posedge ACLK);
    ARESETn = 1'b1;
    `uvm_info("TB_TOP", "ARESETn deasserted", UVM_NONE)
  end

  // ── VIP Interfaces ──────────────────────────────────────────────────────────
  // Explicit parameter binding to package localparams so one change propagates
  // everywhere: change AXI_DATA_W in *_pkg.sv → widths update here automatically.
  // Qualified names (pkg::CONST) avoid ambiguity when both packages are imported.

  // Master VIP: VIP is Transmitter → drives FIFO slave port
  axi_stream_master_vip_if #(
    .DATA_W  (axi_stream_master_vip_pkg::AXI_DATA_W),
    .ID_W    (axi_stream_master_vip_pkg::AXI_ID_W),
    .DEST_W  (axi_stream_master_vip_pkg::AXI_DEST_W),
    .USER_W  (axi_stream_master_vip_pkg::AXI_USER_W),
    .HAS_PAR (axi_stream_master_vip_pkg::AXI_HAS_PAR),
    .HAS_WAKE(axi_stream_master_vip_pkg::AXI_HAS_WAKE)
  ) mst_if (.ACLK(ACLK), .ARESETn(ARESETn));

  // Slave VIP: VIP is Receiver → reads FIFO master port
  axi_stream_slave_vip_if #(
    .DATA_W  (axi_stream_slave_vip_pkg::AXI_DATA_W),
    .ID_W    (axi_stream_slave_vip_pkg::AXI_ID_W),
    .DEST_W  (axi_stream_slave_vip_pkg::AXI_DEST_W),
    .USER_W  (axi_stream_slave_vip_pkg::AXI_USER_W),
    .HAS_PAR (axi_stream_slave_vip_pkg::AXI_HAS_PAR),
    .HAS_WAKE(axi_stream_slave_vip_pkg::AXI_HAS_WAKE)
  ) slv_if (.ACLK(ACLK), .ARESETn(ARESETn));

  // ── Internal wires: FIFO slave port TREADY output ──────────────────────────
  // The FIFO outputs s_axis_tready; the Master VIP observes it.
  logic s_axis_tready_w;

  // Bring FIFO's TREADY back into master VIP interface + compute AXI5 parity
  // (FIFO is AXI4-Stream — it does not generate TREADYCHK)
  assign mst_if.TREADY    = s_axis_tready_w;
  assign mst_if.TREADYCHK = ~s_axis_tready_w;    // odd parity of 1-bit TREADY

  // ── Internal wires: FIFO master port outputs ────────────────────────────────
  // Widths derived from slave VIP package so they track any localparam change.
  logic [axi_stream_slave_vip_pkg::AXI_DATA_W-1:0] m_tdata_w;
  logic [axi_stream_slave_vip_pkg::AXI_STRB_W-1:0] m_tstrb_w;
  logic [axi_stream_slave_vip_pkg::AXI_STRB_W-1:0] m_tkeep_w;
  logic                                              m_tvalid_w;
  logic                                              m_tlast_w;
  logic [axi_stream_slave_vip_pkg::AXI_ID_W-1:0]   m_tid_w;
  logic [axi_stream_slave_vip_pkg::AXI_DEST_W-1:0] m_tdest_w;
  logic [axi_stream_slave_vip_pkg::AXI_USER_W-1:0] m_tuser_w;

  // Feed FIFO master outputs into the Slave VIP interface
  assign slv_if.TVALID = m_tvalid_w;
  assign slv_if.TDATA  = m_tdata_w;
  assign slv_if.TSTRB  = m_tstrb_w;
  assign slv_if.TKEEP  = m_tkeep_w;
  assign slv_if.TLAST  = m_tlast_w;
  assign slv_if.TID    = m_tid_w;
  assign slv_if.TDEST  = m_tdest_w;
  assign slv_if.TUSER  = m_tuser_w;
  assign slv_if.TWAKEUP = 1'b0;      // FIFO has no TWAKEUP → drive inactive

  // ── AXI5 parity for Slave VIP interface ────────────────────────────────────
  // The FIFO does not generate check signals.  Compute odd parity from outputs.
  // Odd parity rule: 1-bit x → ~x ;  8-bit byte b → ~^b (inverted even XOR)
  assign slv_if.TVALIDCHK  = ~m_tvalid_w;
  assign slv_if.TLASTCHK   = ~m_tlast_w;
  assign slv_if.TWAKEUPCHK = 1'b1;               // ~TWAKEUP = ~0 = 1
  generate
    genvar gi;
    for (gi = 0; gi < axi_stream_slave_vip_pkg::AXI_STRB_W; gi++) begin : gen_datachk
      assign slv_if.TDATACHK[gi] = ~^m_tdata_w[gi*8 +: 8];
    end
  endgenerate

  // ── DUT: Xilinx AXI4-Stream Data FIFO ──────────────────────────────────────
  // Instantiation matches the parameters in the user's spec.
  // m_axis_tready is driven by the Slave VIP (not tied to 0 as in the spec
  // placeholder — connected to slv_if.TREADY so the slave agent controls flow).
  axis_data_fifo_v2_0_0_top #(
    .C_FAMILY             ("zynq"),
    .C_AXIS_TDATA_WIDTH   (axi_stream_master_vip_pkg::AXI_DATA_W),
    .C_AXIS_TID_WIDTH     (axi_stream_master_vip_pkg::AXI_ID_W),
    .C_AXIS_TDEST_WIDTH   (axi_stream_master_vip_pkg::AXI_DEST_W),
    .C_AXIS_TUSER_WIDTH   (axi_stream_master_vip_pkg::AXI_USER_W),
    .C_AXIS_SIGNAL_SET    ('B00000000000000000000000000000011),
    .C_FIFO_DEPTH         (512),
    .C_FIFO_MODE          (1),
    .C_IS_ACLK_ASYNC      (0),
    .C_SYNCHRONIZER_STAGE (3),
    .C_ACLKEN_CONV_MODE   (0),
    .C_ECC_MODE           (0),
    .C_FIFO_MEMORY_TYPE   ("auto"),
    .C_USE_ADV_FEATURES   (825241648),
    .C_PROG_EMPTY_THRESH  (5),
    .C_PROG_FULL_THRESH   (11)
  ) dut (
    // ── Slave port: Master VIP drives in ──────────────────────────────────────
    .s_axis_aresetn  (ARESETn),
    .s_axis_aclk     (ACLK),
    .s_axis_aclken   (1'b1),
    .s_axis_tvalid   (mst_if.TVALID),
    .s_axis_tready   (s_axis_tready_w),     // output → mst_if.TREADY (see above)
    .s_axis_tdata    (mst_if.TDATA),
    .s_axis_tstrb    (mst_if.TSTRB),
    .s_axis_tkeep    (mst_if.TKEEP),
    .s_axis_tlast    (mst_if.TLAST),
    .s_axis_tid      (mst_if.TID),
    .s_axis_tdest    (mst_if.TDEST),
    .s_axis_tuser    (mst_if.TUSER),

    // ── Master port: Slave VIP reads out ─────────────────────────────────────
    .m_axis_aclk     (1'b0),               // unused in sync mode (C_IS_ACLK_ASYNC=0)
    .m_axis_aclken   (1'b1),
    .m_axis_tvalid   (m_tvalid_w),         // → slv_if.TVALID (see above)
    .m_axis_tready   (slv_if.TREADY),      // ← Slave VIP drives this
    .m_axis_tdata    (m_tdata_w),
    .m_axis_tstrb    (m_tstrb_w),
    .m_axis_tkeep    (m_tkeep_w),
    .m_axis_tlast    (m_tlast_w),
    .m_axis_tid      (m_tid_w),
    .m_axis_tdest    (m_tdest_w),
    .m_axis_tuser    (m_tuser_w),

    // ── Status outputs (unconnected — tie off) ────────────────────────────────
    .axis_wr_data_count (),
    .axis_rd_data_count (),
    .almost_empty       (),
    .prog_empty         (),
    .almost_full        (),
    .prog_full          (),
    .sbiterr            (),
    .dbiterr            (),
    .injectsbiterr      (1'b0),
    .injectdbiterr      (1'b0)
  );

  // ── UVM config DB: register both VIF handles with distinct keys ─────────────
  // Type must match the interface instance's parameter specialisation exactly.
  initial begin
    uvm_config_db #(virtual axi_stream_master_vip_if #(
      .DATA_W  (axi_stream_master_vip_pkg::AXI_DATA_W),
      .ID_W    (axi_stream_master_vip_pkg::AXI_ID_W),
      .DEST_W  (axi_stream_master_vip_pkg::AXI_DEST_W),
      .USER_W  (axi_stream_master_vip_pkg::AXI_USER_W),
      .HAS_PAR (axi_stream_master_vip_pkg::AXI_HAS_PAR),
      .HAS_WAKE(axi_stream_master_vip_pkg::AXI_HAS_WAKE)))::set(
      null, "uvm_test_top", "mst_vif", mst_if);
    uvm_config_db #(virtual axi_stream_slave_vip_if #(
      .DATA_W  (axi_stream_slave_vip_pkg::AXI_DATA_W),
      .ID_W    (axi_stream_slave_vip_pkg::AXI_ID_W),
      .DEST_W  (axi_stream_slave_vip_pkg::AXI_DEST_W),
      .USER_W  (axi_stream_slave_vip_pkg::AXI_USER_W),
      .HAS_PAR (axi_stream_slave_vip_pkg::AXI_HAS_PAR),
      .HAS_WAKE(axi_stream_slave_vip_pkg::AXI_HAS_WAKE)))::set(
      null, "uvm_test_top", "slv_vif", slv_if);
    run_test();
  end

  // ── UVM global timeout ──────────────────────────────────────────────────────
  initial uvm_top.set_timeout(100_000_000, 1);  // 100 µs in ps (1ns/1ps timescale)

  // ── Waveform dump ───────────────────────────────────────────────────────────
  initial begin
    if ($test$plusargs("WAVES")) begin
      $shm_open("waves.shm");
      $shm_probe("AS");
    end
  end

endmodule
