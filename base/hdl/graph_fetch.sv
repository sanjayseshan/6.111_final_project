`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module graph_fetch #(parameter DIM = 2)(
  input wire clk_in,
  input wire rst_in,
  input wire [31:0] v_id,
  output logic [31:0] rowidx_out,
  output logic [31:0] data_out,
  output logic data_valid_out,
  output logic rowidx_valid_out
  );


    FIFO#(.DATA_WIDTH(32+5),.DEPTH(8))(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .deq,
        .enq_data,
        .enq,
        .full,
        .data_out,
        .empty
    );


endmodule

`default_nettype wire