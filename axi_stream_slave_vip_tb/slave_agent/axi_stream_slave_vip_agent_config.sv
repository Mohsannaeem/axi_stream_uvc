// =============================================================================
// AXI5-Stream Slave VIP — Agent Config
// Runtime knobs only. Widths are structural (defines macros / interface params).
// Follows the current skill's tracker_dir + get_cli_args() pattern (§116).
// =============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_AGENT_CONFIG_SV
`define AXI_STREAM_SLAVE_VIP_AGENT_CONFIG_SV

class axi_stream_slave_vip_agent_config extends uvm_object;
  `uvm_object_utils(axi_stream_slave_vip_agent_config)

  // Explicit #(...) binding is MANDATORY (SKILL §156) so macro changes propagate.
  virtual axi_stream_slave_vip_if #(
    .DATA_W  (`AXI_DATA_W),
    .ID_W    (`AXI_ID_W),
    .DEST_W  (`AXI_DEST_W),
    .USER_W  (`AXI_USER_W),
    .HAS_PAR (`AXI_HAS_PAR),
    .HAS_WAKE(`AXI_HAS_WAKE)
  ) vif;

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  bit          has_parity        = `AXI_HAS_PAR;
  bit          has_twakeup       = `AXI_HAS_WAKE;
  bit          enable_tracker    = 1;      // active-by-default (SKILL §177)
  string       tracker_dir       = ".";
  bit          wakeup_gated_ready = 0;     // gate TREADY on observed TWAKEUP (REQ_SLV_12)
  int unsigned tvalid_watchdog_cycles = `TVALID_WATCHDOG_MAX;
  int unsigned max_packet_beats  = `MAX_PACKET_BEATS;

  function new(string name = "axi_stream_slave_vip_agent_config");
    super.new(name);
    get_cli_args();
  endfunction

  virtual function void get_cli_args();
    uvm_cmdline_processor cmd = uvm_cmdline_processor::get_inst();
    void'(cmd.get_arg_value("+TRACKER_DIR=", tracker_dir));
  endfunction

endclass

`endif
