// =============================================================================
// AXI5-Stream Master VIP — Tests
// One test per test_cases[] entry: 48 tests, TC_MST_001 .. TC_MST_048.
// The 48 near-identical classes are macro-expanded, which keeps this file ~250
// lines instead of ~1500 and matches the pattern eda_yaml_generator's test
// discovery already knows how to parse.
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_TEST_SV
`define AXI_STREAM_MASTER_VIP_TEST_SV

// ── Reset control ────────────────────────────────────────────────────────────
// Tests request a mid-simulation reset pulse by writing here; tb_top's reset
// generator polls it. This is how the reset test cases interrupt live traffic.
class axi_stream_master_vip_reset_ctl;
  static int unsigned pulse_cycles = 0;   // >0 requests an N-cycle ARESETn pulse
endclass

// ── Violation catcher ────────────────────────────────────────────────────────
// A negative test must PROVE its checker fired. This catcher demotes the one
// expected UVM_ERROR to UVM_INFO (so the deliberate violation does not fail the
// run) and counts it — the test then FAILS if the count is zero, i.e. if the
// checker stayed silent when it should have spoken.
class axi_stream_master_vip_violation_catcher extends uvm_report_catcher;
  string       expect_id;     // MUST fire, or the test fails as vacuous
  string       allow_ids[$];  // collateral: demoted, but not required to fire
  int unsigned caught;

  function new(string name = "axi_stream_master_vip_violation_catcher");
    super.new(name);
  endfunction

  function action_e catch();
    if (get_severity() == UVM_ERROR) begin
      if (get_id() == expect_id) begin
        caught++;
        set_severity(UVM_INFO);
        set_id($sformatf("EXPECTED_VIOLATION/%s", expect_id));
      end
      // Collateral damage from an intentional violation. Example: the TREADY
      // watchdog abort must drop TVALID to escape a deadlocked DUT, which in
      // turn trips the TVALID-stability checker. That second error is a
      // consequence of the abort, not an independent defect.
      else foreach (allow_ids[i])
        if (get_id() == allow_ids[i]) begin
          set_severity(UVM_INFO);
          set_id($sformatf("COLLATERAL/%s", allow_ids[i]));
          break;
        end
    end
    return THROW;
  endfunction
endclass

// ── Base test ────────────────────────────────────────────────────────────────
class axi_stream_master_vip_base_test extends uvm_test;
  `uvm_component_utils(axi_stream_master_vip_base_test)

  axi_stream_master_vip_env            env;
  axi_stream_master_vip_env_config     env_cfg;
  axi_stream_master_vip_agent_config   agent_cfg;
  axi_stream_master_vip_violation_catcher catcher;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Overridden by tests that need to tweak knobs before the env is built.
  virtual function void configure_knobs();
  endfunction

  // Overridden by every concrete test to supply its sequence.
  virtual function uvm_sequence_base get_seq();
    return null;
  endfunction

  // Non-empty for negative tests: the checker ID that MUST fire.
  virtual function string expected_violation_id();
    return "";
  endfunction

  // Checker IDs that are demoted as collateral of the intentional violation.
  virtual function void collateral_ids(ref string ids[$]);
  endfunction

  // Overridden by the reset tests to interrupt traffic mid-flight.
  virtual task stimulus_hook();
  endtask

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent_cfg = axi_stream_master_vip_agent_config::type_id::create("agent_cfg");
    env_cfg   = axi_stream_master_vip_env_config  ::type_id::create("env_cfg");

    if (!uvm_config_db #(virtual axi_stream_master_vip_if #(
          .DATA_W(`AXI_DATA_W), .ID_W(`AXI_ID_W), .DEST_W(`AXI_DEST_W),
          .USER_W(`AXI_USER_W), .HAS_PAR(`AXI_HAS_PAR), .HAS_WAKE(`AXI_HAS_WAKE)
        ))::get(this, "", "vif", agent_cfg.vif))
      `uvm_fatal("TEST/NOVIF", "Virtual interface 'vif' not found in ConfigDB")

    env_cfg.agent_cfg = agent_cfg;

    configure_knobs();

    uvm_config_db #(axi_stream_master_vip_env_config)::set(this, "env", "cfg", env_cfg);
    env = axi_stream_master_vip_env::type_id::create("env", this);

    if (expected_violation_id() != "") begin
      catcher = new("catcher");
      catcher.expect_id = expected_violation_id();

      // A negative test drives deliberately illegal stimulus and does NOT
      // register its packets as expected, so packet-level accounting is
      // meaningless for it by construction. Demote the scoreboard's bookkeeping
      // errors for every negative test; the protocol CHECKERS remain live, and
      // they are what the test is actually asserting.
      catcher.allow_ids.push_back("SB/UNEXPECTED");
      catcher.allow_ids.push_back("SB/PKT_COUNT");
      catcher.allow_ids.push_back("SB/STRANDED");
      collateral_ids(catcher.allow_ids);

      uvm_report_cb::add(null, catcher);
      `uvm_info("TEST", $sformatf(
        "NEGATIVE test: expecting checker '%s' to fire. The run FAILS if it stays silent.",
        catcher.expect_id), UVM_LOW)
    end
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    uvm_sequence_base seq = get_seq();
    phase.raise_objection(this);

    if (seq == null) begin
      `uvm_info("TEST", "No sequence for this test (base test) — idling", UVM_LOW)
      #1us;
    end else begin
      fork
        stimulus_hook();
      join_none
      if (!seq.randomize())
        `uvm_fatal("TEST/RAND", "Sequence randomization failed")
      seq.start(env.master_agent.sequencer);
      #2us;   // drain: let the monitor observe trailing beats
    end

    phase.drop_objection(this);
  endtask

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (expected_violation_id() != "") begin
      if (catcher.caught == 0)
        `uvm_error("TEST/CHECKER_SILENT", $sformatf(
          "Negative test drove an illegal stimulus but checker '%s' never fired. The checker is vacuous — it would pass a broken DUT.",
          expected_violation_id()))
      else
        `uvm_info("TEST", $sformatf(
          "Checker '%s' fired %0d time(s) as expected — detection confirmed",
          expected_violation_id(), catcher.caught), UVM_LOW)
    end
  endfunction

