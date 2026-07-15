// =============================================================================
// AXI5-Stream Slave VIP — TB Top
// Role: SLAVE VIP (Receiver). DUT is a MASTER (Transmitter) stub that emits
// packets and honours the dut_ctl violation knobs. ACLK is gate-able for the
// clock-removal resilience test (TC_SLV_050 / REQ_SLV_15).
// =============================================================================
`timescale 1ns/1ps

`include "axi_stream_slave_vip_defines.sv"

import axi_stream_slave_vip_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module axi_stream_slave_vip_tb_top;

  logic ACLK    = 1'b0;
  logic ARESETn = 1'b0;
  int unsigned rst_n;
  int unsigned gate_n;   // module-scope: a decl-with-init inside initial is implicitly static

  // ── Clock generator with gating (REQ_SLV_15) ──────────────────────────────
  // When dut_ctl.clk_gate_cycles > 0, ACLK is held frozen for that many
  // simulation half-periods so all synchronous state stops, then resumes.
  initial begin
    forever begin
      if (axi_stream_slave_vip_dut_ctl::clk_gate_cycles > 0) begin
        gate_n = axi_stream_slave_vip_dut_ctl::clk_gate_cycles;
        axi_stream_slave_vip_dut_ctl::clk_gate_cycles = 0;
        `uvm_info("TB_TOP", $sformatf("ACLK gated for %0d half-periods", gate_n), UVM_LOW)
        repeat (gate_n) #(`CLK_PERIOD_PS / 2.0);   // time passes, ACLK frozen
        `uvm_info("TB_TOP", "ACLK restored", UVM_LOW)
      end
      #(`CLK_PERIOD_PS / 2.0) ACLK = ~ACLK;
    end
  end

  // ── Reset: power-on + mid-sim pulses requested by the reset tests ─────────
  initial begin
    ARESETn = 1'b0;
    repeat (10) @(posedge ACLK);
    @(posedge ACLK); ARESETn = 1'b1;
    `uvm_info("TB_TOP", "ARESETn deasserted", UVM_LOW)
    forever begin
      @(posedge ACLK);
      if (axi_stream_slave_vip_dut_ctl::reset_pulse > 0) begin
        rst_n = axi_stream_slave_vip_dut_ctl::reset_pulse;
        axi_stream_slave_vip_dut_ctl::reset_pulse = 0;
        ARESETn = 1'b0;
        repeat (rst_n) @(posedge ACLK);
        @(posedge ACLK); ARESETn = 1'b1;
      end
    end
  end

  // ── Interface instance (explicit #(...) binding mandatory, SKILL §156) ────
  axi_stream_slave_vip_if #(
    .DATA_W(`AXI_DATA_W), .ID_W(`AXI_ID_W), .DEST_W(`AXI_DEST_W),
    .USER_W(`AXI_USER_W), .HAS_PAR(`AXI_HAS_PAR), .HAS_WAKE(`AXI_HAS_WAKE)
  ) dut_if (.ACLK(ACLK), .ARESETn(ARESETn));

  // ── DUT: AXI-Stream Master Transmitter stub ───────────────────────────────
  axi_stream_master_dut_stub #(
    .DATA_W(`AXI_DATA_W), .ID_W(`AXI_ID_W), .DEST_W(`AXI_DEST_W), .USER_W(`AXI_USER_W)
  ) dut (
    .ACLK(ACLK), .ARESETn(ARESETn),
    .TREADY(dut_if.TREADY), .TREADYCHK(dut_if.TREADYCHK),
    .TVALID(dut_if.TVALID), .TDATA(dut_if.TDATA), .TSTRB(dut_if.TSTRB), .TKEEP(dut_if.TKEEP),
    .TLAST(dut_if.TLAST), .TID(dut_if.TID), .TDEST(dut_if.TDEST), .TUSER(dut_if.TUSER),
    .TWAKEUP(dut_if.TWAKEUP), .TVALIDCHK(dut_if.TVALIDCHK), .TDATACHK(dut_if.TDATACHK),
    .TLASTCHK(dut_if.TLASTCHK), .TWAKEUPCHK(dut_if.TWAKEUPCHK)
  );

  initial begin
    uvm_config_db #(virtual axi_stream_slave_vip_if #(
      .DATA_W(`AXI_DATA_W), .ID_W(`AXI_ID_W), .DEST_W(`AXI_DEST_W),
      .USER_W(`AXI_USER_W), .HAS_PAR(`AXI_HAS_PAR), .HAS_WAKE(`AXI_HAS_WAKE)
    ))::set(null, "uvm_test_top", "vif", dut_if);
    uvm_top.set_timeout(100000000, 1);   // 100us in ps
    run_test();
  end

  initial if ($test$plusargs("WAVES")) $wlfdumpvars(0, axi_stream_slave_vip_tb_top);

endmodule

// =============================================================================
// AXI-Stream Master Transmitter DUT stub
// Emits packets; honours dut_ctl knobs to produce protocol violations so the
// Slave VIP's checkers can be proven non-vacuous. Uses only 2-state-safe logic.
// =============================================================================
module axi_stream_master_dut_stub #(
  parameter int DATA_W=32, parameter int ID_W=8, parameter int DEST_W=4, parameter int USER_W=4
)(
  input  logic                ACLK,
  input  logic                ARESETn,
  input  logic                TREADY,
  input  logic                TREADYCHK,
  output logic                TVALID,
  output logic [DATA_W-1:0]   TDATA,
  output logic [DATA_W/8-1:0] TSTRB,
  output logic [DATA_W/8-1:0] TKEEP,
  output logic                TLAST,
  output logic [ID_W-1:0]     TID,
  output logic [DEST_W-1:0]   TDEST,
  output logic [USER_W-1:0]   TUSER,
  output logic                TWAKEUP,
  output logic                TVALIDCHK,
  output logic [DATA_W/8-1:0] TDATACHK,
  output logic                TLASTCHK,
  output logic                TWAKEUPCHK
);
  localparam int STRB_W = DATA_W/8;

  function automatic logic odd_par(logic [7:0] b); return ~(^b); endfunction
  function automatic logic [STRB_W-1:0] datachk(logic [DATA_W-1:0] d);
    logic [STRB_W-1:0] c;
    for (int i=0;i<STRB_W;i++) c[i]=odd_par(d[8*i +: 8]);
    return c;
  endfunction

  task automatic drive_idle();
    TVALID<=0; TLAST<=0; TDATA<='0; TKEEP<='0; TSTRB<='0; TID<='0; TDEST<='0; TUSER<='0;
    TWAKEUP<=0; TVALIDCHK<=~1'b0; TLASTCHK<=~1'b0; TWAKEUPCHK<=~1'b0; TDATACHK<=datachk('0);
  endtask

  // Emit one packet of `beats` beats with identity {id,dest}.
  task automatic emit_packet(int beats, logic [ID_W-1:0] id, logic [DEST_W-1:0] dest);
    logic [DATA_W-1:0] d; logic [STRB_W-1:0] k, chk; logic lastb;
    // TWAKEUP one cycle before TVALID, unless the no_wake_lead knob is set.
    if (!axi_stream_slave_vip_dut_ctl::no_wake_lead) begin
      TWAKEUP<=1; TWAKEUPCHK<=~1'b1; @(posedge ACLK);
    end
    for (int b=0;b<beats;b++) begin
      d = $urandom; k = '1;
      // reserved-qualifier violation on lane 0
      if (axi_stream_slave_vip_dut_ctl::reserved_qual) begin k[0]=1'b0; TSTRB<={{(STRB_W-1){1'b0}},1'b1}; end
      else TSTRB<=k;
      // tlast_glitch: assert TLAST early (mid-packet) => premature boundary
      lastb = (b==beats-1);
      if (axi_stream_slave_vip_dut_ctl::tlast_glitch && b==0 && beats>1) lastb = 1'b1;
      chk = datachk(d);
      if (axi_stream_slave_vip_dut_ctl::parity_fault) chk[0] = ~chk[0];
      TDATA<=d; TKEEP<=k; TLAST<=lastb; TID<=id; TDEST<=dest; TUSER<=b[USER_W-1:0];
      TDATACHK<=chk; TVALIDCHK<=~1'b1; TLASTCHK<=~lastb;
      TVALID<=1;
      @(posedge ACLK);
      // Hold TVALID until TREADY, unless drop_valid knob (retract mid-stall).
      begin int s=0;
        while (TREADY!==1'b1) begin
          if (axi_stream_slave_vip_dut_ctl::drop_valid && s>=2) begin TVALID<=0; @(posedge ACLK); break; end
          if (axi_stream_slave_vip_dut_ctl::mutate_payload && s==1) begin TDATA<=~d; TKEEP<=~k; end
          @(posedge ACLK); s++;
          if (s>200) break;   // safety
        end
      end
      TVALID<=0;
      if (axi_stream_slave_vip_dut_ctl::tlast_glitch && b==0 && beats>1) break; // stop after premature TLAST
    end
    TWAKEUP<=0; TWAKEUPCHK<=~1'b0;
  endtask

  initial begin
    logic [ID_W-1:0] id; logic [DEST_W-1:0] dest;
    drive_idle();
    wait (ARESETn===1'b1);
    @(posedge ACLK);
    forever begin
      id = $urandom; dest = $urandom;
      emit_packet($urandom_range(1,8), id, dest);
      repeat ($urandom_range(0,3)) @(posedge ACLK);
    end
  end

  // Force idle whenever reset is active.
  always @(negedge ARESETn) drive_idle();

endmodule
