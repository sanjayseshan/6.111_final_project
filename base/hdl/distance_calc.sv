`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module distance #(parameter DIM = 2)(
  input wire clk_in,
  input wire rst_in,
  input wire data_valid_in [DIM-1:0],
  input wire [31:0] vertex_pos_in [DIM-1:0],
  input wire [31:0] query_pos_in [DIM-1:0],
  output logic [31:0] distance_sq_out,
  output logic data_valid_out
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

      recursive_add_n_dim  #(
        .DIM(DIM)
        ) add_distances(
          .clk_in(clk_in),
          .rst_in(rst_in),
          .data_valid_in(valid_mults_out[DIM-1]),
          .intermediate_muls_in(intermediate_muls_in),
          .distance_sq_out(distance_sq_out),
          .data_valid_out(data_valid_out)
      );

  end

  // for (i=0; i < $clog2(DIM); i=i+1) begin
  //   for (j=0; j < DIM; j=j+1-+) begin


//   adder add(
//     .aclk(clk_in), 

//     .s_axis_a_tvalid(point_mul_tvalid), 
//     .s_axis_a_tdata(point_mul_tdata), 

//     .s_axis_b_tvalid(query_mul_tvalid), 
//     .s_axis_b_tdata(query_mul_tdata), 

//     .m_axis_result_tvalid(data_valid_out), 
//     .m_axis_result_tready(1'b1), 
//     .m_axis_result_tdata(distance_out)
//     );

// endmodule // top_level


module recursive_add_n_dim # (parameter DIM = 1)(
  input wire clk_in,
  input wire rst_in,
  input wire data_valid_in,
  input wire [31:0] intermediate_muls_in [DIM-1:0],
  output [31:0] distance_sq_out,
  output data_valid_out
);

  generate 
    if (DIM==1) begin
      always_ff @ (posedge clk_in) begin
        if (rst) distance_sq_out <= 0;
        else distance_sq_out <= intermediate_muls_in[0];
      end
    end
    else if (DIM==2) begin
      adder add(
        .aclk(clk_in), 

        .s_axis_a_tvalid(data_valid_in), 
        .s_axis_a_tdata(intermediate_muls_in[0]), 

        .s_axis_b_tvalid(data_valid_in), 
        .s_axis_b_tdata(intermediate_muls_in[1]), 

        .m_axis_result_tvalid(data_valid_out), 
        .m_axis_result_tready(1'b1), 
        .m_axis_result_tdata(distance_out)
        );
    end
    else begin
      logic [31:0] distance1, distance2;
      logic add_valid1, add_valid2;
      add_n_dimensions # (
        .DIM(DIM >> 1)
      ) adder1 (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .data_valid_in(data_valid_in),
        .intermediate_muls_in(intermediate_muls_in[0:(DIM>>2)]),
        .distance_sq_out(distance1),
        .data_valid_out(add_valid1)
      );

      add_n_dimensions # (
        .DIM(DIM >> 1)
      ) adder2 (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .data_valid_in(data_valid_in),
        .intermediate_muls_in(intermediate_muls_in[(DIM>>2)+1:DIM-1]),
        .distance_sq_out(distance2),
        .data_valid_out(add_valid2),
      );

      adder add(
        .aclk(clk_in), 

        .s_axis_a_tvalid(add_valid1), 
        .s_axis_a_tdata(distance1), 

        .s_axis_b_tvalid(add_valid2), 
        .s_axis_b_tdata(distance2), 

        .m_axis_result_tvalid(data_valid_out), 
        .m_axis_result_tready(1'b1), 
        .m_axis_result_tdata(distance_sq_out)
        );

      end
  endgenerate
endmodule

`default_nettype wire
