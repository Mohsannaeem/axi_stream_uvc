// =============================================================================
// AXI5-Stream Master VIP — Sequencer
// Named type so factory overrides and p_sequencer casts resolve cleanly.
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_SEQUENCER_SV
`define AXI_STREAM_MASTER_VIP_SEQUENCER_SV

class axi_stream_master_vip_sequencer extends uvm_sequencer #(axi_stream_master_vip_seq_item);
  `uvm_component_utils(axi_stream_master_vip_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass

`endif
