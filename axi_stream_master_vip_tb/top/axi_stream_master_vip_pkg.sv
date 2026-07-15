// =============================================================================
// AXI5-Stream Master VIP — Package
// Compile order: if.sv -> pkg.sv -> tb_top.sv
//
// The include order below IS the compile dependency graph. defines.sv is
// included BEFORE any class file so every class sees the width macros.
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_PKG_SV
`define AXI_STREAM_MASTER_VIP_PKG_SV

package axi_stream_master_vip_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ── Width/capability macros — MUST precede every class include ────────────
  `include "axi_stream_master_vip_defines.sv"

  // ── Tracker base class (must precede driver/monitor, which instance it) ───
  `include "axi_stream_master_vip_tracker.sv"

  // ── Sequence item ─────────────────────────────────────────────────────────
  `include "axi_stream_master_vip_seq_item.sv"

  // ── Agent ─────────────────────────────────────────────────────────────────
  `include "axi_stream_master_vip_agent_config.sv"
  `include "axi_stream_master_vip_sequencer.sv"
  `include "axi_stream_master_vip_callback.sv"
  `include "axi_stream_master_vip_driver.sv"
  `include "axi_stream_master_vip_monitor.sv"
  `include "axi_stream_master_vip_agent.sv"

  // ── Environment ───────────────────────────────────────────────────────────
  `include "axi_stream_master_vip_env_config.sv"
  `include "axi_stream_master_vip_scoreboard.sv"
  `include "axi_stream_master_vip_env.sv"

  // ── Sequences ─────────────────────────────────────────────────────────────
  `include "axi_stream_master_vip_base_sequence.sv"
  `include "axi_stream_master_vip_test_sequences.sv"

  // ── Tests ─────────────────────────────────────────────────────────────────
  `include "axi_stream_master_vip_test.sv"

  // ── Default factory-override aliases ──────────────────────────────────────
  typedef axi_stream_master_vip_seq_item axi_stream_mst_seq_item_t;
  typedef axi_stream_master_vip_agent    axi_stream_mst_agent_t;
  typedef axi_stream_master_vip_env      axi_stream_mst_env_t;

endpackage

`endif
