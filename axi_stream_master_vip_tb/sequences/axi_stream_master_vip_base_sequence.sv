// AXI-Stream Master VIP Base Sequence
// All test sequences extend this class for common helpers.
class axi_stream_master_vip_base_sequence extends uvm_sequence #(axi_stream_master_vip_seq_item);
  `uvm_object_utils(axi_stream_master_vip_base_sequence)
  `uvm_declare_p_sequencer(axi_stream_master_vip_sequencer)

  function new(string name = "axi_stream_master_vip_base_sequence");
    super.new(name);
  endfunction

  // ── Transmit one randomized packet ─────────────────────────────────────────────
  task send_packet(
    int unsigned num_beats    = 1,
    logic [AXI_ID_W-1:0]   tid     = '0,
    logic [AXI_DEST_W-1:0] tdest   = '0,
    logic [AXI_STRB_W-1:0] tkeep   = '1,
    logic [AXI_STRB_W-1:0] tstrb   = '1
  );
    axi_stream_master_vip_seq_item pkt;
    pkt = axi_stream_master_vip_seq_item::type_id::create("pkt");
    start_item(pkt);
    if (!pkt.randomize() with {
          packet_length == num_beats;
          pkt.tid       == tid;
          pkt.tdest     == tdest;
          pkt.tkeep     == tkeep;
          pkt.tstrb     == tstrb;
        })
      `uvm_fatal("RAND", "randomize failed in base_sequence::send_packet")
    finish_item(pkt);
  endtask

  // ── Transmit with all violation knobs off ──────────────────────────────────────
  task send_clean_packet(int unsigned num_beats = 1,
                         logic [AXI_ID_W-1:0] tid = '0);
    send_packet(.num_beats(num_beats), .tid(tid));
  endtask

  // ── Transmit a null-termination packet (TKEEP=0 on final beat) ────────────────
  task send_null_term_packet(logic [AXI_ID_W-1:0] tid = '0);
    axi_stream_master_vip_seq_item pkt;
    pkt = axi_stream_master_vip_seq_item::type_id::create("pkt_null");
    start_item(pkt);
    if (!pkt.randomize() with {
          packet_length == 1;
          pkt.tid   == tid;
          pkt.tkeep == '0;
          pkt.tstrb == '0;
          pkt.tlast == 1'b1;
        })
      `uvm_fatal("RAND", "randomize failed in send_null_term_packet")
    finish_item(pkt);
  endtask

  // ── Transmit a packet with violation injection ─────────────────────────────────
  task send_violation_packet(
    bit drop_valid_early           = 0,
    bit inject_invalid_tstrb_tkeep = 0,
    bit change_tid_mid_packet      = 0,
    bit parity_inject_error        = 0,
    int parity_error_byte_idx      = 0,
    int unsigned num_beats         = 4
  );
    axi_stream_master_vip_seq_item pkt;
    pkt = axi_stream_master_vip_seq_item::type_id::create("pkt_viol");
    pkt.drop_valid_early           = drop_valid_early;
    pkt.inject_invalid_tstrb_tkeep = inject_invalid_tstrb_tkeep;
    pkt.change_tid_mid_packet      = change_tid_mid_packet;
    pkt.parity_inject_error        = parity_inject_error;
    pkt.parity_error_byte_idx      = parity_error_byte_idx;
    start_item(pkt);
    if (!pkt.randomize() with { packet_length == num_beats; })
      `uvm_fatal("RAND", "randomize failed in send_violation_packet")
    finish_item(pkt);
  endtask

  // ── Run body must be provided by child class ───────────────────────────────────
  virtual task body();
    `uvm_fatal("BASE_SEQ", "body() not overridden in base_sequence")
  endtask

endclass
