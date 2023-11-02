`timescale 1ns / 1ps
`default_nettype none

module distance_tb();

  logic clk_in;
  logic rst_in;
  logic data_valid_in;
  logic [31:0] vertex_pos_in;
  logic [31:0] query_pos_in;
  logic [31:0] distance_sq_out;
  logic data_valid_out;

  distance #(.DIM(1)) distance_calculator(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .data_valid_in(data_valid_in),
    .vertex_pos_in(vertex_pos_in),
    .query_pos_in(query_pos_in),
    .distance_sq_out(distance_sq_out),
    .data_valid_out(data_valid_out)
  );

  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("distance_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,distance_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    data_valid_in = 0;
    vertex_pos_in = 0;
    query_pos_in = 0;
    $display("Simulation finished");
    $finish;
  end
endmodule
`default_nettype wire