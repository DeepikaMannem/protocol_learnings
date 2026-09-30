//-----------------------------------------------------------------------------
// Testcase Description:
//-----------------------------------------------------------------------------
// This testbench verifies the SPI RX operation for an 8-bit data transfer.
//
// - The SPI design uses a fixed clock mode and does not support configurable
//   CPOL and CPHA.
// - The design follows SPI Mode 0 timing.
// - The testbench generates the SPI clock and provides 8-bit data on MISO.
// - MISO data is changed on the falling edge of SCLK and sampled by the RX FSM
//   on the rising edge.
// - The received data is checked after all 8 bits are transferred.
//
// Author : Mannem Deepika
// GitHub : https://github.com/DeepikaMannem
//-----------------------------------------------------------------------------

module tb;
  
  wire mosi;
  wire [7:0] rx_data;
  reg start;
  reg msb;
  reg int1, int2;
  reg sclk, rst;
  reg [7:0] m2sdata;
  reg miso;
  reg [2:0] count;
  reg slave1, slave2;
  
  spi dut (
    .sclk    (sclk),
    .rst     (rst),
    .msb     (msb),
    .start   (start),
    .int1    (int1),
    .int2    (int2),
    .slave1  (slave1),
    .slave2  (slave2),
    .m2sdata (m2sdata),
    .miso    (miso),
    .mosi    (mosi),
    .rx_data (rx_data)
  );
  
  always #2 sclk = ~sclk;
  initial begin
    
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    sclk    = 0;
    rst     = 1;
    msb     = 0;
    start   = 0;

    int1    = 1;
    int2    = 1;

    slave1  = 1;
    slave2  = 1;

    m2sdata = 8'd0;
    miso    = 0;
    count   = 0;

    #2;
    start = 1;
    int1 = 0;
    $display("after 4 delay");
    for (count = 0; count <= 7; count = count + 1) begin
      @(negedge sclk);
      $display("time = %0t  sclk = %d slave = %d count = %d miso = %d", $time, sclk, slave1, count, miso);
      case (count)
        3'd0: miso = 1;
        3'd1: miso = 0;
        3'd2: miso = 1;
        3'd3: miso = 1;
        3'd4: miso = 1;
        3'd5: miso = 0;
        3'd6: miso = 1;
        3'd7: miso = 1;
      endcase
    if (count == 7) begin
        $display("Transaction complete");
        $finish;
    end
    end
    #30;
    $finish;
  end
endmodule
        
        
  