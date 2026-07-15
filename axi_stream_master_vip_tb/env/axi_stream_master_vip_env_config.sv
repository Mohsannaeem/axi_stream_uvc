// =============================================================================
// AXI5-Stream Master VIP — Env Config
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_ENV_CONFIG_SV
`define AXI_STREAM_MASTER_VIP_ENV_CONFIG_SV

class axi_stream_master_vip_env_config extends uvm_object;
  `uvm_object_utils(axi_stream_master_vip_env_config)

  axi_stream_master_vip_agent_config agent_cfg;

  bit enable_scoreboard = 1;
  bit enable_coverage   = 1;

  // Set by a test when it drives a zero-delay packet, so the scoreboard knows
  // to assert the PERF_THROUGHPUT == 1.0 beats/cycle target (REQ_MST_04).
  bit check_throughput  = 0;

  function new(string name = "axi_stream_master_vip_env_config");
    super.new(name);
  endfunction

endclass

`endif
