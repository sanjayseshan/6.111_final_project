`timescale 1ns / 1ps
`default_nettype none

module graph_fetch_tb();

  logic clk_in;
  logic rst_in;
  logic [31:0] v_addr_in;
  logic valid_in;
  logic ready_out;
  logic [31:0] neigh_fifo_out;
  logic [31:0] data_out;
  logic data_valid_out;

  logic pos_deq_in;
  logic pos_valid_out;
  logic pos_full_out;
  logic pos_empty_out;

  logic neigh_deq_in;
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

  logic [31:0] data_out0, data_out1, data_out2, data_out3;
  logic data_valid_out0, data_valid_out1, data_valid_out2, data_valid_out3;



  // fetch position and neighbor values from BRAM
  // retrieve neighbor if ready and fifo isn't full
  graph_memory# (.DIM(4), .PROC_BITS(0)) g (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .data_addra(mem_req_out),
    .data_addrb(mem_req_out2),
    .data_validina(mem_valid_out),
    .data_validinb(mem_valid_out2),
    .data_outa(mem_data_in),
    .data_outb(mem_data_in2),
    .data_valid_outa(mem_valid_in),
    .data_valid_outb(mem_valid_in2),


  );


graph_fetch #(.DIM(4)) graph(
  .clk_in(clk_in),
  .rst_in(rst_in),
  .v_addr_in(v_addr_in),
  .valid_in(valid_in),
  .ready_out(ready_out),

  .pos_deq_in(pos_deq_in),
  .data_out(data_out),
  .data_valid_out(data_valid_out),
  .pos_full_out(pos_full_out),
  .pos_empty_out(pos_empty_out),

  .neigh_deq_in(neigh_deq_in),
  .neigh_fifo_out(neigh_fifo_out),
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
  .mem_req_out2(mem_req_out2)
);


  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
      
    //   data_valid_out0 = data_valid_out[0];
    //   data_valid_out1 = data_valid_out[1];
    //   data_valid_out2 = data_valid_out[2];
    //   data_valid_out3 = data_valid_out[3];

    //   data_out0 = data_out[0];
    //   data_out1 = data_out[1];
    //   data_out2 = data_out[2];
    //   data_out3 = data_out[3];
      
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
    // mem_valid_in = 0;
    // mem_data_in = 0;
    // mem_valid_in2 = 0;
    // mem_data_in2 = 0;
    neigh_deq_in = 0;
    pos_deq_in = 0;

    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #10;
    v_addr_in = 1;
    valid_in = 1;
    #10;
    valid_in = 0;
    #100;
    pos_deq_in = 1;
    #10;
    pos_deq_in = 0;
    #10;
    pos_deq_in = 1;
    #10
    pos_deq_in = 0;
    #10;
    pos_deq_in = 1;
    #10
    pos_deq_in = 0;
    #10;
    pos_deq_in = 1;
    #10
    pos_deq_in = 0;
    #30;
    neigh_deq_in = 1;
    #10;
    neigh_deq_in = 0;
    #10;
    neigh_deq_in = 1;
    #10;
    neigh_deq_in = 0;
    #10;
    neigh_deq_in = 1;
    #10;
    neigh_deq_in = 0;

    #10;
    v_addr_in = 55;
    valid_in = 1;
    #10;
    valid_in = 0;
    #100;
    pos_deq_in = 1;
    #10;
    pos_deq_in = 0;
    #10;
    pos_deq_in = 1;
    #10
    pos_deq_in = 0;
    #10;
    pos_deq_in = 1;
    #10
    pos_deq_in = 0;
    #10;
    pos_deq_in = 1;
    #10
    pos_deq_in = 0;
    #30;
    neigh_deq_in = 1;
    #10;
    neigh_deq_in = 0;
    #10;
    neigh_deq_in = 1;
    #10;
    neigh_deq_in = 0;
    #10;
    neigh_deq_in = 1;
    #10;
    neigh_deq_in = 0;


    #10;
    v_addr_in = 64;
    valid_in = 1;
    #10;
    valid_in = 0;
    #100;
    pos_deq_in = 1;
    #10;
    pos_deq_in = 0;
    #10;
    pos_deq_in = 1;
    #10
    pos_deq_in = 0;
    #10;
    pos_deq_in = 1;
    #10
    pos_deq_in = 0;
    #10;
    pos_deq_in = 1;
    #10
    pos_deq_in = 0;
    #30;
    neigh_deq_in = 1;
    #10;
    neigh_deq_in = 0;
    #10;
    neigh_deq_in = 1;
    #10;
    neigh_deq_in = 0;
    #10;
    neigh_deq_in = 1;
    #10;
    neigh_deq_in = 0;



    #200
    $display("Simulation finished");
    $finish;

  end

endmodule
`default_nettype wire