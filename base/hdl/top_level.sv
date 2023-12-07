`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module top_level(
  input wire clk_100mhz,
  input wire [15:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  input wire uart_rxd,
  output wire uart_txd,
  output logic [15:0] led //16 green output LEDs (located right above switches)
  );

  // assign led = sw; //for debugging
  //shut up those rgb LEDs (active high):
  // assign rgb1= 0;
  // assign rgb0 = 0;

  logic [2:0] state;

  logic sys_rst;
  assign sys_rst = btn[0];

  logic valid_out;

  logic [31:0] vertex_in;
  logic [31:0] query_in [4-1:0];
  logic [31:0] query_in_real [4-1:0];
  logic [31:0] top_k_out;

  always_ff @( posedge clk_100mhz ) begin 
    if (sys_rst) begin 
      query_in_real[0] = 5;
      query_in_real[1] = 7;
      query_in_real[2] = 1;
      query_in_real[3] = 1;
    end
    
  end


  bfis #(.DIM(4), .PQ_LENGTH(8)) main(
  .clk_in(clk_100mhz),
  .rst_in(sys_rst),
  .vertex_id_in(1),
  // .vertex_valid_in(1),
  .query_in(query_in_real),
  .k_in(4),
  .top_k_out(top_k_out),
  .valid_out(valid_out),
 .state(state)
  );

  logic [31:0] val_3, last_val_3, buf_k_out;

  always_ff @( posedge clk_100mhz ) begin
    last_val_3 <= val_3;
    
  end

  logic [31:0] buf_valid_out;

  FIFO #(.DATA_WIDTH(32),.DEPTH(4)) buf_out (
  .clk_in(clk_100mhz),
  .rst_in(sys_rst),
  .enq_data_in(top_k_out),
  .enq_in(valid_out),
  .deq_in(val_3 != last_val_3 && val_3 == 1),
  .full_out(),
  .data_out(buf_k_out),
  .empty_out(),
  .valid_out(buf_valid_out)
  );

  //   input wire clk_in,
 assign led = buf_k_out[15:0];
  // input wire rst_in,
  // input wire [31:0] vertex_id_in,
  // input wire [31:0] query_in [DIM-1:0],
  // input wire [15:0] k_in,
  // output logic [31:0] top_k_out,
  // output logic valid_out,
  // output logic [2:0] state

  logic [2:0] i;

  // always_ff @( posedge clk_100mhz ) begin 
  //   if (sys_rst) i <= 0;
  //   else begin
  //     if (i==4) i<=0;
  //     else i<=i+1;
  //   end
    
  // end


  manta man (
      .clk(clk_100mhz),
      .rx(uart_rxd),
      .tx(uart_txd),
      .val1_in(buf_k_out),
      .val2_in(buf_valid_out),
      .val3_out(val_3),
      .val4_out(0)
    );


  //   //lots of stuff


  // logic [13:0] cycle;

  // always_ff @(posedge clk_100mhz ) begin
  //   // if (sys_rst) begin
  //   //   cycle <= 0;
  //   //   data_valid_in <= 0;

  //   // end else begin
  //     if (cycle == 10000) begin
  //       cycle <= 0;
  //       data_valid_in <= 1;
  //     end else begin
  //       cycle <= cycle + 1;
  //       data_valid_in <= 0;
  //     end
  //   // end
  // end
   


endmodule // top_level

`default_nettype wire
