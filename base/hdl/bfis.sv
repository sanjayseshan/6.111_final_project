`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module bfis #(parameter DIM = 2)(
  input wire clk_in,
  input wire rst_in,
  input wire [31:0] starting_point_in [DIM-1:0],
  input wire [31:0] query_in [DIM-1:0],
  input wire [15:0] pq_length_in,
  input wire [15:0] k_in,
  output logic [31:0] top_k_out [4:0],
  output logic valid_out
  );

  logic [4:0] state;

  always_ff @ (posedge clk_in) begin
    if (rst_in) begin
        top_k_out <= 0;
        valid_out <= 0;
    end

    // state 1
    else if (state==5'b0) begin
    end

    // state 2
    else if (state==5'b1) begin
    end

    else if (state==5'b10) begin
    end

    else if (state==5'b11) begin
    end

    else if (state==5'b100) begin
    end

    else if (state==5'b101) begin
    end

    else if (state==5'b110) begin
    end
  end

  

endmodule

`default_nettype wire