// ============================================================================
// AXI5-Stream Slave VIP — Tests (TC_SLV_001..050)
// Negative tests set a static dut_ctl bit that the DUT master stub polls to
// emit the violation; a report catcher demotes the expected checker error and
// check_phase FAILS if the checker stayed silent (vacuous-checker guard).
// ============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_TEST_SV
`define AXI_STREAM_SLAVE_VIP_TEST_SV

// Static control the tests use to command the DUT master stub and TB clock.
class axi_stream_slave_vip_dut_ctl;
  static bit drop_valid, mutate_payload, reserved_qual, no_wake_lead, parity_fault, tlast_glitch;
  static int unsigned clk_gate_cycles;   // >0 requests an ACLK-off window (TC_050)
  static int unsigned reset_pulse;       // >0 requests a mid-sim ARESETn pulse
endclass

class axi_stream_slave_vip_violation_catcher extends uvm_report_catcher;
  string expect_id; string allow_ids[$]; int unsigned caught;
  function new(string name="axi_stream_slave_vip_violation_catcher"); super.new(name); endfunction
  function action_e catch();
    if (get_severity()==UVM_ERROR) begin
      if (get_id()==expect_id) begin caught++; set_severity(UVM_INFO); set_id($sformatf("EXPECTED/%s",expect_id)); end
      else foreach (allow_ids[i]) if (get_id()==allow_ids[i]) begin set_severity(UVM_INFO); set_id($sformatf("COLLATERAL/%s",allow_ids[i])); break; end
    end
    return THROW;
  endfunction
endclass

class axi_stream_slave_vip_base_test extends uvm_test;
  `uvm_component_utils(axi_stream_slave_vip_base_test)
  axi_stream_slave_vip_env            env;
  axi_stream_slave_vip_env_config     env_cfg;
  axi_stream_slave_vip_agent_config   agent_cfg;
  axi_stream_slave_vip_violation_catcher catcher;
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function void configure_knobs(); endfunction
  virtual function uvm_sequence_base get_seq(); return null; endfunction
  virtual function string expected_violation_id(); return ""; endfunction
  virtual task stimulus_hook(); endtask
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent_cfg = axi_stream_slave_vip_agent_config::type_id::create("agent_cfg");
    env_cfg   = axi_stream_slave_vip_env_config  ::type_id::create("env_cfg");
    if (!uvm_config_db #(virtual axi_stream_slave_vip_if #(.DATA_W(`AXI_DATA_W),.ID_W(`AXI_ID_W),.DEST_W(`AXI_DEST_W),.USER_W(`AXI_USER_W),.HAS_PAR(`AXI_HAS_PAR),.HAS_WAKE(`AXI_HAS_WAKE)))::get(this,"","vif",agent_cfg.vif))
      `uvm_fatal("TEST/NOVIF","vif not found")
    env_cfg.agent_cfg = agent_cfg;
    configure_knobs();
    uvm_config_db #(axi_stream_slave_vip_env_config)::set(this,"env","cfg",env_cfg);
    env = axi_stream_slave_vip_env::type_id::create("env", this);
    if (expected_violation_id() != "") begin
      catcher = new("catcher"); catcher.expect_id = expected_violation_id();
      // A deliberate mid-packet DUT violation disrupts downstream reconstruction,
      // so identity/framing/liveness checks firing is expected collateral. The
      // test's real assertion is that its NAMED checker fired (checked below).
      catcher.allow_ids.push_back("SB/LIVENESS");
      catcher.allow_ids.push_back("CHK/ID_CONSTANT");
      catcher.allow_ids.push_back("CHK/PKT_FRAMING");
      uvm_report_cb::add(null, catcher);
      `uvm_info("TEST",$sformatf("NEGATIVE: expecting checker '%s'; run FAILS if silent.",catcher.expect_id),UVM_LOW)
    end
  endfunction
  function void end_of_elaboration_phase(uvm_phase phase); super.end_of_elaboration_phase(phase); uvm_top.print_topology(); endfunction
  task run_phase(uvm_phase phase);
    uvm_sequence_base seq = get_seq();
    phase.raise_objection(this);
    fork stimulus_hook(); join_none
    if (seq==null) #1us; else begin if(!seq.randomize()) `uvm_fatal("TEST/RAND","seq rand failed"); seq.start(env.slave_agent.sequencer); #2us; end
    phase.drop_objection(this);
  endtask
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (expected_violation_id() != "") begin
      if (catcher.caught==0) `uvm_error("TEST/CHECKER_SILENT",$sformatf("Checker '%s' never fired — vacuous.",expected_violation_id()))
      else `uvm_info("TEST",$sformatf("Checker '%s' fired %0d time(s) — confirmed.",expected_violation_id(),catcher.caught),UVM_LOW)
    end
  endfunction
endclass

`define AXIS_SLV_TEST(TC) \
class axi_stream_slave_vip_``TC``_test extends axi_stream_slave_vip_base_test; \
  `uvm_component_utils(axi_stream_slave_vip_``TC``_test) \
  function new(string name, uvm_component parent); super.new(name,parent); endfunction \
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_``TC``_seq::type_id::create("seq"); endfunction \
endclass

`AXIS_SLV_TEST(tc_slv_001)
`AXIS_SLV_TEST(tc_slv_002)
`AXIS_SLV_TEST(tc_slv_003)
`AXIS_SLV_TEST(tc_slv_004)
`AXIS_SLV_TEST(tc_slv_005)
`AXIS_SLV_TEST(tc_slv_006)
`AXIS_SLV_TEST(tc_slv_007)
`AXIS_SLV_TEST(tc_slv_008)
`AXIS_SLV_TEST(tc_slv_009)
`AXIS_SLV_TEST(tc_slv_011)
`AXIS_SLV_TEST(tc_slv_012)
`AXIS_SLV_TEST(tc_slv_013)
`AXIS_SLV_TEST(tc_slv_015)
`AXIS_SLV_TEST(tc_slv_016)
`AXIS_SLV_TEST(tc_slv_017)
`AXIS_SLV_TEST(tc_slv_019)
`AXIS_SLV_TEST(tc_slv_020)
`AXIS_SLV_TEST(tc_slv_021)
`AXIS_SLV_TEST(tc_slv_025)
`AXIS_SLV_TEST(tc_slv_026)
`AXIS_SLV_TEST(tc_slv_027)
`AXIS_SLV_TEST(tc_slv_028)
`AXIS_SLV_TEST(tc_slv_029)
`AXIS_SLV_TEST(tc_slv_030)
`AXIS_SLV_TEST(tc_slv_031)
`AXIS_SLV_TEST(tc_slv_032)
`AXIS_SLV_TEST(tc_slv_033)
`AXIS_SLV_TEST(tc_slv_034)
`AXIS_SLV_TEST(tc_slv_035)
`AXIS_SLV_TEST(tc_slv_036)
`AXIS_SLV_TEST(tc_slv_037)
`AXIS_SLV_TEST(tc_slv_038)
`AXIS_SLV_TEST(tc_slv_040)
`AXIS_SLV_TEST(tc_slv_041)
`AXIS_SLV_TEST(tc_slv_042)
`AXIS_SLV_TEST(tc_slv_043)
`AXIS_SLV_TEST(tc_slv_045)
`AXIS_SLV_TEST(tc_slv_047)

class axi_stream_slave_vip_tc_slv_010_test extends axi_stream_slave_vip_base_test;
  `uvm_component_utils(axi_stream_slave_vip_tc_slv_010_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_tc_slv_010_seq::type_id::create("seq"); endfunction
  virtual function void configure_knobs(); env_cfg.check_throughput = 1; endfunction
endclass

class axi_stream_slave_vip_tc_slv_014_test extends axi_stream_slave_vip_base_test;
  `uvm_component_utils(axi_stream_slave_vip_tc_slv_014_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_tc_slv_014_seq::type_id::create("seq"); endfunction
  virtual function string expected_violation_id(); return "CHK/TVALID_STABILITY"; endfunction
  virtual function void configure_knobs(); axi_stream_slave_vip_dut_ctl::drop_valid = 1; endfunction
endclass

class axi_stream_slave_vip_tc_slv_018_test extends axi_stream_slave_vip_base_test;
  `uvm_component_utils(axi_stream_slave_vip_tc_slv_018_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_tc_slv_018_seq::type_id::create("seq"); endfunction
  virtual function string expected_violation_id(); return "CHK/PAYLOAD_STABILITY"; endfunction
  virtual function void configure_knobs(); axi_stream_slave_vip_dut_ctl::mutate_payload = 1; endfunction
endclass

class axi_stream_slave_vip_tc_slv_022_test extends axi_stream_slave_vip_base_test;
  `uvm_component_utils(axi_stream_slave_vip_tc_slv_022_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_tc_slv_022_seq::type_id::create("seq"); endfunction
  virtual task stimulus_hook(); #3us; axi_stream_slave_vip_dut_ctl::reset_pulse = 6; endtask
endclass

class axi_stream_slave_vip_tc_slv_023_test extends axi_stream_slave_vip_base_test;
  `uvm_component_utils(axi_stream_slave_vip_tc_slv_023_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_tc_slv_023_seq::type_id::create("seq"); endfunction
  virtual task stimulus_hook(); #4us; axi_stream_slave_vip_dut_ctl::reset_pulse = 6; endtask
endclass

class axi_stream_slave_vip_tc_slv_024_test extends axi_stream_slave_vip_base_test;
  `uvm_component_utils(axi_stream_slave_vip_tc_slv_024_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_tc_slv_024_seq::type_id::create("seq"); endfunction
  virtual task stimulus_hook(); repeat(3) begin #3us; axi_stream_slave_vip_dut_ctl::reset_pulse = $urandom_range(2,8); end endtask
endclass

class axi_stream_slave_vip_tc_slv_039_test extends axi_stream_slave_vip_base_test;
  `uvm_component_utils(axi_stream_slave_vip_tc_slv_039_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_tc_slv_039_seq::type_id::create("seq"); endfunction
  virtual function string expected_violation_id(); return "CHK/RESERVED_QUAL"; endfunction
  virtual function void configure_knobs(); axi_stream_slave_vip_dut_ctl::reserved_qual = 1; endfunction
endclass

class axi_stream_slave_vip_tc_slv_044_test extends axi_stream_slave_vip_base_test;
  `uvm_component_utils(axi_stream_slave_vip_tc_slv_044_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_tc_slv_044_seq::type_id::create("seq"); endfunction
  virtual function void configure_knobs(); agent_cfg.wakeup_gated_ready = 1; endfunction
endclass

class axi_stream_slave_vip_tc_slv_046_test extends axi_stream_slave_vip_base_test;
  `uvm_component_utils(axi_stream_slave_vip_tc_slv_046_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_tc_slv_046_seq::type_id::create("seq"); endfunction
  virtual function string expected_violation_id(); return "CHK/WAKE_LEAD"; endfunction
  virtual function void configure_knobs(); axi_stream_slave_vip_dut_ctl::no_wake_lead = 1; endfunction
endclass

class axi_stream_slave_vip_tc_slv_048_test extends axi_stream_slave_vip_base_test;
  `uvm_component_utils(axi_stream_slave_vip_tc_slv_048_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_tc_slv_048_seq::type_id::create("seq"); endfunction
  virtual function string expected_violation_id(); return "CHK/PARITY"; endfunction
  virtual function void configure_knobs(); axi_stream_slave_vip_dut_ctl::parity_fault = 1; endfunction
endclass

class axi_stream_slave_vip_tc_slv_049_test extends axi_stream_slave_vip_base_test;
  `uvm_component_utils(axi_stream_slave_vip_tc_slv_049_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_tc_slv_049_seq::type_id::create("seq"); endfunction
  virtual function string expected_violation_id(); return "CHK/PKT_FRAMING"; endfunction
  virtual function void configure_knobs(); axi_stream_slave_vip_dut_ctl::tlast_glitch = 1; endfunction
endclass

class axi_stream_slave_vip_tc_slv_050_test extends axi_stream_slave_vip_base_test;
  `uvm_component_utils(axi_stream_slave_vip_tc_slv_050_test)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  virtual function uvm_sequence_base get_seq(); return axi_stream_slave_vip_tc_slv_050_seq::type_id::create("seq"); endfunction
  virtual task stimulus_hook(); #3us; axi_stream_slave_vip_dut_ctl::clk_gate_cycles = 40; endtask
endclass

`endif