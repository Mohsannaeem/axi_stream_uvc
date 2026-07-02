// AXI-Stream FIFO Base Test
//
// Retrieves both VIF handles from the config DB, builds the env config,
// and runs the virtual sequence that drives the full master→FIFO→slave path.
class axi_stream_fifo_base_test extends uvm_test;
  `uvm_component_utils(axi_stream_fifo_base_test)

  axi_stream_fifo_env        env;
  axi_stream_fifo_env_config env_cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    virtual axi_stream_master_vip_if  mst_vif_h;
    virtual axi_stream_slave_vip_if   slv_vif_h;

    super.build_phase(phase);

    // ── Retrieve VIFs set by tb_top ─────────────────────────────────────────
    if (!uvm_config_db #(virtual axi_stream_master_vip_if)::get(
          this, "", "mst_vif", mst_vif_h))
      `uvm_fatal("CFG", "axi_stream_fifo_base_test: mst_vif not found in config DB")

    if (!uvm_config_db #(virtual axi_stream_slave_vip_if)::get(
          this, "", "slv_vif", slv_vif_h))
      `uvm_fatal("CFG", "axi_stream_fifo_base_test: slv_vif not found in config DB")

    // ── Build env config with the two VIFs ──────────────────────────────────
    env_cfg         = axi_stream_fifo_env_config::type_id::create("env_cfg");
    env_cfg.mst_cfg.vif = mst_vif_h;
    env_cfg.slv_cfg.vif = slv_vif_h;

    // Optional: disable per-VIP trackers to avoid log clutter in this TB
    env_cfg.mst_cfg.enable_tracker = 0;
    env_cfg.slv_cfg.enable_tracker = 0;

    uvm_config_db #(axi_stream_fifo_env_config)::set(this, "env", "env_cfg", env_cfg);

    env = axi_stream_fifo_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    axi_stream_fifo_vseq vseq;
    phase.raise_objection(this);

    vseq          = axi_stream_fifo_vseq::type_id::create("vseq");
    vseq.mst_seqr = env.mst_agent.seqr;
    vseq.slv_seqr = env.slv_agent.sqr;

    vseq.start(null);

    phase.drop_objection(this);
  endtask

endclass
