// AXI-Stream Master VIP Package
// Compilation order: if → pkg → tb_top
`ifndef AXI_STREAM_MASTER_VIP_PKG_SV
`define AXI_STREAM_MASTER_VIP_PKG_SV

package axi_stream_master_vip_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ── Structural constants (package-scoped, not global) ────────────────────
  localparam int  AXI_DATA_W          = 32;
  localparam int  AXI_STRB_W          = AXI_DATA_W / 8;
  localparam int  AXI_ID_W            = 8;
  localparam int  AXI_DEST_W          = 4;
  localparam int  AXI_USER_W          = 4;
  localparam bit  AXI_HAS_PAR         = 1;
  localparam bit  AXI_HAS_WAKE        = 1;
  localparam int  CLK_PERIOD_PS       = 10;
  localparam int  TREADY_WATCHDOG_MAX = 100_000;
  localparam int  MAX_PACKET_BEATS    = 256;
  localparam int  TREADY_STALL_MAX    = 100;

  // ── Sequence item ──────────────────────────────────────────────────────────────
  `include "axi_stream_master_vip_seq_item.sv"

  // ── Agent ──────────────────────────────────────────────────────────────────────
  `include "axi_stream_master_vip_agent_config.sv"
  `include "axi_stream_master_vip_sequencer.sv"
  `include "axi_stream_master_vip_driver.sv"
  `include "axi_stream_master_vip_callback.sv"
  `include "axi_stream_master_vip_monitor.sv"
  `include "axi_stream_master_vip_agent.sv"

  // ── Environment ────────────────────────────────────────────────────────────────
  `include "axi_stream_master_vip_env_config.sv"
  `include "axi_stream_master_vip_scoreboard.sv"
  `include "axi_stream_master_vip_env.sv"

  // ── Sequences ──────────────────────────────────────────────────────────────────
  `include "axi_stream_master_vip_base_sequence.sv"
  `include "axi_stream_master_vip_test_sequences.sv"

  // ── Tests ──────────────────────────────────────────────────────────────────────
  `include "axi_stream_master_vip_test.sv"

  // ── Default factory-override aliases ─────────────────────────────────────
  typedef axi_stream_master_vip_seq_item  axi_stream_mst_seq_item_t;
  typedef axi_stream_master_vip_agent     axi_stream_mst_agent_t;
  typedef axi_stream_master_vip_env       axi_stream_mst_env_t;

endpackage

`endif
