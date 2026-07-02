// AXI-Stream Master VIP Interface
// Verification Role: MASTER (Transmitter)
// DUT Role:          SLAVE  (Receiver)
`ifndef AXI_STREAM_MASTER_VIP_IF_SV
`define AXI_STREAM_MASTER_VIP_IF_SV

interface axi_stream_master_vip_if #(
  parameter int DATA_W  = 32,
  parameter int ID_W    = 8,
  parameter int DEST_W  = 4,
  parameter int USER_W  = 4,
  parameter bit HAS_PAR = 1,
  parameter bit HAS_WAKE= 1
)(input logic ACLK, input logic ARESETn);

  // ── Primary payload signals (driven by Master VIP) ───────────────────────────
  logic                        TVALID;
  logic [DATA_W-1:0]           TDATA;
  logic [DATA_W/8-1:0]         TSTRB;
  logic [DATA_W/8-1:0]         TKEEP;
  logic                        TLAST;
  logic [ID_W-1:0]             TID;
  logic [DEST_W-1:0]           TDEST;
  logic [USER_W-1:0]           TUSER;
  logic                        TWAKEUP;

  // ── AXI5 Parity check signals (driven by Master VIP) ─────────────────────────
  logic                        TVALIDCHK;
  logic [DATA_W/8-1:0]         TDATACHK;
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
