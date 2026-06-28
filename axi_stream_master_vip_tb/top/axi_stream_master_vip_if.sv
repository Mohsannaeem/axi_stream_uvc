// AXI-Stream Master VIP Interface
// Verification Role: MASTER (Transmitter)
// DUT Role:          SLAVE  (Receiver)
`ifndef AXI_STREAM_MASTER_VIP_IF_SV
`define AXI_STREAM_MASTER_VIP_IF_SV

`include "axi_stream_master_vip_defines.sv"

interface axi_stream_master_vip_if(input logic ACLK, ARESETn);

  // ── Primary payload signals (driven by Master VIP) ───────────────────────────
  logic                        TVALID;
  logic [`TDATA_WIDTH-1:0]     TDATA;
  logic [`TSTRB_WIDTH-1:0]     TSTRB;
  logic [`TSTRB_WIDTH-1:0]     TKEEP;
  logic                        TLAST;
  logic [`TID_WIDTH-1:0]       TID;
  logic [`TDEST_WIDTH-1:0]     TDEST;
  logic [`TUSER_WIDTH-1:0]     TUSER;
  logic                        TWAKEUP;

  // ── AXI5 Parity check signals (driven by Master VIP) ─────────────────────────
  logic                        TVALIDCHK;
  logic [`TSTRB_WIDTH-1:0]     TDATACHK;
  logic                        TLASTCHK;
  logic                        TWAKEUPCHK;

  // ── DUT Slave Receiver output signals (observed by Master VIP) ───────────────
  logic                        TREADY;
  logic                        TREADYCHK;

  // ── Driver clocking block (Master VIP drives on posedge ACLK) ────────────────
  clocking cb_drv @(posedge ACLK);
    output TVALID, TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER, TWAKEUP;
    output TVALIDCHK, TDATACHK, TLASTCHK, TWAKEUPCHK;
    input  TREADY, TREADYCHK;
  endclocking

  // ── Monitor clocking block (passive observation) ─────────────────────────────
  clocking cb_mon @(posedge ACLK);
    input TVALID, TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER, TWAKEUP;
    input TVALIDCHK, TDATACHK, TLASTCHK, TWAKEUPCHK;
    input TREADY, TREADYCHK;
    input ARESETn;
  endclocking

endinterface

`endif
