// AXI-Stream FIFO Environment Configuration
// Aggregates the master and slave agent configs so a single object can be
// passed from the test into the FIFO environment.
class axi_stream_fifo_env_config extends uvm_object;
  `uvm_object_utils(axi_stream_fifo_env_config)

  axi_stream_master_vip_agent_config mst_cfg;
  axi_stream_slave_vip_agent_config  slv_cfg;
  bit has_scoreboard = 1;

  function new(string name = "axi_stream_fifo_env_config");
    super.new(name);
    mst_cfg = axi_stream_master_vip_agent_config::type_id::create("mst_cfg");
    slv_cfg = axi_stream_slave_vip_agent_config::type_id::create("slv_cfg");
  endfunction

endclass
