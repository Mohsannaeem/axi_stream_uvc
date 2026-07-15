// ============================================================================
// AXI5-Stream Slave VIP — Test Sequences (TC_SLV_001..050)
// One class per plan test case. Each sets a distinct TREADY back-pressure
// profile. Negative tests (014,018,039,046,048,049) rely on the DUT master
// stub emitting the violation via +DUT_* plusargs set by the test; the VIP
// monitor's checker must fire. TC_050 clock-removal is TB-driven.
// ============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_TEST_SEQUENCES_SV
`define AXI_STREAM_SLAVE_VIP_TEST_SEQUENCES_SV

class axi_stream_slave_vip_tc_slv_001_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_001_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_001_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept==1; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_001 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_002_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_002_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_002_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[1:4]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_002 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_003_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_003_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_003_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[2:8]}; foreach(ready_delay[i]) ready_delay[i] inside {[1:16]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_003 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_004_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_004_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_004_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 20; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_PERIODIC; num_beats_to_accept inside {[1:8]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_004 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_005_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_005_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_005_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[4:16]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_005 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_006_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_006_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_006_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_PERIODIC; num_beats_to_accept inside {[4:16]}; period inside {[2:8]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_006 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_007_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_007_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_007_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SINGLE_PULSE; num_beats_to_accept inside {[4:12]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_007 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_008_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_008_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_008_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept==`MAX_PACKET_BEATS; foreach(ready_delay[i]) ready_delay[i] inside {[10:`TREADY_STALL_MAX]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_008 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_009_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_009_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_009_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept==32; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_009 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_010_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_010_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_010_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 4; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[16:32]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_010 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_011_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_011_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_011_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 10; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[1:4]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_011 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_012_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_012_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_012_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 3; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[8:24]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_012 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_013_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_013_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_013_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[2:8]}; foreach(ready_delay[i]) ready_delay[i] inside {[1:`TREADY_STALL_MAX]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_013 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_014_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_014_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_014_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[2:6]}; foreach(ready_delay[i]) ready_delay[i] inside {[2:20]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_014 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_015_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_015_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_015_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept==`MAX_PACKET_BEATS; foreach(ready_delay[i]) ready_delay[i] inside {[1:8]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_015 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_016_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_016_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_016_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept==16; foreach(ready_delay[i]) ready_delay[i] inside {[1:10]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_016 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_017_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_017_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_017_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[2:8]}; foreach(ready_delay[i]) ready_delay[i] inside {[5:`TREADY_STALL_MAX]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_017 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_018_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_018_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_018_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[2:6]}; foreach(ready_delay[i]) ready_delay[i] inside {[2:20]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_018 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_019_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_019_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_019_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[3:10]}; foreach(ready_delay[i]) ready_delay[i] inside {[3:30]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_019 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_020_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_020_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_020_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept==16; foreach(ready_delay[i]) ready_delay[i] inside {[1:10]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_020 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_021_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_021_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_021_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[1:4]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_021 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_022_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_022_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_022_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 8; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[8:32]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_022 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_023_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_023_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_023_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 8; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[4:16]}; foreach(ready_delay[i]) ready_delay[i] inside {[10:40]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_023 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_024_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_024_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_024_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 12; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[2:8]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_024 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_025_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_025_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_025_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 10; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept==1; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_025 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_026_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_026_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_026_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept==`MAX_PACKET_BEATS; foreach(ready_delay[i]) ready_delay[i] inside {[0:2]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_026 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_027_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_027_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_027_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 25; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_PERIODIC; num_beats_to_accept inside {[1:32]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_027 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_028_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_028_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_028_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_PERIODIC; num_beats_to_accept inside {[2:12]}; period inside {[2:6]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_028 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_029_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_029_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_029_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 6; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[2:8]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_029 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_030_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_030_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_030_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 8; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[2:6]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_030 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_031_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_031_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_031_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 8; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[2:6]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_031 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_032_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_032_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_032_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 20; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_PERIODIC; num_beats_to_accept inside {[1:10]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_032 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_033_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_033_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_033_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 15; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[2:12]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_033 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_034_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_034_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_034_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 5; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept==1; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_034 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_035_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_035_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_035_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 10; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[2:8]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_035 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_036_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_036_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_036_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 10; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[4:16]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_036 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_037_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_037_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_037_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 20; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[2:8]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_037 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_038_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_038_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_038_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 8; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[2:8]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_038 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_039_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_039_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_039_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[1:4]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_039 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_040_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_040_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_040_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 12; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[2:6]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_040 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_041_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_041_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_041_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 12; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[4:16]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_041 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_042_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_042_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_042_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 24; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_PERIODIC; num_beats_to_accept inside {[1:6]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_042 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_043_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_043_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_043_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 16; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_PERIODIC; num_beats_to_accept inside {[1:6]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_043 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_044_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_044_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_044_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 12; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_WAKEUP_GATED; num_beats_to_accept inside {[1:6]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_044 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_045_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_045_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_045_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 10; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[2:8]}; foreach(ready_delay[i]) ready_delay[i] inside {[5:40]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_045 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_046_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_046_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_046_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 6; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[1:4]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_046 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_047_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_047_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_047_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 20; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[2:16]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_047 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_048_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_048_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_048_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_SPARSE; num_beats_to_accept inside {[2:6]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_048 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_049_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_049_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_049_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[2:16]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_049 randomize failed");
  endfunction
endclass

class axi_stream_slave_vip_tc_slv_050_seq extends axi_stream_slave_vip_base_sequence;
  `uvm_object_utils(axi_stream_slave_vip_tc_slv_050_seq)
  function new(string name = "axi_stream_slave_vip_tc_slv_050_seq"); super.new(name); endfunction
  constraint c_prof { num_profiles == 1; }
  function void randomize_item(axi_stream_slave_vip_seq_item item);
    if (!item.randomize() with { mode == READY_CONTINUOUS; num_beats_to_accept inside {[2:16]}; })
      `uvm_fatal("SEQ/RAND", "TC_SLV_050 randomize failed");
  endfunction
endclass

`endif