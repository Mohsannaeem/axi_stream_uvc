// =============================================================================
// AXI5-Stream Master VIP — Base Sequence
// Owns the packet lifecycle. Subclasses override ONLY their constraints, never
// the body — that keeps all 48 scenario sequences honest about what they change.
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_BASE_SEQUENCE_SV
`define AXI_STREAM_MASTER_VIP_BASE_SEQUENCE_SV

class axi_stream_master_vip_base_sequence extends uvm_sequence #(axi_stream_master_vip_seq_item);
  `uvm_object_utils(axi_stream_master_vip_base_sequence)

  rand int unsigned num_packets = 1;

  constraint c_num_packets { num_packets inside {[1:50]}; }

  // Scoreboard handle: the sequence registers each packet it emits as EXPECTED,
  // which is what lets the scoreboard detect a packet that is never observed or
  // that surfaces on the wrong stream.
  protected axi_stream_master_vip_scoreboard sb;

  function new(string name = "axi_stream_master_vip_base_sequence");
    super.new(name);
  endfunction

  task pre_start();
    super.pre_start();
    if (!uvm_config_db #(axi_stream_master_vip_scoreboard)::get(null, "*", "sb", sb))
      `uvm_info("SEQ", "No scoreboard handle in ConfigDB — expected packets will not be registered",
                UVM_HIGH)
  endtask

  // Subclasses override this to shape the packet. Default: fully legal random.
  virtual function void randomize_item(axi_stream_master_vip_seq_item item);
    if (!item.randomize())
      `uvm_fatal("SEQ/RAND", "Randomization failed on seq_item")
  endfunction

  // True for the negative sequences, which drive deliberately illegal stimulus.
  // Their packets are NOT registered as expected: the DUT will legitimately not
  // receive them intact, and the point of the test is that a CHECKER fires, not
  // that the scoreboard matches.
  virtual function bit is_negative();
    return 0;
  endfunction

  // Sequence lifecycle steps: UVM_DEBUG (coding_guideline 1c).
  virtual task body();
    axi_stream_master_vip_seq_item item;
    int unsigned n;

    `uvm_info(get_type_name(), $sformatf("[SEQ] step=BODY_START num_packets=%0d", num_packets),
              UVM_DEBUG)

    repeat (num_packets) begin
      n++;
      item = axi_stream_master_vip_seq_item::type_id::create("item");
      `uvm_info(get_type_name(), $sformatf("[SEQ] step=ITEM_CREATED (%0d/%0d)", n, num_packets),
                UVM_DEBUG)

      // Logged BEFORE each blocking call, per coding_guideline rule 5:
      // start_item blocks until the sequencer grants, and finish_item blocks
      // until the driver calls item_done. A log placed after the call cannot
      // show that the sequence is waiting inside it.
      `uvm_info("SEQ_FLOW", "[SEQ] step=CALLING start_item", UVM_DEBUG)
      start_item(item);
      `uvm_info("SEQ_FLOW", "[SEQ] step=START_ITEM granted by sequencer", UVM_DEBUG)

      randomize_item(item);
      `uvm_info("SEQ_FLOW", $sformatf(
        "[SEQ] step=RANDOMIZED beats=%0d TID=0x%0h TDEST=0x%0h data_bytes=%0d knobs=%0b%0b%0b%0b",
        item.packet_beats, item.id, item.dest, item.data_byte_count(),
        item.inject_tvalid_drop, item.inject_parity_fault,
        item.inject_reserved_qual, item.inject_payload_mutate), UVM_DEBUG)

      if (sb != null && !is_negative()) begin
        sb.expect_packet(item);
        `uvm_info("SEQ_FLOW", "[SEQ] step=REGISTERED_EXPECTED with scoreboard", UVM_DEBUG)
      end

      `uvm_info("SEQ_FLOW", "[SEQ] step=CALLING finish_item (blocks until item_done)", UVM_DEBUG)
      finish_item(item);
      `uvm_info("SEQ_FLOW", $sformatf("[SEQ] step=FINISH_ITEM returned (%0d/%0d)",
                                      n, num_packets), UVM_DEBUG)
    end

    `uvm_info(get_type_name(), "[SEQ] step=BODY_DONE", UVM_DEBUG)
  endtask

endclass

`endif
