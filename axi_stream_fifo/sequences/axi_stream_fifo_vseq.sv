// ─────────────────────────────────────────────────────────────────────────────
// FIFO Master Sequence
// Sends a programmable number of clean packets of rotating lengths into the FIFO.
// Extends the master VIP base sequence so it can reuse send_clean_packet().
// ─────────────────────────────────────────────────────────────────────────────
class axi_stream_fifo_mst_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_fifo_mst_seq)
  `uvm_declare_p_sequencer(axi_stream_master_vip_sequencer)

  int unsigned num_packets = 20;

  function new(string name = "axi_stream_fifo_mst_seq");
    super.new(name);
  endfunction

  virtual task body();
    // Packet lengths to rotate through: 1, 4, 8, 16, 32 beats
    int unsigned lengths[$] = '{1, 4, 8, 16, 32};
    for (int unsigned i = 0; i < num_packets; i++) begin
      int unsigned plen = lengths[i % lengths.size()];
      send_clean_packet(.num_beats(plen), .tid(logic'(i[7:0])));
      `uvm_info("FIFO_MST_SEQ", $sformatf(
        "Sent packet #%0d  length=%0d beats  TID=0x%02h", i, plen, i[7:0]), UVM_MEDIUM)
    end
  endtask

endclass

// ─────────────────────────────────────────────────────────────────────────────
// FIFO Slave Sequence
// Generates a stream of TREADY control items with randomized back-pressure.
// num_items must be set large enough to cover the full master traffic.
// ─────────────────────────────────────────────────────────────────────────────
class axi_stream_fifo_slv_seq extends axi_stream_slave_vip_base_seq;
  `uvm_object_utils(axi_stream_fifo_slv_seq)

  function new(string name = "axi_stream_fifo_slv_seq");
    super.new(name);
    num_items = 2000;  // large enough for default num_packets workload
  endfunction

  // Uses the inherited body() which randomizes each item
endclass

// ─────────────────────────────────────────────────────────────────────────────
// FIFO Virtual Sequence
// Orchestrates master and slave sub-sequences simultaneously.
// Hold handles to both sequencers; the test sets them before calling start().
// ─────────────────────────────────────────────────────────────────────────────
class axi_stream_fifo_vseq extends uvm_sequence;
  `uvm_object_utils(axi_stream_fifo_vseq)

  // Set by the test before start()
  axi_stream_master_vip_sequencer mst_seqr;
  axi_stream_slave_vip_sequencer  slv_seqr;

  int unsigned num_packets = 20;

  function new(string name = "axi_stream_fifo_vseq");
    super.new(name);
  endfunction

  virtual task body();
    axi_stream_fifo_mst_seq mst_seq;
    axi_stream_fifo_slv_seq slv_seq;

    if (mst_seqr == null) `uvm_fatal("VSEQ", "mst_seqr not set on axi_stream_fifo_vseq")
    if (slv_seqr == null) `uvm_fatal("VSEQ", "slv_seqr not set on axi_stream_fifo_vseq")

    mst_seq             = axi_stream_fifo_mst_seq::type_id::create("mst_seq");
    slv_seq             = axi_stream_fifo_slv_seq::type_id::create("slv_seq");
    mst_seq.num_packets = num_packets;

    // Run slave TREADY generation in background; master drives packets in foreground
    fork
      slv_seq.start(slv_seqr);
    join_none

    mst_seq.start(mst_seqr);

    // After master finishes, let the FIFO drain (last few beats reach slave)
    #5000;
    `uvm_info("VSEQ", "Master traffic complete — drain window elapsed", UVM_NONE)
  endtask

endclass
