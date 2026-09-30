//-----------------------------------------------------------------------------
// Module Description:
//-----------------------------------------------------------------------------
// This module implements the SPI Receive (RX) FSM for 8-bit data transfer.
//
// - Receives serial data from the slave through the MISO/s2mdata signal.
// - Supports both MSB-first and LSB-first data transfer.
// - Uses a 3-bit counter to track the 8 received bits.
// - Controls chip select signals for two slave devices.
// - The FSM consists of four states:
//      IDLE        : Waits for the start signal.
//      ASSERT_CS   : Selects the required slave based on int1/int2.
//      TRANSFER    : Samples MISO data on the rising edge of SCLK.
//      DEASSERT_CS : Deasserts the chip select after 8 bits.
// - The design uses a fixed SPI clock mode and does not support configurable
//   CPOL and CPHA.
// - The design follows SPI Mode 0 timing, as CPOL and CPHA are not configurable.
// - Reset clears the received data, counter, chip select signals, and FSM state.
//
// Author : Mannem Deepika
// GitHub : https://github.com/DeepikaMannem
//-----------------------------------------------------------------------------

module fsm_rx (
  input wire sclk,
  input wire rst,
  input wire s2mdata,
  input wire start,
  input wire int1,
  input wire int2,
  input wire msb,
  
  
  output reg [7:0] rx_data
  
  
);
  reg cs1;
  reg cs2;
  reg [1:0] state = 0;
  reg [2:0] rx_count = 0;
  parameter IDLE = 2'd0;
  parameter ASSERT_CS = 2'd1;
  parameter TRANSFER = 2'd2;
  parameter DEASSERT_CS = 2'd3;
  
  
  always@(posedge sclk) begin
    if (rst) begin
      rx_data <= 0;
      cs1 <= 1;
      cs2 <= 1;
      rx_count <= 0;
      state <= IDLE;
    end else begin
      case(state)
        IDLE:
          if (start) begin
            state <= ASSERT_CS;
          end else begin
            state <= IDLE;
          end
        ASSERT_CS:
          if (int1) begin
            cs1 <= 0;
            cs2 <= 1;
            state <= TRANSFER;
          end else if (int2) begin
            cs2 <= 0;
            cs1 <= 1;
            state <= TRANSFER;
          end else begin
            cs1 <= 1;
            cs2 <= 1;
            state <= ASSERT_CS;
          end
        TRANSFER: begin
          if (msb) begin
            	rx_data[7 - rx_count] <= s2mdata;
          end else begin
            rx_data [rx_count] <= s2mdata; 
          end
          if (rx_count == 3'd7) begin
          		rx_count <= 0;
                state <= DEASSERT_CS;
        	end else begin
         		 rx_count <= rx_count + 1;
        	end
        end
        DEASSERT_CS:  begin      
           cs1 <= 1'b1; 
           cs2 <= 1'b1; 
           state <= IDLE;
        end
        default : begin
          cs1 <= 1;
          cs2 <= 1;
          state <= IDLE;
        end
      endcase
    end
  end
endmodule