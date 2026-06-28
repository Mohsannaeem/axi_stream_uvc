// AXI-Stream Master VIP Top-Level Environment
class axi_stream_master_vip_env extends uvm_env;
  `uvm_component_utils(axi_stream_master_vip_env)

  axi_stream_master_vip_agent       mst_agent;
  axi_stream_master_vip_scoreboard  scoreboard;
  axi_stream_master_vip_env_config  cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(axi_stream_master_vip_env_config)::get(this, "", "env_cfg", cfg))
      `uvm_fatal("CFG", "No ENV_CFG for axi_stream_master_vip_env")

    mst_agent = axi_stream_master_vip_agent::type_id::create("mst_agent", this);
    uvm_config_db #(axi_stream_master_vip_agent_config)::set(this, "mst_agent", "cfg", cfg.mst_cfg);

    if (cfg.has_scoreboard)
      scoreboard = axi_stream_master_vip_scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    if (cfg.has_scoreboard)
      mst_agent.ap.connect(scoreboard.analysis_export);
  endfunction

endclass
