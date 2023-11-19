`timescale 1ns / 1ps
`default_nettype none

module graph_fetch_tb();

  logic clk_in;
  logic rst_in;
  logic [31:0] v_addr_in;
  logic valid_in;
  logic ready_out;
  logic [31:0] neigh_fifo_out;
  logic [31:0] data_out [1:0];
  logic data_valid_out [1:0];
  logic neigh_deq_out;
  logic neigh_valid_out;

  logic neigh_full_out;
  logic neigh_empty_out;

  logic mem_valid_in;
  logic [31+4:0] mem_data_in;
  logic mem_valid_out;
  logic [31+4:0] mem_req_out;

  logic mem_valid_in2;
  logic [31+4:0] mem_data_in2;
  logic mem_valid_out2;
  logic [31+4:0] mem_req_out2;

  logic fully_fetched_out;


  logic [31:0] data_out0, data_out1;
  logic data_valid_out0, data_valid_out1;


graph_fetch #(.DIM(2)) graph(
  .clk_in(clk_in),
  .rst_in(rst_in),
  .v_addr_in(v_addr_in),
  .valid_in(valid_in),
  .ready_out(ready_out),
  .neigh_fifo_out(neigh_fifo_out),
  .data_out(data_out),
  .data_valid_out(data_valid_out),
  .neigh_deq_out(neigh_deq_out),
  .neigh_valid_out(neigh_valid_out),

  .neigh_full_out(neigh_full_out),
  .neigh_empty_out(neigh_empty_out),

  .mem_valid_in(mem_valid_in),
  .mem_data_in(mem_data_in),
  .mem_valid_out(mem_valid_out),
  .mem_req_out(mem_req_out),

  .mem_valid_in2(mem_valid_in2),
  .mem_data_in2(mem_data_in2),
  .mem_valid_out2(mem_valid_out2),
  .mem_req_out2(mem_req_out2),

  .fully_fetched_out(fully_fetched_out)
);


  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
      
      data_valid_out0 = data_valid_out[0];
      data_valid_out1 = data_valid_out[1];

      data_out0 = data_out[0];
      data_out1 = data_out[1];
      
  end

  //initial block...this is our test simulation
  initial begin
    $dumpfile("graph_fetch_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,graph_fetch_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    v_addr_in = 0;
    valid_in = 0;
    mem_valid_in = 0;
    mem_data_in = 0;
    mem_valid_in2 = 0;
    mem_data_in2 = 0;


    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #10;
    v_addr_in = 1;
    valid_in = 1;
    mem_valid_in = 1;
    mem_data_in = 6;
    #10;
    valid_in = 0;


    #200
    $display("Simulation finished");
    $finish;

  end

endmodule
`default_nettype wire