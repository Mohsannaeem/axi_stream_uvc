// =============================================================================
// AXI5-Stream Slave VIP — Base Sequence
// Drives back-pressure PROFILE items. Subclasses override ONLY their profile
// constraints via profile_constraints(). Step trace at UVM_DEBUG (guideline 1c).
// =============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_BASE_SEQUENCE_SV
`define AXI_STREAM_SLAVE_VIP_BASE_SEQUENCE_SV

class axi_stream_slave_vip_base_sequence extends uvm_sequence #(axi_stream_slave_vip_seq_item);
  `uvm_object_utils(axi_stream_slave_vip_base_sequence)

  rand int unsigned num_profiles = 1;
  constraint c_num { num_profiles inside {[1:50]}; }

  function new(string name = "axi_stream_slave_vip_base_sequence");
    super.new(name);
  endfunction

  // Subclasses override to shape the TREADY profile. Default: legal random.
  virtual function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize())
      `uvm_fatal("SEQ/RAND", "profile randomize failed");
  endfunction

  virtual task body();
    axi_stream_slave_vip_seq_item item;
    int unsigned n;
    `uvm_info("SEQ_FLOW", $sformatf("[SEQ] step=BODY_START num_profiles=%0d", num_profiles), UVM_DEBUG)
    repeat (num_profiles) begin
      n++;
      item = axi_stream_slave_vip_seq_item::type_id::create("item");
      `uvm_info("SEQ_FLOW", "[SEQ] step=CALLING start_item", UVM_DEBUG)
      start_item(item);
      randomize_item(item);
      `uvm_info("SEQ_FLOW", $sformatf("[SEQ] step=RANDOMIZED mode=%s beats=%0d",
                item.mode.name(), item.num_beats_to_accept), UVM_DEBUG)
      `uvm_info("SEQ_FLOW", "[SEQ] step=CALLING finish_item", UVM_DEBUG)
      finish_item(item);
      `uvm_info("SEQ_FLOW", $sformatf("[SEQ] step=FINISH_ITEM done (%0d/%0d)", n, num_profiles), UVM_DEBUG)
    end
    `uvm_info("SEQ_FLOW", "[SEQ] step=BODY_DONE", UVM_DEBUG)
  endtask

endclass

`endif
