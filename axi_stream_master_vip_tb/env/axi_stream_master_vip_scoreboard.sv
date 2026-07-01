// AXI-Stream Master VIP Scoreboard
// Receives observed beats from Master VIP monitor.
// Checks: all beats reach DUT TREADY (no drops), packet integrity, ordering.
class axi_stream_master_vip_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_stream_master_vip_scoreboard)

  uvm_analysis_imp #(axi_stream_master_vip_seq_item, axi_stream_master_vip_scoreboard) analysis_export;

  int total_beats_received   = 0;
  int total_pkts_received    = 0;
  int null_term_pkts         = 0;
  int error_count            = 0;

  // Packet boundary tracking
  logic [AXI_ID_W-1:0]   current_tid;
  logic [AXI_DEST_W-1:0] current_tdest;
  bit   in_packet            = 0;
  int   beats_in_pkt         = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_export = new("analysis_export", this);
  endfunction

  function void write(axi_stream_master_vip_seq_item item);
    total_beats_received++;
    beats_in_pkt++;

    if (!in_packet) begin
      // First beat of a new packet
      in_packet     = 1;
      current_tid   = item.tid;
      current_tdest = item.tdest;
      beats_in_pkt  = 1;
    end else begin
      // Mid-packet: TID and TDEST must not change (AXI5-Stream rule)
      if (item.tid !== current_tid) begin
        `uvm_error("SB", $sformatf(
          "TID_MID_PACKET_CHANGE: expected TID=0x%0h got TID=0x%0h (beat %0d of pkt %0d)",
          current_tid, item.tid, beats_in_pkt, total_pkts_received))
        error_count++;
      end
      if (item.tdest !== current_tdest) begin
        `uvm_error("SB", $sformatf(
          "TDEST_MID_PACKET_CHANGE: expected TDEST=0x%0h got TDEST=0x%0h (beat %0d of pkt %0d)",
          current_tdest, item.tdest, beats_in_pkt, total_pkts_received))
        error_count++;
      end
    end

    // TSTRB/TKEEP compliance
    for (int i = 0; i < AXI_STRB_W; i++) begin
      if (item.tstrb[i] === 1'b1 && item.tkeep[i] !== 1'b1) begin
        `uvm_error("SB", $sformatf(
          "SB_QUALIFIER_VIOLATION: TSTRB[%0d]=1 with TKEEP[%0d]=0 (reserved)", i, i))
        error_count++;
      end
    end

    `uvm_info("SB", $sformatf(
      "[SB] BEAT#%0d RECV: TDATA=0x%08h TKEEP=0b%04b TLAST=%0b TID=0x%0h TDEST=0x%0h",
      total_beats_received, item.tdata, item.tkeep, item.tlast, item.tid, item.tdest), UVM_HIGH)

    // Packet boundary
    if (item.tlast === 1'b1) begin
      total_pkts_received++;
      if (item.tkeep === {(AXI_STRB_W){1'b0}}) begin
        null_term_pkts++;
        `uvm_info("SB", $sformatf(
          "[SB] PKT#%0d: NULL TERMINATION packet received (beats=%0d)",
          total_pkts_received, beats_in_pkt), UVM_MEDIUM)
      end else begin
        `uvm_info("SB", $sformatf(
          "[SB] PKT#%0d: Normal packet received (beats=%0d TID=0x%0h TDEST=0x%0h)",
          total_pkts_received, beats_in_pkt, current_tid, current_tdest), UVM_MEDIUM)
      end
      in_packet    = 0;
      beats_in_pkt = 0;
    end
  endfunction

  function void check_phase(uvm_phase phase);
    if (error_count > 0)
      `uvm_error("SB", $sformatf("[SB] FINAL: %0d protocol errors detected!", error_count))
    else
      `uvm_info("SB", "[SB] FINAL: No protocol errors detected.", UVM_NONE)

    `uvm_info("SB", $sformatf(
      "[SB] SUMMARY: total_beats=%0d total_pkts=%0d null_term=%0d errors=%0d",
      total_beats_received, total_pkts_received, null_term_pkts, error_count), UVM_NONE)
  endfunction

endclass
