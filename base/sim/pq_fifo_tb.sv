`timescale 1ns / 1ps
`default_nettype none

module pq_fifo_tb();

  logic clk_in;
  logic rst_in;

  logic deq_in;
  logic [32-1:0] enq_data_in;
  logic enq_in;
  logic full_out;
  logic [31:0] data_out;
  logic empty_out;
  logic valid_out;

//   logic [31:0] intermediate_subs_out;

PQ_FIFO #(.DATA_WIDTH(32), .DEPTH(8))Q(
  .clk_in(clk_in),
  .rst_in(rst_in),
  .deq_in(deq_in),
  .enq_data_in(enq_data_in),
  .enq_in(enq_in),
  .full_out(full_out),
  .data_out(data_out),
  .empty_out(empty_out),
  .valid_out(valid_out)
);


  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end

  //initial block...this is our test simulation
  initial begin
    $dumpfile("pq_fifo_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,pq_fifo_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    deq_in = 0;
    enq_in=0;
    enq_data_in=0;


    #10;
    rst_in = 1;
    #10;
    rst_in = 0;

  for (int i=0;i<5;i=i+1) begin

      #20;
      enq_in = 1;
      enq_data_in = 64;
      #10;
      enq_in = 0;
      #20;
      enq_in = 1;
      enq_data_in = 16;
      #10;
      enq_in = 0;
      #10;
      deq_in = 1;
      #10;
      deq_in = 0;
      #10;
      deq_in = 1;
      #10;
      deq_in = 0;
      #10;
      deq_in = 1;
      #10;
      deq_in = 0;
      #10;
      deq_in = 1;
      #10;
      deq_in = 0;
      #10;
      deq_in = 1;
      #10;
      deq_in = 0;
      #10;
      deq_in = 1;
      #10;
      deq_in = 0;
      #10;
      deq_in = 1;
      #10;
      deq_in = 0;
    end


  for (int i=0;i<10;i=i+1) begin
    if (!full_out) begin
      #20;
      enq_in = 1;
      enq_data_in = i;
      #10;
      enq_in = 0;
    end      
  end


  for (int i=0;i<10;i=i+1) begin
    if (!empty_out) begin
      #10;
      deq_in = 1;
      #10;
      deq_in = 0;
    end
  end

    #200;
    $display("Simulation finished");
    $finish;
  end
endmodule
`default_nettype wire