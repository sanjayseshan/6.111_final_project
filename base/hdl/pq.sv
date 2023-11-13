`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module PQ #(parameter DATA_WIDTH = 32, parameter DEPTH = 8)(
  input wire clk_in,
  input wire rst_in,
  input wire deq,
  input wire [DATA_WIDTH-1:0] enq_data,
  input wire enq,
  output logic full,
  output logic [31:0] data_out,
  output logic empty,
  output logic valid_out
);
    
        
endmodule


`default_nettype wire