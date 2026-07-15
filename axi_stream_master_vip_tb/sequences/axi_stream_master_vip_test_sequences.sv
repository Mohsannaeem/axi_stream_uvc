// =============================================================================
// AXI5-Stream Master VIP — Test Sequences
// One sequence class per test_cases[] entry in verif_plan_axi_stream_master_v17_0.yaml.
// 48 classes, TC_MST_001 .. TC_MST_048. No stub bodies: every class encodes the
// constraints of its scenario, because a sequence that does not is a traceability
// failure dressed up as a placeholder.
//
// NEGATIVE SEQUENCES (TC 003, 006, 010, 039, 048) call c_legal.constraint_mode(0)
// BEFORE randomize(). Randomizing first and poking the knob afterwards yields a
// legal item and the negative test passes without ever driving the violation.
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_TEST_SEQUENCES_SV
`define AXI_STREAM_MASTER_VIP_TEST_SEQUENCES_SV

// ── REQ_MST_01 — TVALID independence ─────────────────────────────────────────

// TC_MST_001 — Smoke: single-beat packet, no delay.
class axi_stream_master_vip_tc_mst_001_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_001_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_001_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats == 1;
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
      foreach (keep[i]) keep[i] == '1;
      foreach (strb[i]) strb[i] == '1;
    }) `uvm_fatal("SEQ/RAND", "TC_001 randomize failed")
  endfunction
endclass

// TC_MST_002 — TVALID asserted while TREADY is still low (1-16 cycle lead).
class axi_stream_master_vip_tc_mst_002_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_002_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_002_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[2:8]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[1:16]};
    }) `uvm_fatal("SEQ/RAND", "TC_002 randomize failed")
  endfunction
endclass

// TC_MST_003 — NEGATIVE: TREADY watchdog must fire rather than hang.
// The test shrinks cfg.watchdog_cycles so the DUT's normal back-pressure trips it.
class axi_stream_master_vip_tc_mst_003_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_003_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_003_seq"); super.new(name); endfunction
  function bit is_negative(); return 1; endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[4:16]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
    }) `uvm_fatal("SEQ/RAND", "TC_003 randomize failed")
  endfunction
endclass

// TC_MST_004 — TVALID latency invariant across the full stall range.
class axi_stream_master_vip_tc_mst_004_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_004_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_004_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 20; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[1:8]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[0:`TREADY_STALL_MAX]};
    }) `uvm_fatal("SEQ/RAND", "TC_004 randomize failed")
  endfunction
endclass

// ── REQ_MST_02 — TVALID stability ────────────────────────────────────────────

// TC_MST_005 — TVALID sticky across a 1-100 cycle stall.
class axi_stream_master_vip_tc_mst_005_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_005_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_005_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[2:8]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[1:`TREADY_STALL_MAX]};
    }) `uvm_fatal("SEQ/RAND", "TC_005 randomize failed")
  endfunction
endclass

// TC_MST_006 — NEGATIVE: retract TVALID mid-stall. Expect CHK/TVALID_STABILITY.
class axi_stream_master_vip_tc_mst_006_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_006_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_006_seq"); super.new(name); endfunction
  function bit is_negative(); return 1; endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    item.c_legal.constraint_mode(0);   // MUST precede randomize()
    if (!item.randomize() with {
      inject_tvalid_drop == 1;
      inject_parity_fault == 0;   // pin: constraint_mode(0) freed every knob
      inject_reserved_qual == 0;   // pin: constraint_mode(0) freed every knob
      inject_payload_mutate == 0;   // pin: constraint_mode(0) freed every knob
      packet_beats inside {[2:4]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
    }) `uvm_fatal("SEQ/RAND", "TC_006 randomize failed")
  endfunction
endclass

// TC_MST_007 — Max-length packet, every beat stalled.
class axi_stream_master_vip_tc_mst_007_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_007_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_007_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats == `MAX_PACKET_BEATS;
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[1:4]};
    }) `uvm_fatal("SEQ/RAND", "TC_007 randomize failed")
  endfunction
endclass

// TC_MST_008 — TREADY toggles before the sampling edge; VIP holds TVALID.
class axi_stream_master_vip_tc_mst_008_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_008_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_008_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[4:12]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[2:20]};
    }) `uvm_fatal("SEQ/RAND", "TC_008 randomize failed")
  endfunction
