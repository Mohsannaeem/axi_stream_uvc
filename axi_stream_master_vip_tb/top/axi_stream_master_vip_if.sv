// =============================================================================
// AXI5-Stream Master VIP — Interface
// Verification Role: MASTER (Transmitter)
// DUT Role:          SLAVE  (Receiver)
//
// Parameter defaults are driven by the defines macros, so the interface and the
// macros can never disagree. ACLK and ARESETn are 4-state `logic` PORTS (never
// `bit`, never internal signals) so X/Z propagate and tb_top never has to drive
// an interface member directly.
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_IF_SV
`define AXI_STREAM_MASTER_VIP_IF_SV

`include "axi_stream_master_vip_defines.sv"

interface axi_stream_master_vip_if #(
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

  // ── Driven by the Master VIP (Transmitter) ─────────────────────────────────
  logic                TVALID;
  logic [DATA_W-1:0]   TDATA;
  logic [STRB_W-1:0]   TSTRB;
  logic [STRB_W-1:0]   TKEEP;
  logic                TLAST;
  logic [ID_W-1:0]     TID;
  logic [DEST_W-1:0]   TDEST;
  logic [USER_W-1:0]   TUSER;
  logic                TWAKEUP;

  // ── AXI5 parity check signals, driven by the Master VIP (Section 5.5) ──────
  logic                TVALIDCHK;
  logic [STRB_W-1:0]   TDATACHK;
  logic                TLASTCHK;
  logic                TWAKEUPCHK;

  // ── Driven by the DUT Slave Receiver — OBSERVED by the VIP, never driven ───
  logic                TREADY;
  logic                TREADYCHK;

  // ── Driver clocking block ─────────────────────────────────────────────────
  // No explicit input/output skews: rely on simulator default edge sampling so
  // timing stays faithful to the RTL clock.
  clocking cb_drv @(posedge ACLK);
    output TVALID, TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER, TWAKEUP;
    output TVALIDCHK, TDATACHK, TLASTCHK, TWAKEUPCHK;
    input  TREADY, TREADYCHK;
  endclocking

  // ── Monitor clocking block (passive) ──────────────────────────────────────
  // ARESETn is an input here only, and is never an output of any clocking block.
  clocking cb_mon @(posedge ACLK);
    input TVALID, TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER, TWAKEUP;
    input TVALIDCHK, TDATACHK, TLASTCHK, TWAKEUPCHK;
    input TREADY, TREADYCHK;
    input ARESETn;
  endclocking

endinterface

`endif
