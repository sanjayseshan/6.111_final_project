`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module bfis #(parameter DIM = 2)(
  input wire clk_in,
  input wire rst_in,
  input wire [31:0] vertex_in [DIM-1:0],
  input wire vertex_valid_in,
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
      if (vertex_valid_in) begin
        // compute distance between the two
        
        // add vertex to priority queue
      end
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


  distance #(.DIM(2)) distance_calc (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .data_valid_in(),
    .vertex_pos_in(),
    .query_pos_in(),
    .distance_sq_out(),
    .data_valid_out()
  );

  PriorityQueue #(.DATA_WIDTH(32), .TAG_WIDTH(32), .DEPTH(8)) s (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .deq_in(),
    .enq_data_in(),
    .enq_tag_in(),
    .enq_in(),
    .full_out(),
    .data_out(),
    .tag_out(),
    .size_out(),
    .empty_out(),
    .valid_out()
  );


endmodule

`default_nettype wire