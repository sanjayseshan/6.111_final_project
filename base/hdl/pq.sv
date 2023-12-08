`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module PriorityQueue #(parameter DATA_WIDTH = 32, parameter TAG_WIDTH = 32, parameter DEPTH = 8)(
  input wire clk_in,
  input wire rst_in,
  input wire deq_in,
  input wire [DATA_WIDTH-1:0] enq_data_in,
  input wire [TAG_WIDTH-1:0] enq_tag_in,
  input wire enq_in,
  output logic full_out,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic [TAG_WIDTH-1:0] tag_out,
  output logic [$clog2(DEPTH):0] size_out,
  output logic empty_out,
  output logic valid_out
);
    
    logic [TAG_WIDTH-1:0] queue [DEPTH-1:0]; // distances
    logic [DATA_WIDTH-1:0] Q_data [DEPTH-1:0]; // point
    logic valid [DEPTH-1:0]; 
    // logic [$clog2(DEPTH):0] nelts;

    logic [$clog2(DEPTH):0] read_ptr, prev_read_ptr;
    logic [$clog2(DEPTH):0] write_ptr;
    logic [DATA_WIDTH-1:0] curval;

    logic rem_lru;
    logic push_lru;


    // finds smallest value in queue
    always_comb begin
        empty_out = (size_out == 0);
        full_out = (size_out == DEPTH);

        curval = 32'hFFFFFFFF;
        
        read_ptr = 0;

        for (int i = 0; i<DEPTH; i=i+1) begin
            if (valid[i] && queue[i] <= curval) begin
                read_ptr = i;
                curval = queue[i];
            end
        end
    end

    // find lru index to write next element
    PQ_FIFO #(.DATA_WIDTH($clog2(DEPTH)+1), .DEPTH(DEPTH)) lru_cache (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .deq_in(rem_lru),
        .enq_data_in(prev_read_ptr),
        .enq_in(push_lru),
        .full_out(),
        .data_out(write_ptr),
        .empty_out(),
        .valid_out()
    );

    always_ff @( posedge clk_in ) begin
        if (rst_in) begin
            for (int i=0; i<DEPTH; i=i+1) begin
                queue[i] <= 0;
                Q_data[i] <= 0;
                valid[i] <= 0;
                // curval <= 32'hFFFFFFFF;
                // write_ptr <= 0;
            end
            prev_read_ptr <= 0;
            data_out <= 0;
            // full_out <= 0;
            // empty_out <= 0;
            // valid_out <= 0;
            valid_out <= 1'b0;
            size_out <= 0;
        end 
        else begin
            // dequeue smallest element
            if (deq_in && !empty_out && valid[read_ptr]) begin
                data_out <= Q_data[read_ptr];
                tag_out <= queue[read_ptr];
                push_lru <= 1'b1;
                valid_out <= 1'b1;
                valid[read_ptr] <= 1'b0;
                // read_ptr <= (read_ptr < DEPTH-1) ? read_ptr +1 : 0;
                prev_read_ptr <= read_ptr;
                size_out <= (size_out>0) ? size_out -1 : 0;
            end else begin
                valid_out <=1'b0;
                push_lru <= 1'b0;
            end
            // enqueue element
            if (enq_in && !full_out && valid[write_ptr] == 0) begin
                size_out <= size_out +1;
                Q_data[write_ptr] <= enq_data_in;
                queue[write_ptr] <= enq_tag_in;
                rem_lru <= 1;
                valid[write_ptr] <= 1'b1;
            end else rem_lru <= 0;
        end
    end
        
endmodule


// fifo for finding earliest dequeued index
module PQ_FIFO #(parameter DATA_WIDTH = 32, parameter DEPTH = 8)(
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

        // always read latest even without deq -- diff from FIFO
        data_out = queue[read_ptr];
        valid_out = valid[read_ptr];
    end

    always_ff @( posedge clk_in ) begin
        if (rst_in) begin
            for (int i=0; i<DEPTH; i=i+1) begin
                // init with x=i -- diff from FIFO
                queue[i] <= i;
                valid[i] <= 1'b1;
            end

            // data_out <= 0;
            // full_out <= 0;
            // empty_out <= 0;
            // valid_out <= 0;
            read_ptr <= 0;
            write_ptr <= 0;
            // valid_out <= 0;
        end else begin
            if (deq_in && !empty_out && valid[read_ptr]) begin
                // data_out <= queue[read_ptr];
                // valid_out <= 1;
                valid[read_ptr] <= 0; // reset valid bit
                read_ptr <= (read_ptr < DEPTH-1) ? read_ptr +1 : 0; // move read ptr by 1
            end 
            // else valid_out <= 0;
            if (enq_in && !full_out && valid[write_ptr] == 0) begin
                queue[write_ptr] <= enq_data_in; 
                valid[write_ptr] <= 1;
                write_ptr <= (write_ptr < DEPTH-1) ? write_ptr +1 : 0;
            end

            // data_out <= queue[read_ptr];
            // valid_out <= valid[read_ptr];
        end
    end
        
endmodule


`default_nettype wire