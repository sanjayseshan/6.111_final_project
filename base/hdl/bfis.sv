`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module bfis #(parameter DIM = 2, parameter PQ_LENGTH = 8)(
  input wire clk_in,
  input wire rst_in,
  input wire [31:0] vertex_id_in,
  input wire valid_in,
  input wire [31:0] query_in [DIM-1:0],
  input wire [15:0] k_in,
  output logic [31:0] top_k_out,
  output logic valid_out,
  output logic [2:0] state,

  output logic [31:0] debug,
  output logic [31:0] debug2
  );

  // ############################################################
  // ################## REGISTER DEFINITIONS ####################

  // distance variables
  logic [$clog2(DIM):0] ct_dist;
  logic [31:0] dist_out;
  logic dist_valid_out, distance_complete;
  logic pos_valid [DIM-1:0];
  logic [31:0] pos_vec [DIM-1:0];


  // retrieving data of first point
  logic initial_lookup;
  logic [31:0] idx_lookup_addr, idxaddr_out;
  logic idx_lookup_addr_valid, idxaddr_out_valid;


  // pq variables
  logic [31:0] point_addr, pq_out, pq_dist_out;
  logic [3:0] pq_size;
  logic pq_deq_in, pq_stall_out;
  logic pq_valid_out, pq_empty_out, pq_full_out;


  // graph fetching variables
  logic [31:0] neigh_fifo_out, data_out, v_addr_in;
  logic pos_empty_out, pos_full_out, fetch_data_valid_out;
  logic neigh_full_out, neigh_empty_out, neigh_valid_out, reached_neigh_end_out;
  logic neigh_deq, pos_deq;


  // fetching from memory
  logic mem_valid_in, mem_valid_out;
  logic [31:0] mem_data_in, mem_req_out;
  logic mem_valid_in2, mem_valid_out2;
  logic [31:0] mem_data_in2, mem_req_out2;


  // visited variables
  logic visited, valid_visited;
  logic [31:0] visited_addr_in;
  logic visited_addr_valid_in;


  // checked variables
  logic checked_valid_in, checked_valid_out;
  logic checked_max_deq, checked_min_deq;
  logic checked_full_out, checked_empty_out;
  logic [31:0] checked_tag_in;
  logic [31:0] checked_data_out, checked_tag_out, checked_max_tag;
  logic [$clog2(PQ_LENGTH):0] checked_size;
  logic checked_stall_out, remove_checked;


  logic [15:0] k_count;


  logic vertex_addr_in;
  logic [31:0] vertex_in, first_pos_lookup_addr, mem_data_in2_route;
  logic vertex_valid_in, first_pos_lookup_addr_valid, mem_valid_in2_route;


  // #####################################################
  // ################## DEBUGGING ########################

  // assign debug = pq_size;
  // assign debug2 = checked_size;


  // #####################################################
  // ################## STATE MACHINE ####################

  always_ff @ (posedge clk_in) begin
    if (rst_in) begin
      top_k_out <= 0;
      valid_out <= 1'b0;

      state <= 3'b0;

      initial_lookup <= 1'b0;

      ct_dist <= 0;
      distance_complete <= 1'b0;

      pq_deq_in <= 1'b0;
      point_addr <= 32'b0;

      checked_valid_in <= 1'b0;
      checked_max_deq <= 1'b0;
      checked_min_deq <= 1'b0;
      remove_checked <= 1'b0;

      k_count <= 0;
    end


    // state 0: looks up address of starting vertex
    else if (state ==  3'b0) begin
      // if valid input, initiate lookup
      if (valid_in) initial_lookup <= 1'b1;

      // look up address of first vertex
      if (initial_lookup) begin
        idx_lookup_addr <= vertex_id_in;
        idx_lookup_addr_valid <= 1'b1;
        initial_lookup <= 1'b0;
      end

      // if valid address received, find data of vertex
      if (idxaddr_out_valid) begin
        idx_lookup_addr_valid <= 1'b0;
        state <= 3'b1;

        point_addr <= idxaddr_out;

        first_pos_lookup_addr <= idxaddr_out+1+ct_dist;
        first_pos_lookup_addr_valid <= 1'b1;
      end
      else if (idx_lookup_addr_valid) begin
        idx_lookup_addr_valid <= 1'b0;
      end
    end


    // state 1: computes distance between starting point and query
    else if (state==3'b1) begin
      // if valid data, calculate distance
      if (mem_valid_in2_route) begin
        pos_vec[ct_dist] <= mem_data_in2_route;
        if (ct_dist<DIM) begin 
          first_pos_lookup_addr_valid <= 1'b1;
          first_pos_lookup_addr <= first_pos_lookup_addr + 1;
          
          ct_dist <= ct_dist+1;
          pos_valid[ct_dist] <= 1'b1;
          if (ct_dist != 0) pos_valid[ct_dist-1] <= 1'b0;
        end 
        else begin 
          pos_valid[DIM-1] <= 1'b0;
        end
      end
      else if (first_pos_lookup_addr_valid) first_pos_lookup_addr_valid <= 1'b0;

      // add vertex to priority queue
      if (dist_valid_out) begin
        ct_dist <= 0;
        first_pos_lookup_addr_valid <= 0;
        first_pos_lookup_addr <= 0;

        pos_valid[DIM-1] <= 0;
        pos_valid[DIM-2] <= 0;
        state <= 3'b10;
        pq_deq_in <= 1'b1;
      end
    end


    // state 2: check if top L vertices have been checked
    else if (state==3'b10) begin
      pq_deq_in <= 1'b0;

      // if valid output from priority queue, checked if value can be added to top L
      if (pq_valid_out) begin
        // if checked full and dist > max tag, end algorithm
        if ((checked_full_out && checked_max_tag < pq_dist_out)) begin
          state <= 3'b110;
          k_count <= 4'b0;
        end
        // if checked full and dist < max tag, deq from checked and add
        else if (checked_full_out && pq_dist_out < checked_max_tag) begin
          checked_max_deq <= 1'b1;
        end 
        // checked not full
        else if (~checked_full_out) begin
          checked_valid_in <= 1'b1;
          state <= 3'b11;

          k_count <= 4'b0;
        end
      end

      // successfully dequeued element from checked, now add element
      else if (checked_valid_out) begin
        checked_valid_in <= 1'b1;
        checked_max_deq <= 1'b0;
        state <= 3'b11;
      end
      else if (checked_max_deq) checked_max_deq <= 1'b0;
    end


    // state 3: visits next neighbor if exists
    else if (state==3'b11) begin
      checked_valid_in <= 1'b0;
     
      // deqs first neighbor, moves to state 4
      if (~neigh_empty_out) begin
        state <= 3'b100;
        neigh_deq <= 1'b1;
      end 

      // if no more neighbors, moves to state 5
      else if (reached_neigh_end_out && neigh_empty_out) begin
        state <= 3'b101;
      end
    end


    // state 4: visit all neighbors
    else if (state==3'b100) begin
      top_k_out <= neigh_fifo_out;

      // retrieve position after retrieving neighbor
      if (neigh_valid_out) begin
          point_addr <= neigh_fifo_out;
          pos_deq <= 1'b1;
          ct_dist <= 0;
      end

      // if valid data, calculate distance 
      if(fetch_data_valid_out) begin
        pos_vec[ct_dist] <= data_out;
        if (ct_dist<DIM) begin 
          ct_dist <= ct_dist+1;
          pos_valid[ct_dist] <= 1'b1;
          if (ct_dist != 0) pos_valid[ct_dist-1] <= 1'b0;
          if (ct_dist == DIM-2) pos_deq <= 1'b0;

        end else begin 
          pos_valid[DIM-1] <= 1'b0;
        end
      end 

      // if distance calculated and not all neighbors visited, get next neighbor
      if (dist_valid_out && ~neigh_empty_out) begin
        neigh_deq <= 1'b1;
        pos_deq <= 1'b0;
      end
      else neigh_deq <= 1'b0;

      // if calculated distance for final neighbor and element added to pq, move to state 5
      if (distance_complete && ~pq_empty_out) begin
          distance_complete <= 1'b0;
          state <= 3'b101;
      end
      // note if removed all neighbors and distance complete
      else if (reached_neigh_end_out && pos_empty_out && neigh_empty_out) begin
        if (dist_valid_out) distance_complete <= 1'b1;
      end
    end


    // state 5: remove next element from pq if possible
    else if (state==3'b101) begin
      // if no more elements, end algorithm
      if (pq_empty_out && ~checked_empty_out) begin
        state <= 3'b110;
        k_count <= 4'b0;
      end

      // otherwise, deq element with smallest tag and move to state 2
      else begin
        pq_deq_in <= 1'b1;
        state <= 3'b10;
      end
    end


    // state 6: remove top k
    else if (state==3'b110) begin
      // remove first element
      if (k_count==0) begin
        checked_min_deq <= 1'b1;
        k_count <= k_count + 1;
      end 
      else if (checked_min_deq) checked_min_deq <= 1'b0;

      // if valid output, look up vertex id
      if (checked_valid_out) begin
        first_pos_lookup_addr <= checked_data_out;
        first_pos_lookup_addr_valid <= 1'b1;

        // note to remove another element  
        if (k_count < k_in) remove_checked <= 1'b1;
        k_count <= k_count + 1;
      end

      // remove next element if deq complete and min updated
      else if (remove_checked && ~checked_stall_out) begin
        checked_min_deq <= 1'b1;
        remove_checked <= 1'b0;
      end
      else if (checked_min_deq) checked_min_deq <= 1'b0;
      else first_pos_lookup_addr_valid <= 1'b0;

      // output values
      top_k_out <= mem_data_in2_route;
      valid_out <= mem_valid_in2_route;

      // if finished removing all elements, move to state 7
      if (k_count > k_in && valid_out) state <= 3'b111;

    end


    // state 7: idle state after finishing algorithm to help with debugging
    else if (state==3'b111) begin
      valid_out <= 1'b0;
    end

  end


  // ##########################################################
  // ################## MODULE CONNECTIONS ####################


  // distance
  distance #(.DIM(DIM)) distance_calc (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .data_valid_in(pos_valid),
    .vertex_pos_in(pos_vec),
    .query_pos_in(query_in),
    .distance_sq_out(dist_out),
    .data_valid_out(dist_valid_out)
  );


  // checked queue
  CheckedQueue #(.DATA_WIDTH(32), .TAG_WIDTH(32), .DEPTH(PQ_LENGTH)) checked (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .deq_smallest_in(checked_min_deq),
    .deq_largest_in(checked_max_deq),
    .enq_data_in(v_addr_in),
    .enq_tag_in(pq_dist_out),
    .enq_in(checked_valid_in),
    .full_out(checked_full_out),
    .data_out(checked_data_out),
    .tag_out(checked_tag_out),
    .size_out(checked_size),
    .empty_out(checked_empty_out),
    .valid_out(checked_valid_out),
    .max_tag_out(checked_max_tag),
    .deq_stall_out(checked_stall_out)
  );


    // priority queue
    CheckedQueue #(.DATA_WIDTH(32), .TAG_WIDTH(32), .DEPTH(16'd8)) pq (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .deq_smallest_in(pq_deq_in),
    .deq_largest_in(1'b0),
    .enq_data_in(point_addr),
    .enq_tag_in(dist_out),
    .enq_in(dist_valid_out),
    .full_out(pq_full_out),
    .data_out(v_addr_in),
    .tag_out(pq_dist_out),
    .size_out(pq_size),
    .empty_out(pq_empty_out),
    .valid_out(pq_valid_out),
    .deq_stall_out(pq_stall_out)
  );


  // memory
  graph_memory# (.DIM(DIM), .PROC_BITS(0)) gmem (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .data_addra_in(mem_req_out),
    .data_addrb_in((state==3'b1||state==3'b110)?first_pos_lookup_addr:mem_req_out2),
    .data_validina(mem_valid_out),
    .data_validinb((state==3'b1||state==3'b110)?first_pos_lookup_addr_valid:mem_valid_out2),
    .data_outa(mem_data_in),
    .data_outb(mem_data_in2_route),
    .data_valid_outa(mem_valid_in),
    .data_valid_outb(mem_valid_in2_route),

    .idx_addr(idx_lookup_addr),
    .idx_validin(idx_lookup_addr_valid),
    .rowidx_out(idxaddr_out),
    .rowidx_valid_out(idxaddr_out_valid)
  );


  // visited bram
  visited #(.PROC_BITS(0)) vmem (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .v_addr_in(visited_addr_in),
    .v_addr_valid_in(visited_addr_valid_in),
    .visited_out(visited),
    .valid_v_out(valid_visited)  
  );


  // graph fetcher
  graph_fetch #(.DIM(DIM)) graph(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .v_addr_in(v_addr_in),
    .valid_in(pq_valid_out),

    .pos_deq_in(pos_deq),
    .data_out(data_out),
    .data_valid_out(fetch_data_valid_out),
    .pos_full_out(pos_full_out),
    .pos_empty_out(pos_empty_out),

    .neigh_deq_in(neigh_deq),
    .neigh_fifo_out(neigh_fifo_out),
    .neigh_valid_out(neigh_valid_out),
    .neigh_full_out(neigh_full_out),
    .neigh_empty_out(neigh_empty_out),
    .reached_neigh_end_out(reached_neigh_end_out),

    // MEMORY CONNECTIONS 
    .mem_valid_in(mem_valid_in),
    .mem_data_in(mem_data_in),
    .mem_valid_out(mem_valid_out),
    .mem_req_out(mem_req_out),
    .mem_valid_in2(mem_valid_in2_route),
    .mem_data_in2(mem_data_in2_route),
    .mem_valid_out2(mem_valid_out2),
    .mem_req_out2(mem_req_out2),

    .visited_req_out(visited_addr_in),
    .visited_req_valid_out(visited_addr_valid_in),
    .visited_val_in(visited),
    .visited_val_valid_in(valid_visited)
  );


endmodule

`default_nettype wire
