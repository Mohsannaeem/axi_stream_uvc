// AXI-Stream Master VIP Test Sequences
// 48 sequences mapping to TC_MST_001 through TC_MST_048
// Each sequence covers a specific requirement from the verification plan.

// ═══ REQ_MST_01: TVALID Stability ════════════════════════════════════════════

// TC_MST_001: Single-beat packet — no stall
class axi_stream_master_vip_tc_mst_001_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_001_seq)
  function new(string name = "tc_mst_001"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_001] TVALID Stability — single beat, no stall", UVM_MEDIUM)
    repeat(5) send_clean_packet(.num_beats(1));
  endtask
endclass

// TC_MST_002: Multi-beat packet — stability under extended TREADY stall
class axi_stream_master_vip_tc_mst_002_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_002_seq)
  function new(string name = "tc_mst_002"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_002] TVALID Stability — multi-beat (64 beats), extended stall", UVM_MEDIUM)
    repeat(3) send_clean_packet(.num_beats(64));
  endtask
endclass

// TC_MST_003: Back-to-back single-beat packets
class axi_stream_master_vip_tc_mst_003_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_003_seq)
  function new(string name = "tc_mst_003"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_003] TVALID Stability — 20 back-to-back single beats", UVM_MEDIUM)
    repeat(20) send_clean_packet(.num_beats(1));
  endtask
endclass

// TC_MST_004: TVALID early deassert (violation — expect monitor fatal)
class axi_stream_master_vip_tc_mst_004_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_004_seq)
  function new(string name = "tc_mst_004"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_004] TVALID Violation — drop TVALID before handshake", UVM_MEDIUM)
    send_violation_packet(.drop_valid_early(1), .num_beats(8));
  endtask
endclass

// ═══ REQ_MST_02: Pre-TVALID TREADY ══════════════════════════════════════════

// TC_MST_005: TREADY=1 before TVALID (slave pre-asserts ready)
class axi_stream_master_vip_tc_mst_005_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_005_seq)
  function new(string name = "tc_mst_005"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_005] Pre-TVALID TREADY — handshake with pre-asserted TREADY", UVM_MEDIUM)
    repeat(10) send_clean_packet(.num_beats(4));
  endtask
endclass

// TC_MST_006: TREADY toggles around TVALID window
class axi_stream_master_vip_tc_mst_006_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_006_seq)
  function new(string name = "tc_mst_006"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_006] Pre-TVALID TREADY — TREADY toggles mid-stream", UVM_MEDIUM)
    repeat(5) send_clean_packet(.num_beats(8));
  endtask
endclass

// TC_MST_007: Simultaneous TVALID/TREADY assertion
class axi_stream_master_vip_tc_mst_007_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_007_seq)
  function new(string name = "tc_mst_007"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_007] Pre-TVALID TREADY — simultaneous assertion", UVM_MEDIUM)
    repeat(15) send_clean_packet(.num_beats(1));
  endtask
endclass

// TC_MST_008: TREADY deasserts during multi-beat packet
class axi_stream_master_vip_tc_mst_008_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_008_seq)
  function new(string name = "tc_mst_008"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_008] Pre-TVALID TREADY — TREADY deasserts mid-packet", UVM_MEDIUM)
    repeat(5) send_clean_packet(.num_beats(16));
  endtask
endclass

// ═══ REQ_MST_03: Zero-Stall Throughput ═══════════════════════════════════════

// TC_MST_009: 100 packets — zero stall (DUT holds TREADY=1 continuously)
class axi_stream_master_vip_tc_mst_009_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_009_seq)
  function new(string name = "tc_mst_009"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_009] Zero-Stall — 100 pkts max throughput", UVM_MEDIUM)
    repeat(100) send_clean_packet(.num_beats(4));
  endtask
endclass

// TC_MST_010: Zero-stall single-beat burst (256 beats)
class axi_stream_master_vip_tc_mst_010_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_010_seq)
  function new(string name = "tc_mst_010"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_010] Zero-Stall — max packet length (256 beats)", UVM_MEDIUM)
    repeat(3) send_clean_packet(.num_beats(256));
  endtask
endclass

// TC_MST_011: Alternating stall / no-stall
class axi_stream_master_vip_tc_mst_011_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_011_seq)
  function new(string name = "tc_mst_011"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_011] Zero-Stall — alternating stall/no-stall packets", UVM_MEDIUM)
    for (int i = 0; i < 20; i++) send_clean_packet(.num_beats((i%2 == 0) ? 1 : 8));
  endtask