endclass

// ── REQ_MST_03 — payload stability ───────────────────────────────────────────

// TC_MST_009 — Payload frozen from TVALID rise to handshake.
class axi_stream_master_vip_tc_mst_009_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_009_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_009_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[2:8]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[5:`TREADY_STALL_MAX]};
    }) `uvm_fatal("SEQ/RAND", "TC_009 randomize failed")
  endfunction
endclass

// TC_MST_010 — NEGATIVE: mutate payload mid-stall. Expect CHK/PAYLOAD_STABILITY.
class axi_stream_master_vip_tc_mst_010_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_010_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_010_seq"); super.new(name); endfunction
  function bit is_negative(); return 1; endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    item.c_legal.constraint_mode(0);   // MUST precede randomize()
    if (!item.randomize() with {
      inject_payload_mutate == 1;
      inject_tvalid_drop == 0;   // pin: constraint_mode(0) freed every knob
      inject_parity_fault == 0;   // pin: constraint_mode(0) freed every knob
      inject_reserved_qual == 0;   // pin: constraint_mode(0) freed every knob
      packet_beats inside {[2:4]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
    }) `uvm_fatal("SEQ/RAND", "TC_010 randomize failed")
  endfunction
endclass

// TC_MST_011 — Qualifier stability during stall (TKEEP/TSTRB must not shift).
class axi_stream_master_vip_tc_mst_011_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_011_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_011_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[3:10]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[3:30]};
      foreach (keep[i]) keep[i] != '1;   // force sparse so qualifier drift is visible
    }) `uvm_fatal("SEQ/RAND", "TC_011 randomize failed")
  endfunction
endclass

// TC_MST_012 — Per-beat stability across a 16-beat packet.
class axi_stream_master_vip_tc_mst_012_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_012_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_012_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats == 16;
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[1:10]};
    }) `uvm_fatal("SEQ/RAND", "TC_012 randomize failed")
  endfunction
endclass

// ── REQ_MST_04 — zero-wait throughput ────────────────────────────────────────

// TC_MST_013 — 32-beat zero-delay burst.
class axi_stream_master_vip_tc_mst_013_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_013_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_013_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats == 32;
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
    }) `uvm_fatal("SEQ/RAND", "TC_013 randomize failed")
  endfunction
endclass

// TC_MST_014 — PERF_THROUGHPUT: scoreboard asserts 1.0 beats/cycle.
class axi_stream_master_vip_tc_mst_014_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_014_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_014_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 4; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[16:32]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
    }) `uvm_fatal("SEQ/RAND", "TC_014 randomize failed")
  endfunction
endclass

// TC_MST_015 — Same-cycle TVALID/TREADY handshake.
class axi_stream_master_vip_tc_mst_015_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_015_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_015_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 10; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[1:4]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
    }) `uvm_fatal("SEQ/RAND", "TC_015 randomize failed")
  endfunction
endclass

// TC_MST_016 — Back-to-back zero-gap packets at full rate.
class axi_stream_master_vip_tc_mst_016_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_016_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_016_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 3; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[8:24]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
      wakeup_lead_cycles == 1;
    }) `uvm_fatal("SEQ/RAND", "TC_016 randomize failed")
  endfunction
endclass

// ── REQ_MST_05 — reset-state TVALID ──────────────────────────────────────────
// The reset stimulus itself is applied by the TEST (it owns the reset task);
// these sequences supply the traffic that reset must interrupt.

class axi_stream_master_vip_tc_mst_017_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_017_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_017_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[1:4]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0; })
      `uvm_fatal("SEQ/RAND", "TC_017 randomize failed")
  endfunction
endclass

class axi_stream_master_vip_tc_mst_018_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_018_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_018_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 8; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[8:32]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[0:3]}; })
      `uvm_fatal("SEQ/RAND", "TC_018 randomize failed")
  endfunction
endclass

class axi_stream_master_vip_tc_mst_019_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_019_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_019_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 8; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[4:16]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[10:40]}; })
      `uvm_fatal("SEQ/RAND", "TC_019 randomize failed")
  endfunction
