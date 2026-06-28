// AXI-Stream Master VIP Environment Configuration
class axi_stream_master_vip_env_config extends uvm_object;
  `uvm_object_utils(axi_stream_master_vip_env_config)

  axi_stream_master_vip_agent_config mst_cfg;

  bit has_scoreboard = 1;

  function new(string name = "axi_stream_master_vip_env_config");
    super.new(name);
  endfunction

endclass