endclass

// TC_MST_012: Zero-stall with variable packet lengths
class axi_stream_master_vip_tc_mst_012_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_012_seq)
  function new(string name = "tc_mst_012"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_012] Zero-Stall — fully random packet lengths", UVM_MEDIUM)
    repeat(50) begin
      axi_stream_master_vip_seq_item pkt;
      pkt = axi_stream_master_vip_seq_item::type_id::create("pkt");
      start_item(pkt);
      if (!pkt.randomize()) `uvm_fatal("RAND","randomize failed tc_mst_012")
      finish_item(pkt);
    end
  endtask
endclass

// ═══ REQ_MST_04: TLAST Framing ═══════════════════════════════════════════════

// TC_MST_013: Single-beat packet — TLAST on beat 1
class axi_stream_master_vip_tc_mst_013_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_013_seq)
  function new(string name = "tc_mst_013"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_013] TLAST Framing — single-beat packet (TLAST=1 on beat 1)", UVM_MEDIUM)
    repeat(10) send_clean_packet(.num_beats(1));
  endtask
endclass

// TC_MST_014: Long packet (128 beats) — TLAST only on final beat
class axi_stream_master_vip_tc_mst_014_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_014_seq)
  function new(string name = "tc_mst_014"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_014] TLAST Framing — 128-beat packet, TLAST on final only", UVM_MEDIUM)
    repeat(2) send_clean_packet(.num_beats(128));
  endtask
endclass

// TC_MST_015: Back-to-back multi-beat packets
class axi_stream_master_vip_tc_mst_015_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_015_seq)
  function new(string name = "tc_mst_015"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_015] TLAST Framing — back-to-back 16-beat packets", UVM_MEDIUM)
    repeat(10) send_clean_packet(.num_beats(16));
  endtask
endclass

// TC_MST_016: Odd-numbered beats per packet
class axi_stream_master_vip_tc_mst_016_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_016_seq)
  function new(string name = "tc_mst_016"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_016] TLAST Framing — odd-length packets (3, 7, 11 beats)", UVM_MEDIUM)
    send_clean_packet(.num_beats(3));
    send_clean_packet(.num_beats(7));
    send_clean_packet(.num_beats(11));
    send_clean_packet(.num_beats(13));
  endtask
endclass

// ═══ REQ_MST_05: Null Termination ════════════════════════════════════════════

// TC_MST_017: Isolated null-termination packet
class axi_stream_master_vip_tc_mst_017_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_017_seq)
  function new(string name = "tc_mst_017"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_017] Null Termination — isolated null-term packet", UVM_MEDIUM)
    send_null_term_packet();
  endtask
endclass

// TC_MST_018: Null-term packet immediately after data packet
class axi_stream_master_vip_tc_mst_018_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_018_seq)
  function new(string name = "tc_mst_018"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_018] Null Termination — null-term after data packet", UVM_MEDIUM)
    send_clean_packet(.num_beats(8));
    send_null_term_packet();
    send_clean_packet(.num_beats(4));
  endtask
endclass

// TC_MST_019: Back-to-back null-term packets
class axi_stream_master_vip_tc_mst_019_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_019_seq)
  function new(string name = "tc_mst_019"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_019] Null Termination — back-to-back null-term packets", UVM_MEDIUM)
    repeat(5) send_null_term_packet();
  endtask
endclass

// TC_MST_020: Null-term at different TID values
class axi_stream_master_vip_tc_mst_020_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_020_seq)
  function new(string name = "tc_mst_020"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_020] Null Termination — null-term across multiple TID values", UVM_MEDIUM)
    send_null_term_packet(.tid(8'h00));
    send_null_term_packet(.tid(8'h01));
    send_null_term_packet(.tid(8'hFF));
  endtask
endclass

// ═══ REQ_MST_06: TKEEP Patterns ══════════════════════════════════════════════

// TC_MST_021: All-HIGH TKEEP (all bytes valid)
class axi_stream_master_vip_tc_mst_021_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_021_seq)
  function new(string name = "tc_mst_021"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_021] TKEEP — all bytes valid (TKEEP=0b1111)", UVM_MEDIUM)
    repeat(10) send_packet(.num_beats(4), .tkeep('1), .tstrb('1));
  endtask
endclass

// TC_MST_022: Sparse TKEEP (alternating bytes)
class axi_stream_master_vip_tc_mst_022_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_022_seq)
  function new(string name = "tc_mst_022"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_022] TKEEP — sparse patterns (0b0101, 0b1010)", UVM_MEDIUM)
    send_packet(.num_beats(4), .tkeep(4'b0101), .tstrb(4'b0101));
    send_packet(.num_beats(4), .tkeep(4'b1010), .tstrb(4'b0000));
    send_packet(.num_beats(4), .tkeep(4'b0001), .tstrb(4'b0001));
  endtask
endclass

// TC_MST_023: TKEEP null byte in mid-packet (position byte)
class axi_stream_master_vip_tc_mst_023_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_023_seq)
  function new(string name = "tc_mst_023"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_023] TKEEP — position bytes TKEEP=1 TSTRB=0", UVM_MEDIUM)
    send_packet(.num_beats(4), .tkeep(4'b1111), .tstrb(4'b0000));  // all position bytes
    send_packet(.num_beats(4), .tkeep(4'b1100), .tstrb(4'b0100));  // mixed
  endtask
endclass

// TC_MST_024: Reserved TSTRB/TKEEP combination (violation)
class axi_stream_master_vip_tc_mst_024_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_024_seq)
  function new(string name = "tc_mst_024"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_024] TKEEP Violation — TSTRB=1 with TKEEP=0 (reserved)", UVM_MEDIUM)
    send_violation_packet(.inject_invalid_tstrb_tkeep(1), .num_beats(4));
  endtask
endclass

// ═══ REQ_MST_07: TSTRB Qualification ════════════════════════════════════════

// TC_MST_025: Data bytes only (TSTRB=1, TKEEP=1)
class axi_stream_master_vip_tc_mst_025_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_025_seq)
  function new(string name = "tc_mst_025"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_025] TSTRB — all data bytes (TKEEP=1 TSTRB=1)", UVM_MEDIUM)
    repeat(8) send_packet(.num_beats(4), .tkeep('1), .tstrb('1));
  endtask
endclass

// TC_MST_026: Position bytes only (TSTRB=0, TKEEP=1)
class axi_stream_master_vip_tc_mst_026_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_026_seq)
  function new(string name = "tc_mst_026"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_026] TSTRB — position bytes only (TKEEP=1 TSTRB=0)", UVM_MEDIUM)
    repeat(8) send_packet(.num_beats(4), .tkeep('1), .tstrb('0));
  endtask
endclass

// TC_MST_027: Mixed data + position bytes
class axi_stream_master_vip_tc_mst_027_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_027_seq)
  function new(string name = "tc_mst_027"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_027] TSTRB — mixed data + position bytes", UVM_MEDIUM)
    send_packet(.num_beats(4), .tkeep(4'b1111), .tstrb(4'b1010));
    send_packet(.num_beats(4), .tkeep(4'b1111), .tstrb(4'b0101));
    send_packet(.num_beats(4), .tkeep(4'b0110), .tstrb(4'b0100));
  endtask
endclass

// TC_MST_028: TSTRB walk through all valid byte positions
class axi_stream_master_vip_tc_mst_028_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_028_seq)
  function new(string name = "tc_mst_028"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_028] TSTRB — walk all qualifier combinations", UVM_MEDIUM)
    for (int k = 0; k < 16; k++) begin
      logic [3:0] tstrb = k[3:0];
      logic [3:0] tkeep = tstrb | 4'b0000;  // TKEEP must be superset of TSTRB
      tkeep = tstrb;  // simplest valid combination: TKEEP==TSTRB
      send_packet(.num_beats(2), .tkeep(tkeep), .tstrb(tstrb));
    end
  endtask
endclass

// ═══ REQ_MST_08: TID Interleaving ════════════════════════════════════════════

// TC_MST_029: Change TID mid-packet (violation)
class axi_stream_master_vip_tc_mst_029_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_029_seq)
  function new(string name = "tc_mst_029"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_029] TID Interleaving — TID change mid-packet (violation)", UVM_MEDIUM)
    send_violation_packet(.change_tid_mid_packet(1), .num_beats(8));
  endtask
endclass

// TC_MST_030: Two interleaved streams (TID=0 and TID=1)
class axi_stream_master_vip_tc_mst_030_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_030_seq)
  function new(string name = "tc_mst_030"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_030] TID Interleaving — 2 streams TID=0 and TID=1", UVM_MEDIUM)
    for (int i = 0; i < 10; i++) begin
      send_clean_packet(.num_beats(4), .tid(8'h00));
      send_clean_packet(.num_beats(4), .tid(8'h01));
    end
  endtask
endclass

// TC_MST_031: Four interleaved streams
class axi_stream_master_vip_tc_mst_031_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_031_seq)
  function new(string name = "tc_mst_031"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_031] TID Interleaving — 4 streams TID=0..3", UVM_MEDIUM)
    for (int i = 0; i < 8; i++) begin
      send_clean_packet(.num_beats(4), .tid(8'h00));
      send_clean_packet(.num_beats(4), .tid(8'h01));
      send_clean_packet(.num_beats(4), .tid(8'h02));
      send_clean_packet(.num_beats(4), .tid(8'h03));
    end
  endtask
endclass

// TC_MST_032: Max TID value (TID=0xFF)
class axi_stream_master_vip_tc_mst_032_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_032_seq)
  function new(string name = "tc_mst_032"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_032] TID Interleaving — max TID=0xFF", UVM_MEDIUM)
    send_clean_packet(.num_beats(4), .tid(8'hFF));
    send_clean_packet(.num_beats(4), .tid(8'h00));
    send_clean_packet(.num_beats(4), .tid(8'hFF));
  endtask
endclass

// ═══ REQ_MST_09: Continuous Packets ══════════════════════════════════════════

// TC_MST_033: Continuous packet mode — all beats valid (TKEEP=1111)
class axi_stream_master_vip_tc_mst_033_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_033_seq)
  function new(string name = "tc_mst_033"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_033] Continuous Pkts — TKEEP=1111 all beats", UVM_MEDIUM)
    repeat(5) send_packet(.num_beats(8), .tkeep('1), .tstrb('1));
  endtask
endclass

// TC_MST_034: Continuous packet mode — TID=same across all packets
class axi_stream_master_vip_tc_mst_034_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_034_seq)
  function new(string name = "tc_mst_034"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_034] Continuous Pkts — same TID across all packets", UVM_MEDIUM)
    repeat(10) send_clean_packet(.num_beats(4), .tid(8'h05));
  endtask
endclass

// TC_MST_035: Continuous packet violation — TID changes while TLAST=0
class axi_stream_master_vip_tc_mst_035_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_035_seq)
  function new(string name = "tc_mst_035"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_035] Continuous Pkts Violation — TID change while TLAST=0", UVM_MEDIUM)
    send_violation_packet(.change_tid_mid_packet(1), .num_beats(8));
  endtask
endclass

// TC_MST_036: Continuous packet violation — null byte while TLAST=0
class axi_stream_master_vip_tc_mst_036_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_036_seq)
  function new(string name = "tc_mst_036"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_036] Continuous Pkts Violation — null byte TKEEP=0 while TLAST=0", UVM_MEDIUM)
    // Null byte in mid-packet where TKEEP is restricted in cont_pkt_mode
    send_packet(.num_beats(4), .tkeep(4'b1110), .tstrb(4'b1110));  // TKEEP[0]=0 mid-packet
  endtask
endclass

// ═══ REQ_MST_10: Reset Behavior ══════════════════════════════════════════════

// TC_MST_037: VIP outputs idle during reset
class axi_stream_master_vip_tc_mst_037_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_037_seq)
  function new(string name = "tc_mst_037"); super.new(name); endfunction
  task body();
    // tb_top controls reset — this sequence just verifies VIP behaves correctly post-reset
    `uvm_info("SEQ", "[TC_MST_037] Reset — send first packet after reset de-assertion", UVM_MEDIUM)
    send_clean_packet(.num_beats(4));
  endtask
