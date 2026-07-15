// =============================================================================
// AXI5-Stream Slave VIP — Sequence Item
// One item == a TREADY BACK-PRESSURE PROFILE the VIP will drive while accepting
// a span of beats. The Slave VIP does not generate payload (the DUT owns it), so
// this item carries no TDATA/TKEEP — only how the Receiver applies back-pressure.
// =============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_SEQ_ITEM_SV
`define AXI_STREAM_SLAVE_VIP_SEQ_ITEM_SV

typedef enum bit [2:0] {
  READY_CONTINUOUS,   // TREADY held HIGH
  READY_PERIODIC,     // TREADY HIGH every `period` cycles
  READY_SINGLE_PULSE, // TREADY HIGH for one cycle at a time
  READY_SPARSE,       // long random stalls between accepts
  READY_WAKEUP_GATED  // TREADY withheld until observed TWAKEUP HIGH
} axi_stream_slave_ready_mode_e;

class axi_stream_slave_vip_seq_item extends uvm_sequence_item;

  // ── Back-pressure profile ─────────────────────────────────────────────────
  rand int unsigned                  num_beats_to_accept;
  rand int unsigned                  ready_delay[$];   // TREADY-low cycles before each accept
  rand axi_stream_slave_ready_mode_e mode;
  rand int unsigned                  period;           // for READY_PERIODIC

  // ── Negative / fault knob (VIP-owned signal only) ─────────────────────────
  rand bit inject_readychk_fault;    // corrupt TREADYCHK parity (VIP drives TREADYCHK)

  `uvm_object_utils_begin(axi_stream_slave_vip_seq_item)
    `uvm_field_int(num_beats_to_accept,  UVM_ALL_ON | UVM_DEC)
    `uvm_field_queue_int(ready_delay,    UVM_ALL_ON | UVM_DEC)
    `uvm_field_enum(axi_stream_slave_ready_mode_e, mode, UVM_ALL_ON)
    `uvm_field_int(period,               UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(inject_readychk_fault, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "axi_stream_slave_vip_seq_item");
    super.new(name);
  endfunction

  constraint c_beats  { num_beats_to_accept inside {[1:`MAX_PACKET_BEATS]}; }
  constraint c_qsize  { ready_delay.size() == num_beats_to_accept; }
  constraint c_delay  { foreach (ready_delay[i]) ready_delay[i] inside {[0:`TREADY_STALL_MAX]}; }
  constraint c_period { period inside {[1:8]}; }

  // Legality: the fault knob is held off unless a negative sequence enables it.
  constraint c_legal  { inject_readychk_fault == 0; }

  function void do_copy(uvm_object rhs);
    axi_stream_slave_vip_seq_item r;
    if (!$cast(r, rhs)) begin
      `uvm_error("do_copy", "cast failed"); return;
    end
    super.do_copy(rhs);
    num_beats_to_accept  = r.num_beats_to_accept;
    ready_delay          = r.ready_delay;
    mode                 = r.mode;
    period               = r.period;
    inject_readychk_fault = r.inject_readychk_fault;
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    axi_stream_slave_vip_seq_item r;
    if (!$cast(r, rhs)) return 0;
    return super.do_compare(rhs, comparer)
        && num_beats_to_accept == r.num_beats_to_accept
        && mode == r.mode && period == r.period;
  endfunction

  function string convert2string();
    return $sformatf("READY_PROFILE mode=%s beats=%0d period=%0d fault=%0b",
                     mode.name(), num_beats_to_accept, period, inject_readychk_fault);
  endfunction

endclass

`endif
