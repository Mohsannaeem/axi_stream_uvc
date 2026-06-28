// AXI-Stream Master VIP Sequence Item
// Represents one logical packet driven by the Master VIP Transmitter.
class axi_stream_master_vip_seq_item extends uvm_sequence_item;
  `uvm_object_utils(axi_stream_master_vip_seq_item)

  // ── Stimulus fields (randomized per beat inside sequences) ───────────────────
  rand logic [`TDATA_WIDTH-1:0]    tdata;
  rand logic [`TSTRB_WIDTH-1:0]    tstrb;
  rand logic [`TSTRB_WIDTH-1:0]    tkeep;
  rand logic                        tlast;
  rand logic [`TID_WIDTH-1:0]      tid;
  rand logic [`TDEST_WIDTH-1:0]    tdest;
  rand logic [`TUSER_WIDTH-1:0]    tuser;

  // ── Timing control ────────────────────────────────────────────────────────────
  rand int unsigned tready_delay;   // cycles to wait for TREADY (observed, not driven)
  rand int unsigned packet_length;  // total beats in this packet

  // ── Protocol violation knobs (negative test injection) ────────────────────────
  bit drop_valid_early          = 0;  // TC_MST_004: deassert TVALID before handshake
  bit inject_invalid_tstrb_tkeep= 0;  // TC_MST_024: TSTRB=1 with TKEEP=0 (reserved)
  bit change_tid_mid_packet     = 0;  // TC_MST_029: change TID while TLAST=0
  bit parity_inject_error       = 0;  // TC_MST_045: flip one TDATACHK bit
  int parity_error_byte_idx     = 0;  // which byte's parity to corrupt

  // ── Default constraints ───────────────────────────────────────────────────────
  constraint c_packet_length  { packet_length inside {1, [2:8], [9:64], [65:`MAX_PACKET_BEATS]}; }
  constraint c_tready_delay   { tready_delay  inside {0, [1:5], [6:20], [21:100]}; }
  constraint c_tkeep_nonzero  {
    if (!drop_valid_early && !inject_invalid_tstrb_tkeep)
      (tkeep != '0) || (tstrb == '0);  // tkeep=0 only valid when tstrb=0 (null-term)
  }
  constraint c_tstrb_law {
    if (!inject_invalid_tstrb_tkeep)
      foreach (tstrb[i]) { tstrb[i] == 0 || tkeep[i] == 1; } // TSTRB=1 requires TKEEP=1
  }
  constraint c_tid_range  { tid   < (1 << `TID_WIDTH);   }
  constraint c_tdest_range{ tdest < (1 << `TDEST_WIDTH); }

  function new(string name = "axi_stream_master_vip_seq_item");
    super.new(name);
  endfunction

  function void do_copy(uvm_object rhs);
    axi_stream_master_vip_seq_item rhs_;
    if (!$cast(rhs_, rhs)) begin
      `uvm_error("do_copy", "Cast failed in axi_stream_master_vip_seq_item::do_copy")
      return;
    end
    super.do_copy(rhs);
    tdata                    = rhs_.tdata;
    tstrb                    = rhs_.tstrb;
    tkeep                    = rhs_.tkeep;
    tlast                    = rhs_.tlast;
    tid                      = rhs_.tid;
    tdest                    = rhs_.tdest;
    tuser                    = rhs_.tuser;
    tready_delay             = rhs_.tready_delay;
    packet_length            = rhs_.packet_length;
    drop_valid_early         = rhs_.drop_valid_early;
    inject_invalid_tstrb_tkeep= rhs_.inject_invalid_tstrb_tkeep;
    change_tid_mid_packet    = rhs_.change_tid_mid_packet;
    parity_inject_error      = rhs_.parity_inject_error;
    parity_error_byte_idx    = rhs_.parity_error_byte_idx;
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    axi_stream_master_vip_seq_item rhs_;
    if (!$cast(rhs_, rhs)) begin
      `uvm_error("do_compare", "Cast failed")
      return 0;
    end
    return (super.do_compare(rhs, comparer) &&
            tdata == rhs_.tdata &&
            tkeep == rhs_.tkeep &&
            tstrb == rhs_.tstrb &&
            tlast == rhs_.tlast &&
            tid   == rhs_.tid   &&
            tdest == rhs_.tdest &&
            tuser == rhs_.tuser);
  endfunction

  function string convert2string();
    return $sformatf(
      "SEQ_ITEM | TDATA=0x%08h TKEEP=0b%04b TSTRB=0b%04b TLAST=%0b TID=0x%0h TDEST=0x%0h TUSER=0x%0h | pkt_len=%0d",
      tdata, tkeep, tstrb, tlast, tid, tdest, tuser, packet_length);
  endfunction

  function void do_print(uvm_printer printer);
    $display(convert2string());
  endfunction

endclass
