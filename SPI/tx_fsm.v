// Code your design here
module fsm_tx (
  input wire sclk,
  input wire rst,
  input wire [7:0] m2sdata,
  input wire start,
  input wire slave1,
  input wire slave2,
  input wire msb,
  
  
  output reg tx_data
  
  
);
  reg cs1;
  reg cs2;
  reg [1:0] state = 0;
  reg [2:0] count;
  parameter IDLE = 2'd0;
  parameter ASSERT_CS = 2'd1;
  parameter TRANSFER = 2'd2;
  parameter DEASSERT_CS = 2'd3;
  
  always@(posedge sclk) begin
    case(state)
      IDLE: 
        if(start) begin 
          state  <= ASSERT_CS;
        end else if (rst) begin
          state <= IDLE;
          count <= 0;
          tx_data <= 0;
          cs1 <= 1;
          cs2 <= 1;
        end 
      ASSERT_CS:
        if (rst) begin
          state <= IDLE;
          count <= 0;
          tx_data <= 0;
          cs1 <= 0;
          cs2 <= 0;
        end else if (slave1) begin
          cs1 <= 0; //selective slave1
          cs2 <= 1; //deselect
          state <= TRANSFER;
        end else if (slave2) begin
          cs1 <= 1;
          cs2 <= 0;
          state <= TRANSFER;
        end else begin
          cs1 <= 1;
          cs2 <= 1;
          state <= ASSERT_CS;
        end
      TRANSFER:
        if(rst) begin
          state <= IDLE;
          count <= 0;
          tx_data <= 0;
          cs1 <= 1;
          cs2 <= 1;
        end else if (!cs1 || !cs2) begin
          if (msb) begin
            tx_data <= m2sdata[7-count];
          end else begin
            tx_data <= m2sdata[count];
          end
          if (count == 3'd7) begin
            count <= 0;
            state <= DEASSERT_CS;
          end else begin
            count <= count+1;
          end
        end
       DEASSERT_CS:  begin      
           cs1 <= 1'b1; 
           cs2 <= 1'b1; 
           state <= IDLE;
       end
      default: begin
           cs1 <= 1'b1; 
           cs2 <= 1'b1; 
           state <= IDLE;
      end
    endcase
  end 
endmodule