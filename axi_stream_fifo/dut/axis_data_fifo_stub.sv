// ─────────────────────────────────────────────────────────────────────────────
// axis_data_fifo_v2_0_0_top  —  Behavioral stub
//
// Mimics the Xilinx AXI4-Stream Data FIFO v2.0 functional interface for
// simulation.  Replace with the actual Xilinx IP simulation model when running
// against the production netlist.
//
// What this stub models:
//   • Single-clock domain (C_IS_ACLK_ASYNC=0 — m_axis_aclk is ignored)
//   • AXI4-Stream handshake on slave and master ports
//   • FIFO depth = C_FIFO_DEPTH beats
//   • Status flags: almost_empty, prog_empty, almost_full, prog_full
//   • All payload signals: TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER
//
// What this stub does NOT model:
//   • Store-and-forward mode (C_FIFO_MODE=1): data appears on master port
//     as soon as a beat is stored, not after full packet arrives.
//   • ECC (sbiterr/dbiterr are always 0; injectsbiterr/injectdbiterr ignored)
//   • C_AXIS_SIGNAL_SET masking (all connected signals are passed through)
//   • Asynchronous clock crossing (C_IS_ACLK_ASYNC=1)
// ─────────────────────────────────────────────────────────────────────────────
`timescale 1ns/1ps

module axis_data_fifo_v2_0_0_top #(
  parameter string       C_FAMILY             = "zynq",
  parameter int unsigned C_AXIS_TDATA_WIDTH   = 32,
  parameter int unsigned C_AXIS_TID_WIDTH     = 8,
  parameter int unsigned C_AXIS_TDEST_WIDTH   = 4,
  parameter int unsigned C_AXIS_TUSER_WIDTH   = 4,
  parameter logic [31:0] C_AXIS_SIGNAL_SET    = 32'h3,
  parameter int unsigned C_FIFO_DEPTH         = 512,
  parameter int unsigned C_FIFO_MODE          = 1,
  parameter int unsigned C_IS_ACLK_ASYNC      = 0,
  parameter int unsigned C_SYNCHRONIZER_STAGE = 3,
  parameter int unsigned C_ACLKEN_CONV_MODE   = 0,
  parameter int unsigned C_ECC_MODE           = 0,
  parameter string       C_FIFO_MEMORY_TYPE   = "auto",
  parameter int unsigned C_USE_ADV_FEATURES   = 825241648,
  parameter int unsigned C_PROG_EMPTY_THRESH  = 5,
  parameter int unsigned C_PROG_FULL_THRESH   = 11
) (
  // ── Slave (write) port ──────────────────────────────────────────────────────
  input  logic                                  s_axis_aresetn,
  input  logic                                  s_axis_aclk,
  input  logic                                  s_axis_aclken,
  input  logic                                  s_axis_tvalid,
  output logic                                  s_axis_tready,
  input  logic [C_AXIS_TDATA_WIDTH-1:0]         s_axis_tdata,
  input  logic [C_AXIS_TDATA_WIDTH/8-1:0]       s_axis_tstrb,
  input  logic [C_AXIS_TDATA_WIDTH/8-1:0]       s_axis_tkeep,
  input  logic                                  s_axis_tlast,
  input  logic [C_AXIS_TID_WIDTH-1:0]           s_axis_tid,
  input  logic [C_AXIS_TDEST_WIDTH-1:0]         s_axis_tdest,
  input  logic [C_AXIS_TUSER_WIDTH-1:0]         s_axis_tuser,

  // ── Master (read) port ──────────────────────────────────────────────────────
  input  logic                                  m_axis_aclk,    // unused (sync mode)
  input  logic                                  m_axis_aclken,  // unused in stub
  output logic                                  m_axis_tvalid,
  input  logic                                  m_axis_tready,
  output logic [C_AXIS_TDATA_WIDTH-1:0]         m_axis_tdata,
  output logic [C_AXIS_TDATA_WIDTH/8-1:0]       m_axis_tstrb,
  output logic [C_AXIS_TDATA_WIDTH/8-1:0]       m_axis_tkeep,
  output logic                                  m_axis_tlast,
  output logic [C_AXIS_TID_WIDTH-1:0]           m_axis_tid,
  output logic [C_AXIS_TDEST_WIDTH-1:0]         m_axis_tdest,
  output logic [C_AXIS_TUSER_WIDTH-1:0]         m_axis_tuser,

  // ── Status / advanced-feature outputs ──────────────────────────────────────
  output logic [31:0]                           axis_wr_data_count,
  output logic [31:0]                           axis_rd_data_count,
  output logic                                  almost_empty,
  output logic                                  prog_empty,
  output logic                                  almost_full,
  output logic                                  prog_full,
  output logic                                  sbiterr,
  output logic                                  dbiterr,
  input  logic                                  injectsbiterr,  // ignored
  input  logic                                  injectdbiterr   // ignored
);

  localparam STRB_W = C_AXIS_TDATA_WIDTH / 8;

  // ── FIFO entry type ─────────────────────────────────────────────────────────
  typedef struct packed {
    logic [C_AXIS_TDATA_WIDTH-1:0]  tdata;
    logic [STRB_W-1:0]              tstrb;
    logic [STRB_W-1:0]              tkeep;
    logic                           tlast;
    logic [C_AXIS_TID_WIDTH-1:0]    tid;
    logic [C_AXIS_TDEST_WIDTH-1:0]  tdest;
    logic [C_AXIS_TUSER_WIDTH-1:0]  tuser;
  } fifo_entry_t;

  // ── Internal storage ─────────────────────────────────────────────────────────
  fifo_entry_t  mem    [0:C_FIFO_DEPTH-1];
  int unsigned  wr_ptr = 0;
  int unsigned  rd_ptr = 0;
  int unsigned  count  = 0;

  // ── Status flags ─────────────────────────────────────────────────────────────
  logic full, empty;
  assign full  = (count == C_FIFO_DEPTH);
  assign empty = (count == 0);

  assign s_axis_tready = s_axis_aresetn & ~full;
  assign m_axis_tvalid = s_axis_aresetn & ~empty;

  // ── Read-side outputs from the current read pointer ─────────────────────────
  assign m_axis_tdata  = empty ? '0 : mem[rd_ptr].tdata;
  assign m_axis_tstrb  = empty ? '0 : mem[rd_ptr].tstrb;
  assign m_axis_tkeep  = empty ? '0 : mem[rd_ptr].tkeep;
  assign m_axis_tlast  = empty ? '0 : mem[rd_ptr].tlast;
  assign m_axis_tid    = empty ? '0 : mem[rd_ptr].tid;
  assign m_axis_tdest  = empty ? '0 : mem[rd_ptr].tdest;
  assign m_axis_tuser  = empty ? '0 : mem[rd_ptr].tuser;

  // ── Sequential: write, read, count update ───────────────────────────────────
  always_ff @(posedge s_axis_aclk or negedge s_axis_aresetn) begin
    if (!s_axis_aresetn) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      count  <= 0;
    end else begin
      logic do_wr, do_rd;
      do_wr = s_axis_tvalid && s_axis_tready;
      do_rd = m_axis_tvalid && m_axis_tready;

      if (do_wr) begin
        mem[wr_ptr] <= '{
          tdata : s_axis_tdata,
          tstrb : s_axis_tstrb,
          tkeep : s_axis_tkeep,
          tlast : s_axis_tlast,
          tid   : s_axis_tid,
          tdest : s_axis_tdest,
          tuser : s_axis_tuser
        };
        wr_ptr <= (wr_ptr == C_FIFO_DEPTH - 1) ? 0 : wr_ptr + 1;
      end

      if (do_rd)
        rd_ptr <= (rd_ptr == C_FIFO_DEPTH - 1) ? 0 : rd_ptr + 1;

      case ({do_wr, do_rd})
        2'b10 : count <= count + 1;
        2'b01 : count <= count - 1;
        default: ;  // 00 or 11 — count unchanged
      endcase
    end
  end

  // ── Status outputs ───────────────────────────────────────────────────────────
  assign axis_wr_data_count = 32'(count);
  assign axis_rd_data_count = 32'(count);
  assign almost_empty       = (count <= 1);
  assign prog_empty         = (count <= C_PROG_EMPTY_THRESH);
  assign almost_full        = (count >= C_FIFO_DEPTH - 1);
  assign prog_full          = (count >= C_PROG_FULL_THRESH);
  assign sbiterr            = 1'b0;
  assign dbiterr            = 1'b0;

endmodule