endclass

// ── Macro: expand one test per test case ─────────────────────────────────────
`define AXIS_MST_TEST(TC)                                                      \
class axi_stream_master_vip_``TC``_test extends axi_stream_master_vip_base_test; \
  `uvm_component_utils(axi_stream_master_vip_``TC``_test)                      \
  function new(string name, uvm_component parent);                             \
    super.new(name, parent);                                                   \
  endfunction                                                                  \
  virtual function uvm_sequence_base get_seq();                                \
    return axi_stream_master_vip_``TC``_seq::type_id::create("seq");           \
  endfunction                                                                  \
endclass

// ── Plain (positive) tests ───────────────────────────────────────────────────
`AXIS_MST_TEST(tc_mst_001)
`AXIS_MST_TEST(tc_mst_002)
`AXIS_MST_TEST(tc_mst_004)
`AXIS_MST_TEST(tc_mst_005)
`AXIS_MST_TEST(tc_mst_007)
`AXIS_MST_TEST(tc_mst_008)
`AXIS_MST_TEST(tc_mst_009)
`AXIS_MST_TEST(tc_mst_011)
`AXIS_MST_TEST(tc_mst_012)
`AXIS_MST_TEST(tc_mst_013)
`AXIS_MST_TEST(tc_mst_015)
`AXIS_MST_TEST(tc_mst_016)
`AXIS_MST_TEST(tc_mst_017)
`AXIS_MST_TEST(tc_mst_021)
`AXIS_MST_TEST(tc_mst_022)
`AXIS_MST_TEST(tc_mst_023)
`AXIS_MST_TEST(tc_mst_024)
`AXIS_MST_TEST(tc_mst_025)
`AXIS_MST_TEST(tc_mst_026)
`AXIS_MST_TEST(tc_mst_027)
`AXIS_MST_TEST(tc_mst_028)
`AXIS_MST_TEST(tc_mst_029)
`AXIS_MST_TEST(tc_mst_030)
`AXIS_MST_TEST(tc_mst_031)
`AXIS_MST_TEST(tc_mst_032)
`AXIS_MST_TEST(tc_mst_033)
`AXIS_MST_TEST(tc_mst_034)
`AXIS_MST_TEST(tc_mst_035)
`AXIS_MST_TEST(tc_mst_036)
`AXIS_MST_TEST(tc_mst_037)
`AXIS_MST_TEST(tc_mst_038)
`AXIS_MST_TEST(tc_mst_040)
`AXIS_MST_TEST(tc_mst_041)
`AXIS_MST_TEST(tc_mst_042)
`AXIS_MST_TEST(tc_mst_043)
`AXIS_MST_TEST(tc_mst_044)
`AXIS_MST_TEST(tc_mst_045)
`AXIS_MST_TEST(tc_mst_046)
`AXIS_MST_TEST(tc_mst_047)

// ── TC_MST_003 — NEGATIVE: TREADY watchdog must fire ─────────────────────────
// Shrinks the watchdog so the DUT's normal back-pressure trips it. Without the
// shrink the default 100k-cycle watchdog would never fire against a DUT that
// eventually asserts TREADY.
class axi_stream_master_vip_tc_mst_003_test extends axi_stream_master_vip_base_test;
  `uvm_component_utils(axi_stream_master_vip_tc_mst_003_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  virtual function void configure_knobs();
    agent_cfg.watchdog_cycles = 5;   // DUT stub stalls up to 100 cycles
  endfunction
  virtual function string expected_violation_id(); return "DRV/WATCHDOG"; endfunction
  // Escaping the deadlock requires dropping TVALID, which necessarily trips the
  // stability checker. Collateral of the abort, not an independent defect.
  virtual function void collateral_ids(ref string ids[$]);
    ids.push_back("CHK/TVALID_STABILITY");
  endfunction
  virtual function uvm_sequence_base get_seq();
    return axi_stream_master_vip_tc_mst_003_seq::type_id::create("seq");
  endfunction
endclass

// ── TC_MST_006 — NEGATIVE: TVALID retracted mid-stall ────────────────────────
class axi_stream_master_vip_tc_mst_006_test extends axi_stream_master_vip_base_test;
  `uvm_component_utils(axi_stream_master_vip_tc_mst_006_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  virtual function string expected_violation_id(); return "CHK/TVALID_STABILITY"; endfunction
  virtual function uvm_sequence_base get_seq();
    return axi_stream_master_vip_tc_mst_006_seq::type_id::create("seq");
  endfunction
endclass

// ── TC_MST_010 — NEGATIVE: payload mutated mid-stall ─────────────────────────
class axi_stream_master_vip_tc_mst_010_test extends axi_stream_master_vip_base_test;
  `uvm_component_utils(axi_stream_master_vip_tc_mst_010_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  virtual function string expected_violation_id(); return "CHK/PAYLOAD_STABILITY"; endfunction
  virtual function uvm_sequence_base get_seq();
    return axi_stream_master_vip_tc_mst_010_seq::type_id::create("seq");
  endfunction
endclass

// ── TC_MST_014 — PERF_THROUGHPUT: assert 1.0 beats/cycle ─────────────────────
class axi_stream_master_vip_tc_mst_014_test extends axi_stream_master_vip_base_test;
  `uvm_component_utils(axi_stream_master_vip_tc_mst_014_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  virtual function void configure_knobs();
    env_cfg.check_throughput = 1;
  endfunction
  virtual function uvm_sequence_base get_seq();
    return axi_stream_master_vip_tc_mst_014_seq::type_id::create("seq");
  endfunction
endclass

// ── TC_MST_018/019/020 — reset injected into live traffic ────────────────────
class axi_stream_master_vip_tc_mst_018_test extends axi_stream_master_vip_base_test;
  `uvm_component_utils(axi_stream_master_vip_tc_mst_018_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  virtual task stimulus_hook();
    #3us;
    `uvm_info("TEST", "Injecting asynchronous mid-packet reset", UVM_LOW)
    axi_stream_master_vip_reset_ctl::pulse_cycles = 6;
  endtask
  virtual function uvm_sequence_base get_seq();
    return axi_stream_master_vip_tc_mst_018_seq::type_id::create("seq");
  endfunction
endclass

class axi_stream_master_vip_tc_mst_019_test extends axi_stream_master_vip_base_test;
  `uvm_component_utils(axi_stream_master_vip_tc_mst_019_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  virtual task stimulus_hook();
    #4us;
    `uvm_info("TEST", "Injecting reset during an outstanding handshake", UVM_LOW)
    axi_stream_master_vip_reset_ctl::pulse_cycles = 4;
  endtask
  virtual function uvm_sequence_base get_seq();
    return axi_stream_master_vip_tc_mst_019_seq::type_id::create("seq");
  endfunction
endclass

class axi_stream_master_vip_tc_mst_020_test extends axi_stream_master_vip_base_test;
  `uvm_component_utils(axi_stream_master_vip_tc_mst_020_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  virtual task stimulus_hook();
    repeat (3) begin
      #3us;
      `uvm_info("TEST", "Injecting repeated reset pulse", UVM_LOW)
      axi_stream_master_vip_reset_ctl::pulse_cycles = $urandom_range(2, 8);
    end
  endtask
  virtual function uvm_sequence_base get_seq();
    return axi_stream_master_vip_tc_mst_020_seq::type_id::create("seq");
  endfunction
endclass

// ── TC_MST_039 — NEGATIVE: reserved qualifier encoding ───────────────────────
class axi_stream_master_vip_tc_mst_039_test extends axi_stream_master_vip_base_test;
  `uvm_component_utils(axi_stream_master_vip_tc_mst_039_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  virtual function string expected_violation_id(); return "CHK/RESERVED_QUAL"; endfunction
  virtual function uvm_sequence_base get_seq();
    return axi_stream_master_vip_tc_mst_039_seq::type_id::create("seq");
  endfunction
endclass

// ── TC_MST_048 — NEGATIVE: parity fault injection ────────────────────────────
class axi_stream_master_vip_tc_mst_048_test extends axi_stream_master_vip_base_test;
  `uvm_component_utils(axi_stream_master_vip_tc_mst_048_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  virtual function string expected_violation_id(); return "CHK/PARITY"; endfunction
  virtual function uvm_sequence_base get_seq();
    return axi_stream_master_vip_tc_mst_048_seq::type_id::create("seq");
  endfunction
endclass

`endif
