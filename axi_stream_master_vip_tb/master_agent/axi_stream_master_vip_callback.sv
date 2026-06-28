// AXI-Stream Master VIP Callback Base Class
// Allows external test code to intercept pre/post-drive events.
class axi_stream_master_vip_callback extends uvm_callback;
  `uvm_object_utils(axi_stream_master_vip_callback)

  function new(string name = "axi_stream_master_vip_callback");
    super.new(name);
  endfunction

  // Called just before driver starts transmitting a packet
  virtual task pre_transmit(axi_stream_master_vip_driver drv,
                            axi_stream_master_vip_seq_item item);
  endtask

  // Called after driver completes transmitting all beats of a packet
  virtual task post_transmit(axi_stream_master_vip_driver drv,
                             axi_stream_master_vip_seq_item item);
  endtask

endclass
