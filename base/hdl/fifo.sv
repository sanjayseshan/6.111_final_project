`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module FIFO #(parameter DATA_WIDTH = 32, parameter DEPTH = 8)(
  input wire clk_in,
  input wire rst_in,
  input wire deq,
  input wire [DATA_WIDTH-1:0] enq_data,
  input wire enq,
  output logic full,
  output logic [31:0] data_out,
  output logic empty
);
    logic [DATA_WIDTH-1:0] Q [DEPTH-1:0];
    logic valid [DEPTH-1:0];
    logic [$clog2(DEPTH):0] read_ptr;
    logic [$clog2(DEPTH):0] write_ptr;

    always_comb begin
        empty = (read_ptr == write_ptr && !valid[read_ptr]);
        full = (read_ptr==write_ptr && valid[read_ptr]);
    end

    always_ff @( posedge clk_in ) begin
        if (rst_in) begin
            for (i=0; i<DEPTH; i=i+1) begin
                Q[i] <= 0;
                valid[i] <= 0;
            end
            read_ptr <= 0;
            write_ptr <= 0;
        end else begin
            if (deq && !empty && valid[read_ptr]) begin
                data_out <= Q[read_ptr];
                valid[read_ptr] <= 0;
                read_ptr <= (read_ptr < DEPTH) ? read_ptr +1 : 0;
            end
            if (enq && !full && valid[write_ptr] == 0) begin
                Q[write_ptr] <= enq_data;
                valid[write_ptr] <= 1;
                write_ptr <= (write_ptr < DEPTH) ? write_ptr +1 : 0;
            end

        end
    end
        
endmodule


`default_nettype wire