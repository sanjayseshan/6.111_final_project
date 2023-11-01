`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module distance #(parameter DIM = 2)(
  input wire clk_in,
  input wire rst_in,
  input wire data_valid_in [DIM-1:0],
  input wire [31:0] vertex_pos_in [DIM-1:0];
  input wire [31:0] query_pos_in [DIM-1:0];
  output logic [15:0] distance_sq_out,
  output logic valid_data_out
  );


  logic [31:0] point_mul_tdata, query_mul_tdata;
  logic point_mul_tvalid, query_mul_tvalid;


  logic valid_subs_out [DIM-1:0];
  logic valid_mults_out [DIM-1:0];
  logic [31:0] intermediate_subs_out [DIM-1:0];
  logic [31:0] intermediate_mults_out [DIM-1:0];


  for (i=0; i < DIM; i=i+1) begin

    adder sub(
      .aclk(clk_in), 

      .s_axis_a_tvalid(data_valid_in[i]), 
      .s_axis_a_tdata(query_pos_in[i]), 

      .s_axis_b_tvalid(1), 
      .s_axis_b_tdata({1,query_pos_in[i][30:23],~query_pos_in[i][30:23]}), 

      .m_axis_result_tvalid(valid_subs_out[i]), 
      .m_axis_result_tready(1'b1), 
      .m_axis_result_tdata(intermediate_subs_out[i])
    );

      multiplier mult(
        .aclk(clk_in), 

        .s_axis_a_tvalid(valid_subs_out[i]),
        .s_axis_a_tdata(intermediate_subs_out[i]),

        .s_axis_b_tvalid(valid_subs_out[i]),
        .s_axis_b_tdata(intermediate_subs_out[i]), 

        .m_axis_result_tready(1'b1), 
        .m_axis_result_tvalid(valid_mults_out[i]), 
        .m_axis_result_tdata(intermediate_mults_out[i])
      );

  end

  for (i=0; i < $clog2(DIM); i=i+1) begin
    for (j=0; j < DIM; j=j+1-+) begin



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