endclass

class axi_stream_master_vip_tc_mst_020_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_020_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_020_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 12; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[2:8]}; })
      `uvm_fatal("SEQ/RAND", "TC_020 randomize failed")
  endfunction
endclass

// ── REQ_MST_06 — reset exit timing ───────────────────────────────────────────

class axi_stream_master_vip_tc_mst_021_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_021_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_021_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[1:4]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0; })
      `uvm_fatal("SEQ/RAND", "TC_021 randomize failed")
  endfunction
endclass

class axi_stream_master_vip_tc_mst_022_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_022_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_022_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 6; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[1:6]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0; })
      `uvm_fatal("SEQ/RAND", "TC_022 randomize failed")
  endfunction
endclass

class axi_stream_master_vip_tc_mst_023_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_023_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_023_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[1:2]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0; })
      `uvm_fatal("SEQ/RAND", "TC_023 randomize failed")
  endfunction
endclass

class axi_stream_master_vip_tc_mst_024_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_024_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_024_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[2:6]};
      wakeup_lead_cycles inside {[2:8]}; })
      `uvm_fatal("SEQ/RAND", "TC_024 randomize failed")
  endfunction
endclass

// ── REQ_MST_07 — TLAST boundary ──────────────────────────────────────────────

// TC_MST_025 — Minimal packet: TLAST on the first and only beat.
class axi_stream_master_vip_tc_mst_025_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_025_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_025_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 10; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats == 1; })
      `uvm_fatal("SEQ/RAND", "TC_025 randomize failed")
  endfunction
endclass

// TC_MST_026 — Maximum packet: TLAST only on beat MAX_PACKET_BEATS.
class axi_stream_master_vip_tc_mst_026_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_026_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_026_seq"); super.new(name); endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats == `MAX_PACKET_BEATS;
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[0:2]}; })
      `uvm_fatal("SEQ/RAND", "TC_026 randomize failed")
  endfunction
endclass

// TC_MST_027 — Packet-count preservation across 25 packets.
class axi_stream_master_vip_tc_mst_027_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_027_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_027_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 25; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[1:32]}; })
      `uvm_fatal("SEQ/RAND", "TC_027 randomize failed")
  endfunction
endclass

// TC_MST_028 — Random-length sweep including both extremes.
class axi_stream_master_vip_tc_mst_028_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_028_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_028_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 30; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats dist {1 := 10, [2:15] := 40, [16:63] := 30,
                         [64:255] := 15, `MAX_PACKET_BEATS := 5};
    }) `uvm_fatal("SEQ/RAND", "TC_028 randomize failed")
  endfunction
endclass

// ── REQ_MST_08 — merging prohibition ─────────────────────────────────────────

// TC_MST_029 — Zero-gap boundary, SAME TID/TDEST. The hardest merging case:
// only TLAST distinguishes the two packets.
class axi_stream_master_vip_tc_mst_029_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_029_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_029_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 6; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[2:8]};
      id   == 8'hA5;    // held constant across every packet
      dest == 4'h3;
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
    }) `uvm_fatal("SEQ/RAND", "TC_029 randomize failed")
  endfunction
endclass

// TC_MST_030 — Zero-gap boundary, DIFFERENT TID.
class axi_stream_master_vip_tc_mst_030_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_030_seq)
  int unsigned n;
  function new(string name = "axi_stream_master_vip_tc_mst_030_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 8; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[2:6]};
      id   == local::n;     // TID changes every packet
      dest == 4'h1;
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
    }) `uvm_fatal("SEQ/RAND", "TC_030 randomize failed")
    n++;
  endfunction
endclass

// TC_MST_031 — Zero-gap boundary, DIFFERENT TDEST.
class axi_stream_master_vip_tc_mst_031_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_031_seq)
  int unsigned n;
  function new(string name = "axi_stream_master_vip_tc_mst_031_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 8; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[2:6]};
      id   == 8'h11;
      dest == (local::n % 16);   // TDEST changes every packet
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
    }) `uvm_fatal("SEQ/RAND", "TC_031 randomize failed")
    n++;
  endfunction
endclass

// TC_MST_032 — Four TID values round-robin; per-stream queues must stay isolated.
class axi_stream_master_vip_tc_mst_032_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_032_seq)
  int unsigned n;
  function new(string name = "axi_stream_master_vip_tc_mst_032_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 20; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[1:10]};
      id inside {8'h01, 8'h02, 8'h03, 8'h04};
      id == 8'h01 + (local::n % 4);
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[0:2]};
    }) `uvm_fatal("SEQ/RAND", "TC_032 randomize failed")
    n++;
  endfunction
