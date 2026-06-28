// AXI-Stream Master VIP Package
// Compilation order: defines → if → pkg → tb_top
`ifndef AXI_STREAM_MASTER_VIP_PKG_SV
`define AXI_STREAM_MASTER_VIP_PKG_SV

package axi_stream_master_vip_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "axi_stream_master_vip_defines.sv"

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

endpackage

`endif
