// =============================================================================
// AXI5-Stream Slave VIP — Interface
// Verification Role: SLAVE (Receiver) — VIP drives TREADY + TREADYCHK ONLY.
// DUT Role:          MASTER (Transmitter) — DUT drives all payload/control/check.
//
// Direction is INVERTED relative to the master VIP: everything except
// TREADY/TREADYCHK is a DUT output and thus an input to the VIP.
// ACLK/ARESETn are 4-state `logic` input PORTS (SKILL §7.1, §7.2).
// =============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_IF_SV
`define AXI_STREAM_SLAVE_VIP_IF_SV

`include "axi_stream_slave_vip_defines.sv"

interface axi_stream_slave_vip_if #(
  parameter int DATA_W   = `AXI_DATA_W,
  parameter int ID_W     = `AXI_ID_W,
  parameter int DEST_W   = `AXI_DEST_W,
  parameter int USER_W   = `AXI_USER_W,
  parameter bit HAS_PAR  = `AXI_HAS_PAR,
  parameter bit HAS_WAKE = `AXI_HAS_WAKE
)(
  input logic ACLK,
  input logic ARESETn
);

  localparam int STRB_W = DATA_W / 8;

  // ── Driven by the DUT Master (Transmitter) — OBSERVED by the Slave VIP ─────
  logic                TVALID;
  logic [DATA_W-1:0]   TDATA;
  logic [STRB_W-1:0]   TSTRB;
  logic [STRB_W-1:0]   TKEEP;
  logic                TLAST;
  logic [ID_W-1:0]     TID;
  logic [DEST_W-1:0]   TDEST;
  logic [USER_W-1:0]   TUSER;
  logic                TWAKEUP;
  logic                TVALIDCHK;
  logic [STRB_W-1:0]   TDATACHK;
  logic                TLASTCHK;
  logic                TWAKEUPCHK;

  // ── Driven by the Slave VIP (Receiver) — the ONLY VIP outputs ─────────────
  logic                TREADY;
  logic                TREADYCHK;

  // ── Driver clocking block — VIP drives ONLY TREADY/TREADYCHK ──────────────
  // Any other output here would be a role-safety failure.
  clocking cb_drv @(posedge ACLK);
    output TREADY, TREADYCHK;
    input  TVALID, TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER, TWAKEUP;
    input  TVALIDCHK, TDATACHK, TLASTCHK, TWAKEUPCHK;
  endclocking

  // ── Monitor clocking block (passive) ──────────────────────────────────────
  clocking cb_mon @(posedge ACLK);
    input TVALID, TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER, TWAKEUP;
    input TVALIDCHK, TDATACHK, TLASTCHK, TWAKEUPCHK;
    input TREADY, TREADYCHK;
    input ARESETn;
  endclocking

endinterface

`endif