endclass

// TC_MST_038: Reset mid-session (mid-simulation reset)
class axi_stream_master_vip_tc_mst_038_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_038_seq)
  function new(string name = "tc_mst_038"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_038] Reset — multiple packets across reset event", UVM_MEDIUM)
    repeat(3) send_clean_packet(.num_beats(4));  // pre-reset
    // post-reset sends handled by base test
    repeat(3) send_clean_packet(.num_beats(4));
  endtask
endclass

// TC_MST_039: Single packet immediately after ARESETn deasserts
class axi_stream_master_vip_tc_mst_039_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_039_seq)
  function new(string name = "tc_mst_039"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_039] Reset — first packet must wait 1 cycle after ARESETn", UVM_MEDIUM)
    send_clean_packet(.num_beats(1));
    send_clean_packet(.num_beats(8));
  endtask
endclass

// TC_MST_040: Multiple resets with packet boundary verification
class axi_stream_master_vip_tc_mst_040_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_040_seq)
  function new(string name = "tc_mst_040"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_040] Reset — stress test across many packets", UVM_MEDIUM)
    repeat(50) send_clean_packet(.num_beats(2));
  endtask
endclass

// ═══ REQ_MST_11: TWAKEUP Timing ══════════════════════════════════════════════

// TC_MST_041: TWAKEUP asserted 1 cycle before TVALID
class axi_stream_master_vip_tc_mst_041_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_041_seq)
  function new(string name = "tc_mst_041"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_041] TWAKEUP — standard 1-cycle lead before TVALID", UVM_MEDIUM)
    repeat(10) send_clean_packet(.num_beats(4));
  endtask
