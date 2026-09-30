//-----------------------------------------------------------------------------
// Module Description:
//-----------------------------------------------------------------------------
// This module implements the top-level SPI Master design.
//
// - Instantiates separate TX and RX FSMs for SPI communication.
// - The TX FSM handles parallel-to-serial data conversion and MOSI output.
// - The RX FSM handles serial-to-parallel data conversion and MISO input.
// - Supports communication with two slave devices.
// - The TX and RX operations can occur simultaneously, providing full-duplex
//   SPI communication.
// - Supports both MSB-first and LSB-first data transfer.
// - The design uses a fixed SPI clock mode and does not support configurable
//   CPOL and CPHA.
// - The design follows SPI Mode 0 timing.
// - tx_fsm.v and rx_fsm.v are included as separate design files.
//
// Author : Mannem Deepika
// GitHub : https://github.com/DeepikaMannem
//-----------------------------------------------------------------------------


`include "tx_fsm.v"
`include "rx_fsm.v"

module spi (
  input wire start,
  input wire msb,
  input wire int1, int2,
  input wire slave1, slave2,
  input wire sclk, rst,
  input wire [7:0] m2sdata,
  input wire miso,
  output reg mosi,
  output reg [7:0] rx_data
);
  fsm_tx tx_fsm (
    .start     (start),
    .msb       (msb),
    .slave1    (slave1),
    .slave2    (slave2),
    .sclk      (sclk),
    .rst       (rst),
    .m2sdata   (m2sdata),
    .tx_data   (mosi)
  );
  fsm_rx rx_fsm (
    .start      (start),
    .msb        (msb),
    .sclk       (sclk),
    .int1       (int1),
    .int2       (int2),
    .rst        (rst),
    .rx_data    (rx_data),
    .s2mdata    (miso)
  );
  
endmodule
  