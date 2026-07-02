// AXI-Stream FIFO Top-Level Environment
//
// Instantiates the Master VIP agent (drives FIFO slave port) and the Slave VIP
// agent (reads FIFO master port) side-by-side, then wires both analysis ports
// to the FIFO scoreboard for in-order data integrity checking.
//
// DUT topology:
//   Master VIP → [FIFO slave port] ──FIFO──  [FIFO master port] → Slave VIP
//
// The individual VIP envs (axi_stream_master_vip_env / axi_stream_slave_vip_env)
// are NOT used here.  Only their agents are instantiated directly so that a
// single FIFO scoreboard can observe both sides without duplicating the per-VIP
// scoreboards.
class axi_stream_fifo_env extends uvm_env;
  `uvm_component_utils(axi_stream_fifo_env)

  axi_stream_master_vip_agent  mst_agent;
  axi_stream_slave_vip_agent   slv_agent;
  axi_stream_fifo_scoreboard   scb;
  axi_stream_fifo_env_config   cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(axi_stream_fifo_env_config)::get(this, "", "env_cfg", cfg))
      `uvm_fatal("CFG", "axi_stream_fifo_env: could not get env_cfg from config DB")

    // ── Master agent — active, drives FIFO slave port ────────────────────────
    uvm_config_db #(axi_stream_master_vip_agent_config)::set(
      this, "mst_agent", "cfg", cfg.mst_cfg);
    mst_agent = axi_stream_master_vip_agent::type_id::create("mst_agent", this);

    // ── Slave agent — active, reads FIFO master port ─────────────────────────
    uvm_config_db #(axi_stream_slave_vip_agent_config)::set(
      this, "slv_agent", "cfg", cfg.slv_cfg);
    slv_agent = axi_stream_slave_vip_agent::type_id::create("slv_agent", this);

    // ── FIFO scoreboard ──────────────────────────────────────────────────────
    if (cfg.has_scoreboard)
      scb = axi_stream_fifo_scoreboard::type_id::create("scb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    if (cfg.has_scoreboard) begin
      // Master monitor beats (written to FIFO) → scoreboard expected queue
      mst_agent.ap.connect(scb.mst_export);
      // Slave monitor beats (read from FIFO) → scoreboard actual comparison
      slv_agent.ap.connect(scb.slv_export);
    end
  endfunction

endclass
