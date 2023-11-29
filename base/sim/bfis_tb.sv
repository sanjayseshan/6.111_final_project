`timescale 1ns / 1ps
`default_nettype none

module bfis_tb();

  logic clk_in;
  logic rst_in;
  logic [31:0] vertex_in;
  logic [31:0] vertex_addr_in;
  logic vertex_valid_in;
  logic [31:0] query_in [1:0];
  logic [15:0] k_in;
  logic [31:0] top_k_out [4:0];
  logic valid_out;


  logic [31:0] query_pos_in0;
  logic [31:0] query_pos_in1;
//   logic [31:0] query_pos_in2;
//   logic [31:0] query_pos_in3;
//   logic [31:0] query_pos_in4;
//   logic [31:0] query_pos_in5;
//   logic [31:0] query_pos_in6;
//   logic [31:0] query_pos_in7;
//   logic [31:0] query_pos_in8;


  bfis #(.DIM(2), .PQ_LENGTH(8)) bfis_m (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .vertex_in(vertex_in),
    .vertex_addr_in(vertex_addr_in),
    .vertex_valid_in(vertex_valid_in),
    .query_in(query_in),
    .k_in(k_in),
    .top_k_out(top_k_out),
    .valid_out(valid_out)
  );


  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;


      query_pos_in0 = query_in[0];
      query_pos_in1 = query_in[1];
    //   query_in2 = query_in[2];
    //   query_in3 = query_in[3];


  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("bfis_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,bfis_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    for (int i=0;i<2;i=i+1) begin
        // data_valid_in[i] = 0;
        // vertex_pos_in[i] = 0;
        query_in[i] = 0;
    end

    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    query_in[0] = 5;//23;
    query_in[1] = 7;//67;
    vertex_addr_in = 15;
    vertex_in = 4;
    vertex_valid_in = 1;
    #10;
    vertex_valid_in = 0;
    #10;
    vertex_in = 20;
    vertex_valid_in = 1;
    #10;
    vertex_valid_in = 0;
    #40;


// result should be 959 or 0x3bf
    #500;
    $display("Simulation finished");
    $finish;
  end
endmodule
`default_nettype wire