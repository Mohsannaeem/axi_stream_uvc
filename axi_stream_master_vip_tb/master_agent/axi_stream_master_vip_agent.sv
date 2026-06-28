// AXI-Stream Master VIP Agent
// Active agent: instantiates driver + sequencer + monitor.
// Passive agent: instantiates monitor only.
class axi_stream_master_vip_agent extends uvm_agent;
  `uvm_component_utils(axi_stream_master_vip_agent)

  axi_stream_master_vip_driver     drv;
  axi_stream_master_vip_sequencer  seqr;
  axi_stream_master_vip_monitor    mon;
  axi_stream_master_vip_agent_config cfg;

  uvm_analysis_port #(axi_stream_master_vip_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(axi_stream_master_vip_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("CFG", "No CFG for axi_stream_master_vip_agent")

    mon = axi_stream_master_vip_monitor::type_id::create("mon", this);
    uvm_config_db #(virtual axi_stream_master_vip_if)::set(this, "mon", "vif", cfg.vif);
    uvm_config_db #(axi_stream_master_vip_agent_config)::set(this, "mon", "cfg", cfg);

    if (cfg.is_active == UVM_ACTIVE) begin
      drv  = axi_stream_master_vip_driver::type_id::create("drv", this);
      seqr = axi_stream_master_vip_sequencer::type_id::create("seqr", this);
      uvm_config_db #(virtual axi_stream_master_vip_if)::set(this, "drv", "vif", cfg.vif);
      uvm_config_db #(axi_stream_master_vip_agent_config)::set(this, "drv", "cfg", cfg);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    mon.ap.connect(ap);
    if (cfg.is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass
