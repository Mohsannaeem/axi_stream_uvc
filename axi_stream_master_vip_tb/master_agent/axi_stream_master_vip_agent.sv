// =============================================================================
// AXI5-Stream Master VIP — Agent
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_AGENT_SV
`define AXI_STREAM_MASTER_VIP_AGENT_SV

class axi_stream_master_vip_agent extends uvm_agent;
  `uvm_component_utils(axi_stream_master_vip_agent)

  axi_stream_master_vip_agent_config cfg;
  axi_stream_master_vip_driver       driver;
  axi_stream_master_vip_sequencer    sequencer;
  axi_stream_master_vip_monitor      monitor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(axi_stream_master_vip_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("AGT/NOCFG", "agent_config not found in ConfigDB")

    // The monitor is always built: passive observation is unconditional.
    uvm_config_db #(axi_stream_master_vip_agent_config)::set(this, "monitor", "cfg", cfg);
    monitor = axi_stream_master_vip_monitor::type_id::create("monitor", this);

    if (cfg.is_active == UVM_ACTIVE) begin
      uvm_config_db #(axi_stream_master_vip_agent_config)::set(this, "driver", "cfg", cfg);
      driver    = axi_stream_master_vip_driver   ::type_id::create("driver", this);
      sequencer = axi_stream_master_vip_sequencer::type_id::create("sequencer", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.is_active == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass

`endif
