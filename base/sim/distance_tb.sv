`timescale 1ns / 1ps
`default_nettype none

module distance_tb();

  logic clk_in;
  logic rst_in;
  logic data_valid_in [1:0];
  logic [31:0] vertex_pos_in [1:0];
  logic [31:0] query_pos_in [1:0];
  logic [31:0] distance_sq_out;
  logic data_valid_out;

  logic [31:0] vertex_pos_in0;
  logic [31:0] vertex_pos_in1;
  logic [31:0] query_pos_in0;
  logic [31:0] query_pos_in1;
  logic data_valid_in0;
  logic data_valid_in1;

//   logic [31:0] intermediate_subs_out;

  distance #(.DIM(2)) distance_calculator(
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
      query_pos_in0 = query_pos_in[0];
      query_pos_in1 = query_pos_in[1];
      data_valid_in0 = data_valid_in[0];
      data_valid_in1 = data_valid_in[1];


  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("distance_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,distance_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    for (int i=0;i<2;i=i+1) begin
        data_valid_in[i] = 0;
        vertex_pos_in[i] = 0;
        query_pos_in[i] = 0;
    end

    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    query_pos_in[0] = 32'd18;
    query_pos_in[1] = 32'd23090;
    #20;
    data_valid_in[0] = 1;
    vertex_pos_in[0] = 32'd2938;
    #10;
    data_valid_in[0] = 0;
    data_valid_in[1] = 1;
    vertex_pos_in[1] = 32'd223;
    #10;
    data_valid_in[1] = 0;

    // for (int i = 0; i<10000; i=i+1)begin
    //   audio_in = i;
    //   audio_valid_in = 1;
    //   #10;
    // end
    // #1;
    // data_valid_in[1] = 0;
    // data_valid_in[0] = 0;

    #500;
    $display("Simulation finished");
    $finish;
  end
endmodule
`default_nettype wire