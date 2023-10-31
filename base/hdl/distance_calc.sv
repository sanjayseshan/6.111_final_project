`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module distance#(parameter DIMS = 2)(
  input wire clk_100mhz,
  input wire data_valid_in,
  input wire[31:0] dividend_in;
  input wire[31:0] divisor_in;
  output logic [15:0] led //16 green output LEDs (located right above switches)
  output logic [31:0] result;
  );


//   logic[31:0] dividend_in;
//   logic[31:0] divisor_in;
//   logic data_valid_in;
//   logic[31:0] quotient_out;
//   logic[31:0] remainder_out;
//   // logic data_valid_out;
//   // logic error_out;
//   // logic busy_out;
//   logic[31:0] val1_in;
//   logic[31:0] val2_in;


  logic [31:0]m_axis_result_tdata1;
  logic m_axis_result_tvalid1;
  logic [31:0]m_axis_result_tdata2;
  logic m_axis_result_tvalid2;

  logic m_axis_result_tvalid3;

//   logic m_axis_result_tvalid4;
//   logic [31:0]m_axis_result_tdata4;



  // multiplier(.aclk(clk_100mhz), .s_axis_a_tvalid(data_valid_in), .s_axis_a_tready(), 
  // .s_axis_a_tdata(), .s_axis_b_tvalid(), .s_axis_b_tready(), .s_axis_b_tdata(), .m_axis_result_tvalid(), 
  // .m_axis_result_tready(), .m_axis_result_tdata())


  multiplier mult1(.aclk(clk_100mhz), .s_axis_a_tvalid(data_valid_in),
  .s_axis_a_tdata(dividend_in), .s_axis_b_tvalid(data_valid_in),  .s_axis_b_tdata(dividend_in), 
  .m_axis_result_tready(1), .m_axis_result_tvalid(m_axis_result_tvalid1), .m_axis_result_tdata(m_axis_result_tdata1));

  multiplier mult2(.aclk(clk_100mhz), .s_axis_a_tvalid(data_valid_in),
  .s_axis_a_tdata(divisor_in), .s_axis_b_tvalid(data_valid_in),  .s_axis_b_tdata(divisor_in), 
  .m_axis_result_tready(1), .m_axis_result_tvalid(m_axis_result_tvalid2), .m_axis_result_tdata(m_axis_result_tdata2));


  adder add(.aclk(clk_100mhz), .s_axis_a_tvalid(m_axis_result_tvalid1), 
  .s_axis_a_tdata(m_axis_result_tdata1), .s_axis_b_tvalid(m_axis_result_tvalid2), .s_axis_b_tdata(m_axis_result_tdata2), .m_axis_result_tvalid(m_axis_result_tvalid3), 
  .m_axis_result_tready(1), .m_axis_result_tdata(result));

//   inv_sqrt isqrt (.aclk(clk_100mhz), .s_axis_a_tvalid(m_axis_result_tvalid3), 
//   .s_axis_a_tdata(m_axis_result_tdata3), .m_axis_result_tvalid(m_axis_result_tvalid4), .m_axis_result_tready(1), .m_axis_result_tdata(m_axis_result_tdata4));


endmodule // top_level

`default_nettype wire