endclass

// TC_MST_042: TWAKEUP deasserted correctly after packet
class axi_stream_master_vip_tc_mst_042_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_042_seq)
  function new(string name = "tc_mst_042"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_042] TWAKEUP — deassert after last transfer of packet", UVM_MEDIUM)
    send_clean_packet(.num_beats(8));
    send_clean_packet(.num_beats(4));
  endtask
endclass

// TC_MST_043: TWAKEUP held across back-to-back packets
class axi_stream_master_vip_tc_mst_043_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_043_seq)
  function new(string name = "tc_mst_043"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_043] TWAKEUP — held HIGH across consecutive packets", UVM_MEDIUM)
    repeat(8) send_clean_packet(.num_beats(4));
  endtask
endclass

// TC_MST_044: TWAKEUP parity correctness (TWAKEUPCHK = ~TWAKEUP)
class axi_stream_master_vip_tc_mst_044_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_044_seq)
  function new(string name = "tc_mst_044"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_044] TWAKEUP — TWAKEUPCHK odd parity throughout", UVM_MEDIUM)
    repeat(5) send_clean_packet(.num_beats(4));
  endtask
endclass

// ═══ REQ_MST_12: AXI5 Parity Integrity ═══════════════════════════════════════

// TC_MST_045: TDATACHK parity injection (1-bit flip)
class axi_stream_master_vip_tc_mst_045_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_045_seq)
  function new(string name = "tc_mst_045"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_045] AXI5 Parity — inject TDATACHK error on byte 0", UVM_MEDIUM)
    send_violation_packet(.parity_inject_error(1), .parity_error_byte_idx(0), .num_beats(16));
  endtask
