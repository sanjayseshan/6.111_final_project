`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module FIFO #(parameter DATA_WIDTH = 32, parameter DEPTH = 8)(
  input wire clk_in,
  input wire rst_in,
  input wire deq_in,
  input wire [DATA_WIDTH-1:0] enq_data_in,
  input wire enq_in,
  output logic full_out,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic empty_out,
  output logic valid_out
);
    logic [DATA_WIDTH-1:0] queue [DEPTH-1:0];
    logic valid [DEPTH-1:0];
    logic [$clog2(DEPTH):0] read_ptr;
    logic [$clog2(DEPTH):0] write_ptr;

    always_comb begin
        empty_out = (read_ptr == write_ptr && !valid[read_ptr]);
        full_out = (read_ptr==write_ptr && valid[read_ptr]);
    end

    always_ff @( posedge clk_in ) begin
        if (rst_in) begin
            for (int i=0; i<DEPTH; i=i+1) begin
                queue[i] <= 0;
                valid[i] <= 0;

            end
            data_out <= 0;
            // full_out <= 0;
            // empty_out <= 0;
            // valid_out <= 0;
            read_ptr <= 0;
            write_ptr <= 0;
            valid_out <= 0;
        end else begin
            // dequeue value
            if (deq_in && !empty_out && valid[read_ptr]) begin
                data_out <= queue[read_ptr];
                valid_out <= 1;
                valid[read_ptr] <= 0;
                read_ptr <= (read_ptr < DEPTH-1) ? read_ptr +1 : 0;
            end else valid_out <= 0;
            // enqeue value
            if (enq_in && !full_out && valid[write_ptr] == 0) begin
                queue[write_ptr] <= enq_data_in;
                valid[write_ptr] <= 1;
                write_ptr <= (write_ptr < DEPTH-1) ? write_ptr +1 : 0;
            end

        end
    end
        
endmodule


`default_nettype wire