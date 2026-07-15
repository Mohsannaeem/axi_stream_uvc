// =============================================================================
// AXI5-Stream Slave VIP — Sequencer
// =============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_SEQUENCER_SV
`define AXI_STREAM_SLAVE_VIP_SEQUENCER_SV

class axi_stream_slave_vip_sequencer extends uvm_sequencer #(axi_stream_slave_vip_seq_item);
  `uvm_component_utils(axi_stream_slave_vip_sequencer)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass

`endif
