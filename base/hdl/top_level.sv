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

  assign led = sw; //for debugging
  //shut up those rgb LEDs (active high):
  // assign rgb1= 0;
  // assign rgb0 = 0;

  logic sys_rst;
  assign sys_rst = btn[0];





  logic clk_in;
  logic rst_in;
  logic data_valid_in [3:0];
  logic [31:0] vertex_pos_in [3:0];
  logic [31:0] query_pos_in [3:0];
  logic [31:0] distance_sq_out;
  logic data_valid_out;

  logic [31:0] vertex_pos_in0;
  logic [31:0] vertex_pos_in1;
  logic [31:0] vertex_pos_in2;
  logic [31:0] vertex_pos_in3;
  logic [31:0] query_pos_in0;
  logic [31:0] query_pos_in1;
  logic [31:0] query_pos_in2;
  logic [31:0] query_pos_in3;
  logic data_valid_in0;
  logic data_valid_in1;
  logic data_valid_in2;
  logic data_valid_in3;

//   logic [31:0] intermediate_subs_out;

  distance #(.DIM(4)) distance_calculator(
    .clk_in(clk_100mhz),
    .rst_in(sys_rst),
    .data_valid_in(data_valid_in),
    .vertex_pos_in(vertex_pos_in),
    .query_pos_in(query_pos_in),
    .distance_sq_out(distance_sq_out),
    .data_valid_out(data_valid_out)
    // .intermediate_subs_out(intermediate_subs_out)
  );




  // manta man (
  //     .clk(clk_100mhz),
  //     .rx(uart_rxd),
  //     .tx(uart_txd),
  //     .val1_in(val1_in),
  //     .val2_in(val2_in),
  //     .val3_out(divisor_in),
  //    .val4_out(dividend_in));
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
