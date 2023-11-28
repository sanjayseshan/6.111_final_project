`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module bfis #(parameter DIM = 2, parameter PQ_LENGTH_IN = 8)(
  input wire clk_in,
  input wire rst_in,
  input wire [31:0] vertex_in,
  input wire vertex_valid_in,
  input wire [31:0] query_in [DIM-1:0],
  // input wire [15:0] pq_length_in,
  input wire [15:0] k_in,
  output logic [31:0] top_k_out [4:0],
  output logic valid_out
  );

  logic [4:0] state;

  always_ff @ (posedge clk_in) begin
    if (rst_in) begin
        top_k_out <= 0;
        valid_out <= 0;
    end

    // state 1
    else if (state==5'b0) begin
      if (vertex_valid_in) begin
        // compute distance between the two
        
        // add vertex to priority queue
      end
    end

    // state 2
    else if (state==5'b1) begin
    end

    else if (state==5'b10) begin
    end

    else if (state==5'b11) begin
    end

    else if (state==5'b100) begin
    end

    else if (state==5'b101) begin
    end

    else if (state==5'b110) begin
    end
  end


  logic mem_valid_in;
  logic [31:0] mem_data_in;
  logic mem_valid_out;
  logic [31:0] mem_req_out;

  logic mem_valid_in2;
  logic [3:0] mem_data_in2;
  logic mem_valid_out2;
  logic [31:0] mem_req_out2;

  logic pos_valid [DIM-1:0];
  logic [31:0] pos_vec [DIM-1:0];
  logic [31:0] query_in [DIM-1:0];
  logic [31:0] dist_out;
  logic data_valid_out;

  distance #(.DIM(DIM)) distance_calc (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .data_valid_in(pos_valid),
    .vertex_pos_in(pos_vec),
    .query_pos_in(query_in),
    .distance_sq_out(dist_out),
    .data_valid_out(dist_valid_out)
  );


  logic [$clog2(DIM):0] ct_dist;

  always_ff @( posedge clk_in ) begin
    if (rst_in) ct_dist <= 0;
    if (data_valid_out) begin
      pos_vec[ct_dist] <= data_out;
      dist_valid <= 1;
      if (ct_dist<DIM) begin 
        ct_dist <= ct_dist+1;
        pos_valid[ct_dist] <= 1;
      end else begin 
        ct_dist <= 0;
        pos_valid <= 0;
      end
    end

    
  end

  PriorityQueue #(.DATA_WIDTH(32), .TAG_WIDTH(32), .DEPTH(PQ_LENGTH_IN)) s (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .deq_in(1),
    .enq_data_in(neigh_fifo_out),
    .enq_tag_in(dist_out),
    .enq_in(dist_valid_out),
    .full_out(),
    .data_out(pq_out),
    .tag_out(dist_out),
    .size_out(),
    .empty_out(),
    .valid_out(pq_valid_out)
  );

  graph_memory# (.DIM(DIM), .PROC_BITS(0)) gmem (
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


    .idx_addr(vertex_in),
    .idx_validin(start_cycle),
    .rowidx_valid_out(start_addr_a_valid),
    .rowidx_out(start_addr_a),
  );


  graph_fetch #(.DIM(DIM)) graph(
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

    .neigh_deq_in(1),
    .neigh_fifo_out(neigh_fifo_out),
    .neigh_valid_out(neigh_valid_out),
    .neigh_full_out(neigh_full_out),
    .neigh_empty_out(neigh_empty_out),

    // MEMORY CONNECTIONS 
    .mem_valid_in(mem_valid_in),
    .mem_data_in(mem_data_in),
    .mem_valid_out(mem_valid_out),
    .mem_req_out(mem_req_out),
    .mem_valid_in2(mem_valid_in2),
    .mem_data_in2(mem_data_in2),
    .mem_valid_out2(mem_valid_out2),
    .mem_req_out2(mem_req_out2)
  );

  checked_visited #(.PROC_BITS(0)) cvmem (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .c_addr_in(pq_out),
    .v_addr_in(neigh_fifo_out),
    .c_addr_valid_in(pq_valid_out),
    .v_addr_valid_in(neigh_valid_out),
    .write_c_data_in(1),
    .write_c_valid_in(pq_valid_out),
    .write_v_data_in(1),
    .write_v_valid_in(neigh_valid_out),
    .checked_out(checked),
    .visited_out(visited),
    .valid_c_out(valid_checked),
    .valid_v_out(valid_visited)
   
  );


endmodule

`default_nettype wire