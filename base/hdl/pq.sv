`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module PriorityQueue #(parameter DATA_WIDTH = 32, parameter TAG_WIDTH = 32, parameter DEPTH = 8)(
  input wire clk_in,
  input wire rst_in,
  input wire deq,
  input wire [DATA_WIDTH-1:0] enq_data,
  input wire [TAG_WIDTH-1:0] enq_tag,
  input wire enq,
  output logic full,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic [TAG_WIDTH-1:0] tag_out,
  output logic empty,
  output logic valid_out
);
    
    logic [TAG_WIDTH-1:0] Q [DEPTH-1:0];
    logic [DATA_WIDTH-1:0] Q_data [DEPTH-1:0];
    logic valid [DEPTH-1:0];
    logic [$clog2(DEPTH):0] nelts;

    logic [$clog2(DEPTH):0] read_ptr;
    logic [$clog2(DEPTH):0] write_ptr;
    logic [DATA_WIDTH-1:0] curval;

    logic rem_lru;
    logic push_lru;




    always_comb begin
        empty = (nelts == 0);
        full = (nelts == DEPTH);

        for (int i = 0; i<DEPTH; i=i+1) begin
            if (valid[i] && Q[i] <= curval) begin
                read_ptr = i;
                curval = Q[i];
            end
        end
    end


    PQ_FIFO #(.DATA_WIDTH($clog2(DEPTH)+1), .DEPTH(DEPTH)) lru_cache (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .deq(rem_lru),
        .enq_data(read_ptr),
        .enq(push_lru),
        .full(),
        .data_out(write_ptr),
        .empty(),
        .valid_out()
    );

    always_ff @( posedge clk_in ) begin
        if (rst_in) begin
            for (int i=0; i<DEPTH; i=i+1) begin
                Q[i] <= 0;
                valid[i] <= 0;
                curval <= 32'hFFFFFFFF;
                read_ptr <= 0;
                // write_ptr <= 0;
            end
            data_out <= 0;
            full <= 0;
            empty <= 0;
            // valid_out <= 0;
            valid_out <= 0;
            nelts <= 0;
        end else begin
            if (deq && !empty && valid[read_ptr]) begin
                data_out <= Q_data[read_ptr];
                tag_out <= Q[read_ptr];
                push_lru <= 1;
                valid_out <= 1;
                valid[read_ptr] <= 0;
                read_ptr <= (read_ptr < DEPTH-1) ? read_ptr +1 : 0;
                nelts <= nelts -1;
            end else begin
                valid_out <= 0;
                push_lru <= 0;
            end
            if (enq && !full && valid[write_ptr] == 0) begin
                nelts <= nelts +1;
                Q_data[write_ptr] <= enq_data;
                Q[write_ptr] <= enq_tag;
                rem_lru <= 1;
                valid[write_ptr] <= 1;
            end else rem_lru <= 0;

        end
    end
        
endmodule



module PQ_FIFO #(parameter DATA_WIDTH = 32, parameter DEPTH = 8)(
  input wire clk_in,
  input wire rst_in,
  input wire deq,
  input wire [DATA_WIDTH-1:0] enq_data,
  input wire enq,
  output logic full,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic empty,
  output logic valid_out
);
    logic [DATA_WIDTH-1:0] Q [DEPTH-1:0];
    logic valid [DEPTH-1:0];
    logic [$clog2(DEPTH):0] read_ptr;
    logic [$clog2(DEPTH):0] write_ptr;

    always_comb begin
        empty = (read_ptr == write_ptr && !valid[read_ptr]);
        full = (read_ptr==write_ptr && valid[read_ptr]);

        // always read latest even without deq -- diff from FIFO
        data_out = Q[read_ptr];
        valid_out = valid[read_ptr];
    end

    always_ff @( posedge clk_in ) begin
        if (rst_in) begin
            for (int i=0; i<DEPTH; i=i+1) begin
                // init with x=i -- diff from FIFO
                Q[i] <= i;
                valid[i] <= 1;

            end
            data_out <= 0;
            full <= 0;
            empty <= 0;
            // valid_out <= 0;
            read_ptr <= 0;
            write_ptr <= 0;
            valid_out <= 0;
        end else begin
            if (deq && !empty && valid[read_ptr]) begin
                // data_out <= Q[read_ptr];
                // valid_out <= 1;
                valid[read_ptr] <= 0;
                read_ptr <= (read_ptr < DEPTH-1) ? read_ptr +1 : 0;
            end else valid_out <= 0;
            if (enq && !full && valid[write_ptr] == 0) begin
                Q[write_ptr] <= enq_data;
                valid[write_ptr] <= 1;
                write_ptr <= (write_ptr < DEPTH-1) ? write_ptr +1 : 0;
            end

        end
    end
        
endmodule


`default_nettype wire