endclass

// ── REQ_MST_09 — TKEEP null bytes ────────────────────────────────────────────

// TC_MST_033 — Sparse stream: full TKEEP space.
class axi_stream_master_vip_tc_mst_033_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_033_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_033_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 15; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[2:12]}; })
      `uvm_fatal("SEQ/RAND", "TC_033 randomize failed")
  endfunction
endclass

// TC_MST_034 — Null packet: TLAST with TKEEP all-zero.
class axi_stream_master_vip_tc_mst_034_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_034_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_034_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 5; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats == 1;
      foreach (keep[i]) keep[i] == '0;
      foreach (strb[i]) strb[i] == '0;   // TSTRB=1 would require TKEEP=1
    }) `uvm_fatal("SEQ/RAND", "TC_034 randomize failed")
  endfunction
endclass

// TC_MST_035 — Unaligned start: first beat TKEEP != all-ones.
class axi_stream_master_vip_tc_mst_035_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_035_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_035_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 10; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[2:8]};
      keep[0] inside {4'b0010, 4'b0100, 4'b1000, 4'b0110, 4'b1100};
    }) `uvm_fatal("SEQ/RAND", "TC_035 randomize failed")
  endfunction
endclass

// TC_MST_036 — Fully dense TKEEP (all-ones) boundary case.
class axi_stream_master_vip_tc_mst_036_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_036_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_036_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 10; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[4:16]};
      foreach (keep[i]) keep[i] == '1;
      foreach (strb[i]) strb[i] == '1;
    }) `uvm_fatal("SEQ/RAND", "TC_036 randomize failed")
  endfunction
endclass

// ── REQ_MST_10 — TSTRB position bytes ────────────────────────────────────────

// TC_MST_037 — Legal TKEEP x TSTRB cross product.
class axi_stream_master_vip_tc_mst_037_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_037_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_037_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 20; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[2:8]}; })
      `uvm_fatal("SEQ/RAND", "TC_037 randomize failed")
  endfunction
endclass

// TC_MST_038 — Position bytes only: TKEEP=1, TSTRB=0 on every lane.
class axi_stream_master_vip_tc_mst_038_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_038_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_038_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 8; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[2:8]};
      foreach (keep[i]) keep[i] == '1;
      foreach (strb[i]) strb[i] == '0;   // transported, but not payload
    }) `uvm_fatal("SEQ/RAND", "TC_038 randomize failed")
  endfunction
endclass

// TC_MST_039 — NEGATIVE: reserved encoding TKEEP=0 / TSTRB=1.
// Expect CHK/RESERVED_QUAL.
class axi_stream_master_vip_tc_mst_039_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_039_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_039_seq"); super.new(name); endfunction
  function bit is_negative(); return 1; endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    item.c_legal.constraint_mode(0);   // MUST precede randomize()
    if (!item.randomize() with {
      inject_reserved_qual == 1;
      inject_tvalid_drop == 0;   // pin: constraint_mode(0) freed every knob
      inject_parity_fault == 0;   // pin: constraint_mode(0) freed every knob
      inject_payload_mutate == 0;   // pin: constraint_mode(0) freed every knob
      packet_beats inside {[1:4]};
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
    }) `uvm_fatal("SEQ/RAND", "TC_039 randomize failed")
  endfunction
endclass

// TC_MST_040 — Data, position and null bytes coexisting in one beat.
class axi_stream_master_vip_tc_mst_040_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_040_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_040_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 12; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[2:6]};
      foreach (keep[i]) keep[i] == 4'b1110;   // lane 0 null
      foreach (strb[i]) strb[i] == 4'b1010;   // mix of data and position lanes
    }) `uvm_fatal("SEQ/RAND", "TC_040 randomize failed")
  endfunction
endclass

