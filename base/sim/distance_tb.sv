`timescale 1ns / 1ps
`default_nettype none

module distance_tb();

  logic clk_in;
  logic rst_in;
  logic data_valid_in [8:0];
  logic [31:0] vertex_pos_in [8:0];
  logic [31:0] query_pos_in [8:0];
  logic [31:0] distance_sq_out;
  logic data_valid_out;

  logic [31:0] vertex_pos_in0;
  logic [31:0] vertex_pos_in1;
  logic [31:0] vertex_pos_in2;
  logic [31:0] vertex_pos_in3;
  logic [31:0] vertex_pos_in4;
  logic [31:0] vertex_pos_in5;
  logic [31:0] vertex_pos_in6;
  logic [31:0] vertex_pos_in7;
  logic [31:0] vertex_pos_in8;

  logic [31:0] query_pos_in0;
  logic [31:0] query_pos_in1;
  logic [31:0] query_pos_in2;
  logic [31:0] query_pos_in3;
  logic [31:0] query_pos_in4;
  logic [31:0] query_pos_in5;
  logic [31:0] query_pos_in6;
  logic [31:0] query_pos_in7;
  logic [31:0] query_pos_in8;

  logic data_valid_in0;
  logic data_valid_in1;
  logic data_valid_in2;
  logic data_valid_in3;
  logic data_valid_in4;
  logic data_valid_in5;
  logic data_valid_in6;
  logic data_valid_in7;
  logic data_valid_in8;

//   logic [31:0] intermediate_subs_out;

  distance #(.DIM(9)) distance_calculator(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .data_valid_in(data_valid_in),
    .vertex_pos_in(vertex_pos_in),
    .query_pos_in(query_pos_in),
    .distance_sq_out(distance_sq_out),
    .data_valid_out(data_valid_out)
    // .intermediate_subs_out(intermediate_subs_out)
  );

  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
      vertex_pos_in0 = vertex_pos_in[0];
      vertex_pos_in1 = vertex_pos_in[1];
      vertex_pos_in2 = vertex_pos_in[2];
      vertex_pos_in3 = vertex_pos_in[3];
      vertex_pos_in4 = vertex_pos_in[4];
      vertex_pos_in5 = vertex_pos_in[5];
      vertex_pos_in6 = vertex_pos_in[6];
      vertex_pos_in7 = vertex_pos_in[7];
      vertex_pos_in8 = vertex_pos_in[8];

      query_pos_in0 = query_pos_in[0];
      query_pos_in1 = query_pos_in[1];
      query_pos_in2 = query_pos_in[2];
      query_pos_in3 = query_pos_in[3];
      query_pos_in4 = query_pos_in[4];
      query_pos_in5 = query_pos_in[5];
      query_pos_in6 = query_pos_in[6];
      query_pos_in7 = query_pos_in[7];
      query_pos_in8 = query_pos_in[8];

      data_valid_in0 = data_valid_in[0];
      data_valid_in1 = data_valid_in[1];
      data_valid_in2 = data_valid_in[2];
      data_valid_in3 = data_valid_in[3];
      data_valid_in4 = data_valid_in[4];
      data_valid_in5 = data_valid_in[5];
      data_valid_in6 = data_valid_in[6];
      data_valid_in7 = data_valid_in[7];
      data_valid_in8 = data_valid_in[8];

  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("distance_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,distance_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    for (int i=0;i<9;i=i+1) begin
        data_valid_in[i] = 0;
        vertex_pos_in[i] = 0;
        query_pos_in[i] = 0;
    end

    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    query_pos_in[0] = 23; //5;
    query_pos_in[1] = 67; //7;
    query_pos_in[2] = 2; //10;
    query_pos_in[3] = 99; //50;
    query_pos_in[4] = 17;
    query_pos_in[5] = 103;
    query_pos_in[6] = 1;
    query_pos_in[7] = 53;
    query_pos_in[8] = 18;

    #20;
    data_valid_in[0] = 1;
    vertex_pos_in[0] = 89; //8;
    #10;
    data_valid_in[0] = 0;
    data_valid_in[1] = 1;
    vertex_pos_in[1] = 123; //2;
    #10;
    data_valid_in[1] = 0;
    data_valid_in[2] = 1;
    vertex_pos_in[2] = 231; //15;
    #10;
    data_valid_in[2] = 0;
    data_valid_in[3] = 1;
    vertex_pos_in[3] = 82; //80;
    #10;
    data_valid_in[3] = 0;
    data_valid_in[4] = 1;
    vertex_pos_in[4] = 7;
    #10;
    data_valid_in[4] = 0;
    data_valid_in[5] = 1;
    vertex_pos_in[5] = 12;
    #10;
    data_valid_in[5] = 0;
    data_valid_in[6] = 1;
    vertex_pos_in[6] = 20;
    #10;
    data_valid_in[6] = 0;
    data_valid_in[7] = 1;
    vertex_pos_in[7] = 39;
    #10;
    data_valid_in[7] = 0;
    data_valid_in[8] = 1;
    vertex_pos_in[8] = 19;
    #10;
    data_valid_in[8] = 0;

// result should be 959 or 0x3bf
    #500;
    $display("Simulation finished");
    $finish;
  end
endmodule
`default_nettype wire