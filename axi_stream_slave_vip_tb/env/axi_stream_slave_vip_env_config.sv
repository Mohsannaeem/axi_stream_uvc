// =============================================================================
// AXI5-Stream Slave VIP — Env Config
// =============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_ENV_CONFIG_SV
`define AXI_STREAM_SLAVE_VIP_ENV_CONFIG_SV

class axi_stream_slave_vip_env_config extends uvm_object;
  `uvm_object_utils(axi_stream_slave_vip_env_config)

  axi_stream_slave_vip_agent_config agent_cfg;
  bit enable_scoreboard = 1;
  bit enable_coverage   = 1;
  bit check_throughput  = 0;   // set by TC_SLV_010 (PERF_ACCEPT_THROUGHPUT)

  function new(string name = "axi_stream_slave_vip_env_config");
    super.new(name);
  endfunction
endclass

`endif
