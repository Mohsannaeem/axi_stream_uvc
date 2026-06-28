// AXI-Stream Master VIP — Global Defines
// Verification Role: MASTER (VIP is Transmitter, drives TVALID/TDATA)
// DUT Role:          SLAVE (DUT drives TREADY)
`ifndef AXI_STREAM_MASTER_VIP_DEFINES_SV
`define AXI_STREAM_MASTER_VIP_DEFINES_SV

`define TDATA_WIDTH          32
`define TSTRB_WIDTH          (`TDATA_WIDTH/8)
`define TID_WIDTH             8
`define TDEST_WIDTH           4
`define TUSER_WIDTH           4
`define HAS_TKEEP             1
`define HAS_TSTRB             1
`define HAS_TLAST             1
`define HAS_TID               1
`define HAS_TDEST             1
`define HAS_TUSER             1
`define HAS_TWAKEUP           1
`define HAS_PARITY            1
`define CLK_PERIOD           10
`define TREADY_STALL_MAX     100
`define MAX_PACKET_BEATS     256
`define TREADY_WATCHDOG_MAX  100000

// Odd parity helpers:
//   1-bit signal x  → parity = ~x       (1 bit inverted to make count odd)
//   8-bit byte   b  → parity = ~^b      (even XOR reduction, then invert)

`endif
