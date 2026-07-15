// =============================================================================
// AXI5-Stream Slave VIP — Environment
// =============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_ENV_SV
`define AXI_STREAM_SLAVE_VIP_ENV_SV

class axi_stream_slave_vip_env extends uvm_env;
  `uvm_component_utils(axi_stream_slave_vip_env)

  axi_stream_slave_vip_env_config  cfg;
  axi_stream_slave_vip_agent       slave_agent;
  axi_stream_slave_vip_scoreboard  sb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(axi_stream_slave_vip_env_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("ENV/NOCFG", "env_config not found in ConfigDB")
    uvm_config_db #(axi_stream_slave_vip_agent_config)::set(this, "slave_agent", "cfg", cfg.agent_cfg);
    slave_agent = axi_stream_slave_vip_agent::type_id::create("slave_agent", this);
    if (cfg.enable_scoreboard) begin
      uvm_config_db #(axi_stream_slave_vip_env_config)::set(this, "sb", "cfg", cfg);
      sb = axi_stream_slave_vip_scoreboard::type_id::create("sb", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.enable_scoreboard) begin
      // The monitor reaches the scoreboard directly via note_received/note_reset
      // (published below), so its analysis port needs no wiring here.
      uvm_config_db #(axi_stream_slave_vip_scoreboard)::set(null, "*", "sb", sb);
    end
  endfunction

endclass

`endif
