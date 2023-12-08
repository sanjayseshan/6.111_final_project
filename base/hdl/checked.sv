`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module CheckedQueue #(parameter DATA_WIDTH = 32, parameter TAG_WIDTH = 32, parameter DEPTH = 8)(
  input wire clk_in,
  input wire rst_in,
  input wire deq_smallest_in,
  input wire deq_largest_in,
  input wire [DATA_WIDTH-1:0] enq_data_in,
  input wire [TAG_WIDTH-1:0] enq_tag_in,
  input wire enq_in,
  output logic full_out,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic [TAG_WIDTH-1:0] tag_out,
  output logic [$clog2(DEPTH):0] size_out,
  output logic empty_out,
  output logic valid_out,
  output logic [TAG_WIDTH-1:0] max_tag_out,
  output logic proc_deq_ready
);
    


    logic [TAG_WIDTH-1:0] queue [DEPTH-1:0]; // distances
    logic [DATA_WIDTH-1:0] Q_data [DEPTH-1:0]; // point
    logic valid [DEPTH-1:0]; 

    logic [$clog2(DEPTH):0] read_ptr_min, read_ptr_max, prev_read_ptr;
    logic [$clog2(DEPTH):0] write_ptr;
    logic [DATA_WIDTH-1:0] curval;
    logic [DATA_WIDTH-1:0] maxval;

    logic rem_lru;
    logic push_lru;
    
    logic deq_high;

    logic [$clog2(DEPTH)+1:0] i;
    logic ready;

    always_ff @( posedge clk_in ) begin
        if (rst_in) begin
            empty_out <= 0;
            full_out <= 0;
            i <= 0;
            curval <= 32'hFFFFFFFF;//deq_smallest_in ? 32'hFFFFFFFF : 32'h0;
            maxval <= 32'h0;

            deq_high <= 1'b0;

        end else begin
            empty_out = (size_out == 0);
            full_out = (size_out == DEPTH);
            // deq_in = deq_smallest_in || deq_largest_in;

            
            if (i==DEPTH) begin
                i <= 0;
                ready <= 1'b1;
            end
            else if (i <= DEPTH) begin
                i <= i + 1;
                ready <= 1'b0;
                // curval <= 32'hFFFFFFFF;//deq_smallest_in ? 32'hFFFFFFFF : 32'h0;
                // maxval <= 32'h0;
            end

            // if (deq_smallest_in) begin
                // for (int i = 0; i<DEPTH; i=i+1) begin
            if (valid[i] && queue[i] < curval) begin
                read_ptr_min = i;
                curval <= queue[i];
            end

            // if (valid[i] && queue[i] >= maxval) begin
            //     maxval = queue[i];
            // end
                // end
            // end
            // else begin
                // for (int i = 0; i<DEPTH; i=i+1) begin
            if (valid[i] && queue[i] >= maxval) begin
                read_ptr_max = i;
                // curval = queue[i];
                maxval <= queue[i];
            end
                // end
            // end

            // max_tag_out <= queue[i];
            // if (enq_in) begin
            //     max_tag_out <= (enq_data_in > max_tag_out) ? enq_data_in : max_tag_out;
            // end
            if (deq_largest_in || deq_smallest_in) begin
                deq_high <= 1'b1;
            end
            else if (deq_high && valid_out) begin
                maxval <= 0;
                curval <= 32'hFFFFFFFF;
                deq_high <= 1'b0;
            end

            
            max_tag_out <= maxval;

        end
        
    end

    logic [1:0] in_req_out;
    logic in_req_valid_out;

    FIFO #(.DATA_WIDTH(2),.DEPTH(8)) buf_out_max (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .enq_data_in({deq_smallest_in,deq_largest_in}),
        .enq_in(deq_smallest_in || deq_largest_in),
        .deq_in(ready),
        .full_out(),
        .data_out(in_req_out),
        .empty_out(proc_deq_ready),
        .valid_out(in_req_valid_out)
    );


    // always_comb begin
    //     proc_deq = (!nproc_deq_1);
    // end


    // // finds largest value in queue (supposedly)
    // always_comb begin
     
    // end

    // find lru index to write next element
    PQ_FIFO_CH #(.DATA_WIDTH($clog2(DEPTH)+1), .DEPTH(DEPTH)) lru_cache (
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
            end
            prev_read_ptr <= 0;
            data_out <= 0;
            valid_out <= 0;
            size_out <= 0;
            max_tag_out <= 0;
        end 
        else begin
            // dequeue smallest element
            if ((in_req_out[1] && in_req_valid_out) && ~empty_out && valid[read_ptr_min]) begin
                data_out <= Q_data[read_ptr_min];
                tag_out <= queue[read_ptr_min];
                push_lru <= 1'b1;
                valid_out <= 1;
                valid[read_ptr_min] <= 0;
                // read_ptr <= (read_ptr < DEPTH-1) ? read_ptr + 1 : 0;
                prev_read_ptr <= read_ptr_min;
                size_out <= size_out -1;
            // dequeue largest element
            end else if ((in_req_out[0] && in_req_valid_out) && ~empty_out && valid[read_ptr_max]) begin
                data_out <= Q_data[read_ptr_max];
                tag_out <= queue[read_ptr_max];
                push_lru <= 1'b1;
                valid_out <= 1;
                valid[read_ptr_max] <= 0;
                // read_ptr <= (read_ptr < DEPTH-1) ? read_ptr + 1 : 0;
                prev_read_ptr <= read_ptr_max;
                size_out <= size_out -1;
            end else begin
                valid_out <= 0;
                push_lru <= 1'b0;
            end
            // enqueue element
            if (enq_in && ~full_out && valid[write_ptr] == 0) begin
                size_out <= size_out +1;
                Q_data[write_ptr] <= enq_data_in;
                queue[write_ptr] <= enq_tag_in;
                rem_lru <= 1;
                valid[write_ptr] <= 1;
            end else rem_lru <= 0;
            
        end
    end
        
endmodule


// fifo for finding earliest dequeued index
module PQ_FIFO_CH #(parameter DATA_WIDTH = 32, parameter DEPTH = 8)(
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
                valid[i] <= 1;
            end


            read_ptr <= 0;
            write_ptr <= 0;
        end else begin
            if (deq_in && !empty_out && valid[read_ptr]) begin
                valid[read_ptr] <= 0; // reset valid bit
                read_ptr <= (read_ptr < DEPTH-1) ? read_ptr +1 : 0; // move read ptr by 1
            end 
            if (enq_in && !full_out && valid[write_ptr] == 0) begin
                queue[write_ptr] <= enq_data_in; 
                valid[write_ptr] <= 1;
                write_ptr <= (write_ptr < DEPTH-1) ? write_ptr +1 : 0;
            end
        end
    end
        
endmodule


`default_nettype wire