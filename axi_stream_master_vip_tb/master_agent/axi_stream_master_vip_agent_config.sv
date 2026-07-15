// =============================================================================
// AXI5-Stream Master VIP — Agent Config
// Runtime knobs only. Signal widths are STRUCTURAL and live in the defines
// macros / interface parameters — never as integer fields here.
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_AGENT_CONFIG_SV
`define AXI_STREAM_MASTER_VIP_AGENT_CONFIG_SV

class axi_stream_master_vip_agent_config extends uvm_object;
  `uvm_object_utils(axi_stream_master_vip_agent_config)

  // The explicit #(...) binding is MANDATORY. A bare
  //   virtual axi_stream_master_vip_if vif;
  // silently takes the interface's own defaults, so a macro change in
  // defines.sv would NOT propagate to this handle's type.
  virtual axi_stream_master_vip_if #(
    .DATA_W  (`AXI_DATA_W),
    .ID_W    (`AXI_ID_W),
    .DEST_W  (`AXI_DEST_W),
    .USER_W  (`AXI_USER_W),
    .HAS_PAR (`AXI_HAS_PAR),
    .HAS_WAKE(`AXI_HAS_WAKE)
  ) vif;

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  bit          has_parity       = `AXI_HAS_PAR;
  bit          has_twakeup      = `AXI_HAS_WAKE;
  // SKILL §2: the tracker is "active-by-default" and verbosity-independent, so
  // a plain UVM_MEDIUM run still yields a full beat-level trace. (The skill's
  // own agent_config snippet at line 115 still shows 0 — that snippet predates
  // the tracker section and the two disagree; the tracker section wins.)
  bit          enable_tracker   = 1;
  int unsigned watchdog_cycles  = `TREADY_WATCHDOG_MAX;
  int unsigned max_packet_beats = `MAX_PACKET_BEATS;

  function new(string name = "axi_stream_master_vip_agent_config");
    super.new(name);
  endfunction

endclass

`endif
