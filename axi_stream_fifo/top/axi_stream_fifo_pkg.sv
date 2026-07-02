// AXI-Stream FIFO Verification Package
//
// Compilation order:
//   1. axi_stream_master_vip_if.sv  (interface — includes master defines)
//   2. axi_stream_slave_vip_if.sv   (interface — includes slave defines)
//   3. axi_stream_master_vip_pkg.sv (imports master classes)
//   4. axi_stream_slave_vip_pkg.sv  (imports slave classes)
//   5. THIS FILE                    (imports both + FIFO env classes)
//   6. axis_data_fifo_stub.sv       (DUT)
//   7. axi_stream_fifo_tb_top.sv    (top module)
`ifndef AXI_STREAM_FIFO_PKG_SV
`define AXI_STREAM_FIFO_PKG_SV

package axi_stream_fifo_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import axi_stream_master_vip_pkg::*;
  import axi_stream_slave_vip_pkg::*;

  // ── Environment classes ─────────────────────────────────────────────────────
  `include "axi_stream_fifo_env_config.sv"
  `include "axi_stream_fifo_scoreboard.sv"
  `include "axi_stream_fifo_env.sv"

  // ── Sequences ────────────────────────────────────────────────────────────────
  `include "axi_stream_fifo_vseq.sv"

  // ── Tests ────────────────────────────────────────────────────────────────────
  `include "axi_stream_fifo_base_test.sv"

endpackage

`endif
