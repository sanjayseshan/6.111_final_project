`timescale 1ns / 1ps
`default_nettype none

module visited_tb();

  logic clk_in;
  logic rst_in;
  logic [31:0] v_addr_in;
  logic v_addr_valid_in;
  logic visited_out;


visited #(.PROC_BITS(0)) vbram (
  .clk_in(clk_in),
  .rst_in(rst_in),
  .v_addr_in(v_addr_in),
  .v_addr_valid_in(v_addr_valid_in),
  .visited_out(visited_out)
);


  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end

  //initial block...this is our test simulation
  initial begin
    $dumpfile("visited_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,visited_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    v_addr_in = 0;
    v_addr_valid_in = 0;


    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #10;
    v_addr_in=32'd1;
    v_addr_valid_in=1'b1;
    #10;
    v_addr_valid_in=1'b0;
    #30;
    v_addr_in=32'd9;
    v_addr_valid_in=1'b1;
    #10;
    v_addr_valid_in=1'b0;
    #30;
    v_addr_in=32'd11;
    v_addr_valid_in=1'b1;
    #10;
    v_addr_valid_in=1'b0;
    #30;
    v_addr_in=32'd1;
    v_addr_valid_in=1'b1;
    #10;
    v_addr_valid_in=1'b0;


    #200
    $display("Simulation finished");
    $finish;

  end

endmodule
`default_nettype wire