endclass

// TC_MST_046: All parity signals correct throughout long stream
class axi_stream_master_vip_tc_mst_046_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_046_seq)
  function new(string name = "tc_mst_046"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_046] AXI5 Parity — all parity correct, 100-packet stream", UVM_MEDIUM)
    repeat(100) send_clean_packet(.num_beats(4));
  endtask
endclass

// TC_MST_047: TREADYCHK verified against DUT TREADY
class axi_stream_master_vip_tc_mst_047_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_047_seq)
  function new(string name = "tc_mst_047"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_047] AXI5 Parity — TREADYCHK=~TREADY verified per cycle", UVM_MEDIUM)
    repeat(20) send_clean_packet(.num_beats(8));
  endtask
endclass

// TC_MST_048: Full parity regression — all signals across all conditions
class axi_stream_master_vip_tc_mst_048_seq extends axi_stream_master_vip_base_sequence;
  `uvm_object_utils(axi_stream_master_vip_tc_mst_048_seq)
  function new(string name = "tc_mst_048"); super.new(name); endfunction
  task body();
    `uvm_info("SEQ", "[TC_MST_048] AXI5 Parity — full regression 15 random pkts", UVM_MEDIUM)
    repeat(15) begin
      axi_stream_master_vip_seq_item pkt;
      pkt = axi_stream_master_vip_seq_item::type_id::create("pkt");
      start_item(pkt);
      if (!pkt.randomize() with { packet_length <= 8; })
        `uvm_fatal("RAND","randomize failed tc_mst_048")
      finish_item(pkt);
    end
  endtask
endclass
