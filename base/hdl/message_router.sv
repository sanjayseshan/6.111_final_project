`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module message_router #(parameter PROC_BITS = 4, parameter DATA_SIZE = 32, parameter PROC_ID=4'b0000)(
  input wire clk_in,
  input wire rst_in,
  input wire [DATA_SIZE-1:0] addr_req,
  input wire [DATA_SIZE-1+PROC_BITS:0] data_route_in,
  input wire valid_in,
  input wire req_ready_in,
  output logic valid_req_out,
  output logic valid_out_route,
  output logic [DATA_SIZE-1+PROC_BITS:0] msg_out,
  output logic [DATA_SIZE-1:0] data_route_out
  );

  always_comb begin
    if (req_ready_in) begin 
      msg_out = {addr_req,PROC_BITS};
    end
    valid_req_out = req_ready_in;

    if (valid_in ) begin // && data_route_in[PROC_BITS-1:0]==PROC_ID
      data_route_out = data_route_in[DATA_SIZE+PROC_BITS-1:PROC_BITS-1];
      valid_out_route = 1;
    end else valid_out_route = 0;
  end
  


endmodule

`default_nettype wire