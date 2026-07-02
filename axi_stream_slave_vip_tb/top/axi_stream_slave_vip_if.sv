// AXI-Stream Slave VIP Interface
// Verification Role: SLAVE — VIP drives TREADY + TREADYCHK
// DUT Role:          MASTER — DUT drives all payload + check signals
`ifndef AXI_STREAM_SLAVE_VIP_IF_SV
`define AXI_STREAM_SLAVE_VIP_IF_SV

interface axi_stream_slave_vip_if #(
  parameter int DATA_W  = 32,
  parameter int ID_W    = 8,
  parameter int DEST_W  = 4,
  parameter int USER_W  = 4,
  parameter bit HAS_PAR = 1,
  parameter bit HAS_WAKE= 1
)(input logic ACLK, input logic ARESETn);

  // ── DUT Master outputs (inputs to VIP) ──────────────────────────────────────
  logic                       TVALID;
  logic [DATA_W-1:0]          TDATA;
  logic [DATA_W/8-1:0]        TKEEP;
  logic [DATA_W/8-1:0]        TSTRB;
  logic                       TLAST;
  logic [ID_W-1:0]            TID;
  logic [DEST_W-1:0]          TDEST;
  logic [USER_W-1:0]          TUSER;
  logic                       TWAKEUP;
  // AXI5 check signals driven by DUT Master
  logic [DATA_W/8-1:0]        TDATACHK;
  logic                       TVALIDCHK;
  logic                       TLASTCHK;
  logic                       TWAKEUPCHK;

  // ── VIP Slave outputs (driven by VIP Slave agent) ───────────────────────────
  logic                       TREADY;
  logic                       TREADYCHK;   // AXI5: odd parity of TREADY

  // ── Driver clocking block — VIP drives TREADY/TREADYCHK, samples DUT inputs ─
  clocking cb_drv @(posedge ACLK);
    output TREADY, TREADYCHK;
    input  TVALID, TDATA, TKEEP, TSTRB, TLAST, TID, TDEST, TUSER, TWAKEUP;
    input  TDATACHK, TVALIDCHK, TLASTCHK, TWAKEUPCHK;
  endclocking

  // ── Monitor clocking block — pure observation of all signals ─────────────────
  clocking cb_mon @(posedge ACLK);
    input  ARESETn, TVALID, TREADY, TDATA, TKEEP, TSTRB, TLAST;
    input  TID, TDEST, TUSER, TWAKEUP;
    input  TDATACHK, TVALIDCHK, TLASTCHK, TWAKEUPCHK, TREADYCHK;
  endclocking

endinterface

`endif