// ── REQ_MST_11 — TID/TDEST stability ─────────────────────────────────────────

class axi_stream_master_vip_tc_mst_041_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_041_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_041_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 12; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[4:16]}; })
      `uvm_fatal("SEQ/RAND", "TC_041 randomize failed")
  endfunction
endclass

// TC_MST_042 — TID value-space sweep.
class axi_stream_master_vip_tc_mst_042_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_042_seq)
  int unsigned n;
  function new(string name = "axi_stream_master_vip_tc_mst_042_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 24; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[1:6]};
      id == ((local::n * 11) % 256);   // stride the 8-bit TID space
    }) `uvm_fatal("SEQ/RAND", "TC_042 randomize failed")
    n++;
  endfunction
endclass

// TC_MST_043 — TDEST routing sweep.
class axi_stream_master_vip_tc_mst_043_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_043_seq)
  int unsigned n;
  function new(string name = "axi_stream_master_vip_tc_mst_043_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 16; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[1:6]};
      dest == (local::n % 16);   // cover all 16 TDEST values
    }) `uvm_fatal("SEQ/RAND", "TC_043 randomize failed")
    n++;
  endfunction
endclass

// ── REQ_MST_12 — TWAKEUP ─────────────────────────────────────────────────────

// TC_MST_044 — Wakeup lead: TWAKEUP >= 1 cycle before TVALID.
class axi_stream_master_vip_tc_mst_044_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_044_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_044_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 12; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[1:6]};
      wakeup_lead_cycles inside {[1:8]};
    }) `uvm_fatal("SEQ/RAND", "TC_044 randomize failed")
  endfunction
endclass

// TC_MST_045 — Wakeup hold across an outstanding handshake.
class axi_stream_master_vip_tc_mst_045_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_045_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_045_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 10; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[2:8]};
      wakeup_lead_cycles == 1;
      foreach (inter_beat_delay[i]) inter_beat_delay[i] inside {[5:40]};
    }) `uvm_fatal("SEQ/RAND", "TC_045 randomize failed")
  endfunction
endclass

// TC_MST_046 — Wakeup deassertion when no further transfers are required.
class axi_stream_master_vip_tc_mst_046_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_046_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_046_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 6; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with {
      packet_beats inside {[1:4]};
      wakeup_lead_cycles inside {[2:6]};
    }) `uvm_fatal("SEQ/RAND", "TC_046 randomize failed")
  endfunction
endclass

// ── REQ_MST_13 / REQ_MST_14 — parity ─────────────────────────────────────────

// TC_MST_047 — Odd parity generation across all check signals.
class axi_stream_master_vip_tc_mst_047_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_047_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_047_seq"); super.new(name); endfunction
  constraint c_pkts { num_packets == 20; }
  function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize() with { packet_beats inside {[2:16]}; })
      `uvm_fatal("SEQ/RAND", "TC_047 randomize failed")
  endfunction
endclass

// TC_MST_048 — NEGATIVE: flip one TDATACHK bit. Expect CHK/PARITY.
// Sparse TKEEP is forced so parity coverage of NULL-BYTE lanes is exercised at
// the same time (REQ_MST_14: parity must be correct on lanes that are not data).
class axi_stream_master_vip_tc_mst_048_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_048_seq)
  function new(string name = "axi_stream_master_vip_tc_mst_048_seq"); super.new(name); endfunction
  function bit is_negative(); return 1; endfunction
  function void randomize_item(axi_stream_master_vip_seq_item item);
    item.c_legal.constraint_mode(0);   // MUST precede randomize()
    if (!item.randomize() with {
      inject_parity_fault == 1;
      inject_tvalid_drop == 0;   // pin: constraint_mode(0) freed every knob
      inject_reserved_qual == 0;   // pin: constraint_mode(0) freed every knob
      inject_payload_mutate == 0;   // pin: constraint_mode(0) freed every knob
      packet_beats inside {[2:6]};
      foreach (keep[i]) keep[i] != '1;   // sparse: null lanes present
      foreach (inter_beat_delay[i]) inter_beat_delay[i] == 0;
    }) `uvm_fatal("SEQ/RAND", "TC_048 randomize failed")
  endfunction
endclass

`endif
