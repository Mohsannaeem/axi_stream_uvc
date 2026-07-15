// =============================================================================
// AXI5-Stream Slave VIP — Package
// Compile order: if.sv -> pkg.sv -> tb_top.sv. The include order below IS the
// compile dependency graph; defines and tracker precede the classes that use them.
// =============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_PKG_SV
`define AXI_STREAM_SLAVE_VIP_PKG_SV

package axi_stream_slave_vip_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "axi_stream_slave_vip_defines.sv"
  `include "axi_stream_slave_vip_tracker.sv"      // from slave_agent/ (incdir)

  `include "axi_stream_slave_vip_seq_item.sv"

  `include "axi_stream_slave_vip_agent_config.sv"
  `include "axi_stream_slave_vip_sequencer.sv"
  `include "axi_stream_slave_vip_callback.sv"
  `include "axi_stream_slave_vip_driver.sv"
  `include "axi_stream_slave_vip_monitor.sv"
  `include "axi_stream_slave_vip_agent.sv"

  `include "axi_stream_slave_vip_env_config.sv"
  `include "axi_stream_slave_vip_scoreboard.sv"
  `include "axi_stream_slave_vip_env.sv"

  `include "axi_stream_slave_vip_base_sequence.sv"
  `include "axi_stream_slave_vip_test_sequences.sv"
  `include "axi_stream_slave_vip_test.sv"

  typedef axi_stream_slave_vip_seq_item axi_stream_slv_seq_item_t;
  typedef axi_stream_slave_vip_agent    axi_stream_slv_agent_t;
  typedef axi_stream_slave_vip_env      axi_stream_slv_env_t;

endpackage

`endif
