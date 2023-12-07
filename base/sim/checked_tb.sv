`timescale 1ns / 1ps
`default_nettype none

module checked_tb();

  logic clk_in;
  logic rst_in;
  logic deq_smallest_in;
  logic deq_largest_in;
  logic [31:0] enq_data_in;
  logic [15:0] enq_tag_in;
  logic enq_in;
  logic full_out;
  logic [31:0] data_out;
  logic [15:0] tag_out;
  logic [2:0] size_out;
  logic empty_out;
  logic valid_out;
  logic [15:0] max_tag_out;

//   logic [31:0] intermediate_subs_out;

CheckedQueue #(.DATA_WIDTH(32), .TAG_WIDTH(16), .DEPTH(3))Q(
  .clk_in(clk_in),
  .rst_in(rst_in),
  .deq_smallest_in(deq_smallest_in),
  .deq_largest_in(deq_largest_in),
  .enq_data_in(enq_data_in),
  .enq_tag_in(enq_tag_in),
  .enq_in(enq_in),
  .full_out(full_out),
  .data_out(data_out),
  .tag_out(tag_out),
  .size_out(size_out),
  .empty_out(empty_out),
  .valid_out(valid_out),
  .max_tag_out(max_tag_out)
);


  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end

  //initial block...this is our test simulation
  initial begin
    $dumpfile("checked_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,checked_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    deq_largest_in = 0;
    deq_smallest_in = 0;
    enq_in=0;
    enq_data_in=0;
    enq_tag_in=0;


    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #10;
    enq_data_in=32'd0;
    enq_tag_in=15'd14;
    enq_in=1;
    #10;
    enq_in=0;
    #30;
    enq_data_in=32'd1;
    enq_tag_in=15'd35;
    enq_in=1;
    #10;
    enq_in=0;
    #30;
    enq_data_in=32'd2;
    enq_tag_in=15'd3;
    enq_in=1;
    #10;
    enq_in=0;
    #10;
    deq_largest_in=1; // return data 2, tag 3
    #10;
    deq_largest_in=0;

    #10;
    enq_data_in=32'd3;
    enq_tag_in=15'd75;
    enq_in=1;
    #10;
    enq_in=0;
    #10;
    enq_data_in=32'd4;
    enq_tag_in=15'd12;
    enq_in=1;
    #10;
    enq_in=0;
    #10;
    enq_data_in=32'd5;
    enq_tag_in=15'd27;
    enq_in=1;
    #10;
    enq_in=0;

    #10;
    deq_largest_in=1; 
    #10;
    deq_largest_in=0;
    #10;
    deq_largest_in=1; 
    #10;
    deq_largest_in=0;
    #10;
    deq_smallest_in=1;
    #10;
    deq_smallest_in=0;
    #10;
    deq_largest_in=1; 
    #10;
    deq_largest_in=0; 
    #10;
    deq_smallest_in=1; 
    #10;
    deq_smallest_in=0; 


    #10;
    enq_data_in=32'd6;
    enq_tag_in=15'd15;
    enq_in=1;
    #10;
    enq_in=0;
    #10;
    deq_largest_in=1; // return data 6, tag 15
    #10;
    deq_largest_in=0; 

    #10;
    enq_data_in=32'd7;
    enq_tag_in=15'd189;
    enq_in=1;
    #10;
    enq_in=0;
    #10;
    enq_data_in=32'd8;
    enq_tag_in=15'd720;
    enq_in=1;
    #10;
    enq_in=0;
    #10;
    deq_smallest_in=1; // return data 7, tag 189
    #10;
    deq_smallest_in=0; 
    #10;
    deq_largest_in=1; // return data 8, tag 720
    #10;
    deq_largest_in=0; 


    #200
    $display("Simulation finished");
    $finish;

  end

endmodule
`default_nettype wire