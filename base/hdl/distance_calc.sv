`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module distance #(parameter DIM = 2)(
  input wire clk_in,
  input wire rst_in,
  input wire data_valid_in,
  input wire [31:0] vertex_in;
  input wire [31:0] query_in;
  output logic [15:0] distance_out,
  output logic valid_data_out
  );


  logic [31:0] point_mul_tdata, query_mul_tdata;
  logic point_mul_tvalid, query_mul_tvalid;



  multiplier mult1(
    .aclk(clk_in), 

    .s_axis_a_tvalid(data_valid_in),
    .s_axis_a_tdata(vertex_in),

    .s_axis_b_tvalid(data_valid_in),
    .s_axis_b_tdata(vertex_in), 

    .m_axis_result_tready(1'b1), 
    .m_axis_result_tvalid(point_mul_tvalid), 
    .m_axis_result_tdata(point_mul_tdata)
    );



  multiplier mult2(
    .aclk(clk_in), 
    
    .s_axis_a_tvalid(data_valid_in),
    .s_axis_a_tdata(query_in), 

    .s_axis_b_tvalid(data_valid_in),  
    .s_axis_b_tdata(query_in), 

    .m_axis_result_tready(1'b1), 
    .m_axis_result_tvalid(query_mul_tvalid), 
    .m_axis_result_tdata(query_mul_tdata)
    );



  adder add(
    .aclk(clk_in), 

    .s_axis_a_tvalid(point_mul_tvalid), 
    .s_axis_a_tdata(point_mul_tdata), 

    .s_axis_b_tvalid(query_mul_tvalid), 
    .s_axis_b_tdata(query_mul_tdata), 

    .m_axis_result_tvalid(valid_data_out), 
    .m_axis_result_tready(1'b1), 
    .m_axis_result_tdata(distance_out)
    );



endmodule // top_level

`default_nettype wire
