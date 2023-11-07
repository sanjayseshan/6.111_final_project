`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module message_router #(parameter PROC_BITS = 4, parameter DATA_SIZE = 32, parameter PROC_ID=4'b0000)(
  input wire clk_in,
  input wire rst_in,
  input wire [$clog2(DATA_SIZE):0] addr_req,
  input wire [DATA_SIZE-1+PROC_BITS:0] data_route_in,
  input wire valid_in,
  output logic req_ready_out,
  output logic valid_out,
  output logic [DATA_SIZE-1:0] data_route_out
  );
  


endmodule

`default_nettype wire