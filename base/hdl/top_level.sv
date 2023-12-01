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

  logic [31:0] vertex_in;
  logic [31:0] query_in [4-1:0];
  logic [31:0] top_k_out [4:0];


  bfis #(.DIM(4), .PQ_LENGTH(8)) main(
  .clk_in(clk_100mhz),
  .rst_in(sys_rst),
  .vertex_in(vertex_in),
  .vertex_valid_in(1),
  .query_in(query_in),
  .k_in(4),
  .top_k_out(top_k_out),
  .valid_out()
  );

  logic [2:0] i;

  always_ff @( posedge clk_100mhz ) begin 
    if (sys_rst) i <= 0;
    else begin
      if (i==4) i<=0;
      else i<=i+1;
    end
    
  end


  manta man (
      .clk(clk_100mhz),
      .rx(uart_rxd),
      .tx(uart_txd),
      .val1_in(vertex_in),
      .val2_in(query_in[i]),
      .val3_out(top_k_out[0]),
      .val4_out(top_k_out[1])
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
