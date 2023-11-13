`timescale 1ns / 1ps
`default_nettype none

module fifo_tb();

  logic clk_in;
  logic rst_in;

  logic deq;
  logic [32-1:0] enq_data;
  logic enq;
  logic full;
  logic [31:0] data_out;
  logic empty;
  logic valid_out;

//   logic [31:0] intermediate_subs_out;

FIFO #(.DATA_WIDTH(32), .DEPTH(8))Q(
  .clk_in(clk_in),
  .rst_in(rst_in),
  .deq(deq),
  .enq_data(enq_data),
  .enq(enq),
  .full(full),
  .data_out(data_out),
  .empty(empty),
  .valid_out(valid_out)
);


  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  

  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("fifo_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,fifo_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;

    #10;
    rst_in = 1;
    #10;
    rst_in = 0;


    #20;
    enq = 1;
    enq_data = 64;
    #10;
    enq = 0;
    #20;
    enq = 1;
    enq_data = 16;
    #10;
    enq = 0;
    #10;
    deq = 1;
    #10;
    deq = 0;
    #10;
    deq = 1;
    #10;
    deq = 0;

// result should be 959 or 0x3bf
    #500;
    $display("Simulation finished");
    $finish;
  end
endmodule
`default_nettype wire