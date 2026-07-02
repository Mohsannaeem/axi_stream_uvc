// AXI-Stream FIFO Scoreboard
//
// Verifies data integrity through the FIFO:
//   Master monitor  → write_mst()   adds one beat to the expected queue
//   Slave  monitor  → write_slv()   pops expected queue, compares field-by-field
//
// Both monitors write one item per completed AXI handshake beat (not per packet),
// so comparison is beat-by-beat in arrival order.  The FIFO preserves order, so
// the expected and actual queues must drain in perfect lock-step.
`uvm_analysis_imp_decl(_mst)
`uvm_analysis_imp_decl(_slv)

class axi_stream_fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_stream_fifo_scoreboard)

  uvm_analysis_imp_mst #(axi_stream_master_vip_seq_item, axi_stream_fifo_scoreboard) mst_export;
  uvm_analysis_imp_slv #(axi_stream_slave_vip_seq_item,  axi_stream_fifo_scoreboard) slv_export;

  // Expected beats queued by master monitor; consumed by slave monitor
  axi_stream_master_vip_seq_item expected_q[$];

  int unsigned beats_checked  = 0;
  int unsigned beats_mismatch = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mst_export = new("mst_export", this);
    slv_export = new("slv_export", this);
  endfunction

  // ── Master monitor writes a beat item here (driven into FIFO) ──────────────
  function void write_mst(axi_stream_master_vip_seq_item item);
    axi_stream_master_vip_seq_item copy;
    $cast(copy, item.clone());
    expected_q.push_back(copy);
    `uvm_info("FIFO_SCB", $sformatf(
      "[MST→FIFO] ENQUEUE beat#%0d  TDATA=0x%08h TKEEP=%04b TLAST=%0b TID=0x%02h",
      beats_checked + expected_q.size() - 1,
      item.tdata, item.tkeep, item.tlast, item.tid), UVM_HIGH)
  endfunction

  // ── Slave monitor writes a beat item here (read out of FIFO) ───────────────
  function void write_slv(axi_stream_slave_vip_seq_item item);
    axi_stream_master_vip_seq_item exp;

    if (expected_q.size() == 0) begin
      `uvm_error("FIFO_SCB",
        $sformatf("[FIFO_SCB] OUT-OF-ORDER: Slave received beat but expected queue is empty | TDATA=0x%08h TLAST=%0b",
          item.tdata, item.tlast))
      return;
    end

    exp = expected_q.pop_front();
    beats_checked++;

    if (item.tdata  !== exp.tdata  ||
        item.tkeep  !== exp.tkeep  ||
        item.tstrb  !== exp.tstrb  ||
        item.tlast  !== exp.tlast  ||
        item.tid    !== exp.tid    ||
        item.tdest  !== exp.tdest  ||
        item.tuser  !== exp.tuser) begin

      beats_mismatch++;
      `uvm_error("FIFO_SCB", $sformatf(
        "[MISMATCH] beat#%0d\n  EXP: TDATA=0x%08h TKEEP=%04b TSTRB=%04b TLAST=%0b TID=0x%02h TDEST=0x%0h TUSER=0x%0h\n  GOT: TDATA=0x%08h TKEEP=%04b TSTRB=%04b TLAST=%0b TID=0x%02h TDEST=0x%0h TUSER=0x%0h",
        beats_checked - 1,
        exp.tdata,  exp.tkeep,  exp.tstrb,  exp.tlast,  exp.tid,  exp.tdest,  exp.tuser,
        item.tdata, item.tkeep, item.tstrb, item.tlast, item.tid, item.tdest, item.tuser))
    end else begin
      `uvm_info("FIFO_SCB", $sformatf(
        "[MATCH] beat#%0d TDATA=0x%08h TKEEP=%04b TLAST=%0b TID=0x%02h",
        beats_checked - 1, item.tdata, item.tkeep, item.tlast, item.tid), UVM_HIGH)
    end
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (expected_q.size() != 0)
      `uvm_error("FIFO_SCB", $sformatf(
        "[FIFO_SCB] %0d beats were driven into the FIFO but never received on master port",
        expected_q.size()))
    `uvm_info("FIFO_SCB", $sformatf(
      "[SUMMARY] beats_checked=%0d  mismatches=%0d  pending=%0d",
      beats_checked, beats_mismatch, expected_q.size()), UVM_NONE)
  endfunction

endclass
