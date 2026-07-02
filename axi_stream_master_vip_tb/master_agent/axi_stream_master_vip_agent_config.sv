// AXI-Stream Master VIP Agent Configuration
class axi_stream_master_vip_agent_config extends uvm_object;
  `uvm_object_utils(axi_stream_master_vip_agent_config)

  virtual axi_stream_master_vip_if vif;

  uvm_active_passive_enum is_active        = UVM_ACTIVE;
  bit has_parity                           = AXI_HAS_PAR;   // drive+check AXI5 parity signals
  bit has_twakeup                          = AXI_HAS_WAKE;  // drive TWAKEUP signal
  bit continuous_pkt_mode                  = 0;             // Continuous_Packets constraint
  bit enable_protocol_checks               = 1;             // enable monitor protocol checks
  bit enable_tracker                       = 1;             // write master_packet_tracker.log
  int tready_watchdog_cycles               = TREADY_WATCHDOG_MAX;
  int max_packet_beats                     = MAX_PACKET_BEATS;

  function new(string name = "axi_stream_master_vip_agent_config");
    super.new(name);
    if ($test$plusargs("CONT_PKT_MODE"))
      continuous_pkt_mode = 1;
    if ($test$plusargs("ENABLE_TRACKER"))
      enable_tracker = 1;
  endfunction

endclass
