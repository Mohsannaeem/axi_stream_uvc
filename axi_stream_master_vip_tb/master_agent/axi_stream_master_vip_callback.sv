// =============================================================================
// AXI5-Stream Master VIP — Driver Callback
// Injection hook letting a test mutate an item just before the driver commits
// it to the pins, without subclassing the driver.
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_CALLBACK_SV
`define AXI_STREAM_MASTER_VIP_CALLBACK_SV

typedef class axi_stream_master_vip_driver;

class axi_stream_master_vip_callback extends uvm_callback;
  `uvm_object_utils(axi_stream_master_vip_callback)

  function new(string name = "axi_stream_master_vip_callback");
    super.new(name);
  endfunction

  virtual task pre_drive(axi_stream_master_vip_driver drv,
                         axi_stream_master_vip_seq_item item);
  endtask

  virtual task post_drive(axi_stream_master_vip_driver drv,
                          axi_stream_master_vip_seq_item item);
  endtask

endclass

typedef uvm_callbacks #(axi_stream_master_vip_driver,
                        axi_stream_master_vip_callback) axi_stream_master_vip_cb_pool;

`endif
