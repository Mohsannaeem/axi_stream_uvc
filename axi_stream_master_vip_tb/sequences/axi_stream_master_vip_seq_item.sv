// =============================================================================
// AXI5-Stream Master VIP — Sequence Item
// One item == one logical PACKET. Payload is queue-based, one entry per beat
// (uvc_generator SKILL: "Queue-Based Payload"). TID/TDEST are packet-scoped and
// constant across all beats, per Section 2.7, Page 27.
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_SEQ_ITEM_SV
`define AXI_STREAM_MASTER_VIP_SEQ_ITEM_SV

class axi_stream_master_vip_seq_item extends uvm_sequence_item;

  // ── Packet shape ──────────────────────────────────────────────────────────
  rand int unsigned            packet_beats;

  // ── Payload: one queue entry per beat ─────────────────────────────────────
  rand logic [`AXI_DATA_W-1:0] data[$];
  rand logic [`AXI_STRB_W-1:0] keep[$];
  rand logic [`AXI_STRB_W-1:0] strb[$];

  // ── Packet-scoped identity (constant for every beat — REQ_MST_11) ─────────
  rand logic [`AXI_ID_W-1:0]   id;
  rand logic [`AXI_DEST_W-1:0] dest;
  rand logic [`AXI_USER_W-1:0] user;

  // ── Timing ────────────────────────────────────────────────────────────────
  rand int unsigned inter_beat_delay[$];   // idle cycles before each beat
  rand int unsigned wakeup_lead_cycles;    // >= 1 when HAS_WAKE (REQ_MST_12)

  // ── Negative-test violation knobs (held at 0 by c_legal) ──────────────────
  rand bit inject_tvalid_drop;     // TC_MST_006 — retract TVALID mid-stall
  rand bit inject_parity_fault;    // TC_MST_048 — flip one TDATACHK bit
  rand bit inject_reserved_qual;   // TC_MST_039 — drive TKEEP=0 with TSTRB=1
  rand bit inject_payload_mutate;  // TC_MST_010 — mutate payload during stall

  `uvm_object_utils_begin(axi_stream_master_vip_seq_item)
    `uvm_field_int(packet_beats,           UVM_ALL_ON | UVM_DEC)
    `uvm_field_queue_int(data,             UVM_ALL_ON | UVM_HEX)
    `uvm_field_queue_int(keep,             UVM_ALL_ON | UVM_BIN)
    `uvm_field_queue_int(strb,             UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(id,                     UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(dest,                   UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(user,                   UVM_ALL_ON | UVM_HEX)
    `uvm_field_queue_int(inter_beat_delay, UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(wakeup_lead_cycles,     UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(inject_tvalid_drop,     UVM_ALL_ON)
    `uvm_field_int(inject_parity_fault,    UVM_ALL_ON)
    `uvm_field_int(inject_reserved_qual,   UVM_ALL_ON)
    `uvm_field_int(inject_payload_mutate,  UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "axi_stream_master_vip_seq_item");
    super.new(name);
  endfunction

  // ── Constraints ───────────────────────────────────────────────────────────
  constraint c_beats {
    packet_beats inside {[1:`MAX_PACKET_BEATS]};
  }

  constraint c_queue_size {
    data.size()             == packet_beats;
    keep.size()             == packet_beats;
    strb.size()             == packet_beats;
    inter_beat_delay.size() == packet_beats;
  }

  constraint c_delay {
    foreach (inter_beat_delay[i])
      inter_beat_delay[i] inside {[0:`TREADY_STALL_MAX]};
  }

  constraint c_wake {
    wakeup_lead_cycles inside {[1:8]};
  }

  // TSTRB=1 requires TKEEP=1. The TKEEP=0/TSTRB=1 pair is a reserved encoding
  // (Section 2.5, Page 24) and must never appear in legal traffic.
  constraint c_qualifier_legal {
    if (!inject_reserved_qual)
      foreach (strb[i]) (strb[i] & ~keep[i]) == '0;
  }

  // ── Legality constraint ───────────────────────────────────────────────────
  // Negative sequences MUST call c_legal.constraint_mode(0) BEFORE randomize()
  // and then force the knob inside the randomize()..with block. Randomizing
  // first and assigning the knob afterwards produces a legal item, and the
  // negative test passes without ever driving the violation it claims to test.
  constraint c_legal {
    inject_tvalid_drop    == 0;
    inject_parity_fault   == 0;
    inject_reserved_qual  == 0;
    inject_payload_mutate == 0;
  }

  // ── Qualifier-aware comparison (REQ_MST_09) ───────────────────────────────
  // Compares TDATA masked by TKEEP. Comparing the raw bus raises false
  // mismatches on null-byte lanes of entirely legal sparse traffic.
  function bit compare_masked(axi_stream_master_vip_seq_item rhs);
    if (rhs == null)                        return 0;
    if (packet_beats != rhs.packet_beats)   return 0;
    if (id   !== rhs.id)                    return 0;
    if (dest !== rhs.dest)                  return 0;
    foreach (data[i]) begin
      if (keep[i] !== rhs.keep[i]) return 0;
      if (strb[i] !== rhs.strb[i]) return 0;
      for (int b = 0; b < `AXI_STRB_W; b++)
        if (keep[i][b] && (data[i][8*b +: 8] !== rhs.data[i][8*b +: 8]))
          return 0;   // only transported bytes are compared
    end
    return 1;
  endfunction

  // Data bytes are TKEEP=1 AND TSTRB=1. A TKEEP=1/TSTRB=0 lane is a POSITION
  // byte: transported, but not payload (Section 2.5, Page 24 — REQ_MST_10).
  function int unsigned data_byte_count();
    data_byte_count = 0;
    foreach (keep[i])
      for (int b = 0; b < `AXI_STRB_W; b++)
        if (keep[i][b] && strb[i][b]) data_byte_count++;
  endfunction

  function string convert2string();
    return $sformatf("PKT | beats=%0d TID=0x%0h TDEST=0x%0h data_bytes=%0d",
                     packet_beats, id, dest, data_byte_count());
  endfunction

endclass

`endif
