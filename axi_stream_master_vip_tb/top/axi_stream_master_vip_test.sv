// AXI-Stream Master VIP Base Test
// All 48 TC tests extend this base to get env + config setup.
class axi_stream_master_vip_base_test extends uvm_test;
  `uvm_component_utils(axi_stream_master_vip_base_test)

  axi_stream_master_vip_env        env;
  axi_stream_master_vip_env_config env_cfg;
  axi_stream_master_vip_agent_config mst_cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env_cfg = axi_stream_master_vip_env_config::type_id::create("env_cfg");
    mst_cfg = axi_stream_master_vip_agent_config::type_id::create("mst_cfg");

    if (!uvm_config_db #(virtual axi_stream_master_vip_if)::get(this, "", "vif", mst_cfg.vif))
      `uvm_fatal("CFG", "No VIF for test — check tb_top uvm_config_db::set")

    env_cfg.mst_cfg    = mst_cfg;
    env_cfg.has_scoreboard = 1;

    uvm_config_db #(axi_stream_master_vip_env_config)::set(this, "env", "env_cfg", env_cfg);
    env = axi_stream_master_vip_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    run_test_body(phase);
    phase.drop_objection(this);
  endtask

  virtual task run_test_body(uvm_phase phase);
    `uvm_fatal("BASE_TEST", "run_test_body() not overridden!")
  endtask

endclass

// ── Individual TC Tests (one per sequence) ────────────────────────────────────

`define DEFINE_MST_TEST(TC_NUM) \
class axi_stream_master_vip_tc_mst_``TC_NUM``_test extends axi_stream_master_vip_base_test; \
  `uvm_component_utils(axi_stream_master_vip_tc_mst_``TC_NUM``_test) \
  function new(string name, uvm_component parent); super.new(name, parent); endfunction \
  virtual task run_test_body(uvm_phase phase); \
    axi_stream_master_vip_tc_mst_``TC_NUM``_seq seq; \
    seq = axi_stream_master_vip_tc_mst_``TC_NUM``_seq::type_id::create("seq"); \
    seq.start(env.mst_agent.seqr); \
  endtask \
endclass

`DEFINE_MST_TEST(001)
`DEFINE_MST_TEST(002)
`DEFINE_MST_TEST(003)
`DEFINE_MST_TEST(004)
`DEFINE_MST_TEST(005)
`DEFINE_MST_TEST(006)
`DEFINE_MST_TEST(007)
`DEFINE_MST_TEST(008)
`DEFINE_MST_TEST(009)
`DEFINE_MST_TEST(010)
`DEFINE_MST_TEST(011)
`DEFINE_MST_TEST(012)
`DEFINE_MST_TEST(013)
`DEFINE_MST_TEST(014)
`DEFINE_MST_TEST(015)
`DEFINE_MST_TEST(016)
`DEFINE_MST_TEST(017)
`DEFINE_MST_TEST(018)
`DEFINE_MST_TEST(019)
`DEFINE_MST_TEST(020)
`DEFINE_MST_TEST(021)
`DEFINE_MST_TEST(022)
`DEFINE_MST_TEST(023)
`DEFINE_MST_TEST(024)
`DEFINE_MST_TEST(025)
`DEFINE_MST_TEST(026)
`DEFINE_MST_TEST(027)
`DEFINE_MST_TEST(028)
`DEFINE_MST_TEST(029)
`DEFINE_MST_TEST(030)
`DEFINE_MST_TEST(031)
`DEFINE_MST_TEST(032)
`DEFINE_MST_TEST(033)
`DEFINE_MST_TEST(034)
`DEFINE_MST_TEST(035)
`DEFINE_MST_TEST(036)
`DEFINE_MST_TEST(037)
`DEFINE_MST_TEST(038)
`DEFINE_MST_TEST(039)
`DEFINE_MST_TEST(040)
`DEFINE_MST_TEST(041)
`DEFINE_MST_TEST(042)
`DEFINE_MST_TEST(043)
`DEFINE_MST_TEST(044)
`DEFINE_MST_TEST(045)
`DEFINE_MST_TEST(046)
`DEFINE_MST_TEST(047)
`DEFINE_MST_TEST(048)
