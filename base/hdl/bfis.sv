`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module bfis #(parameter DIM = 2, parameter PQ_LENGTH = 8)(
  input wire clk_in,
  input wire rst_in,
  // input wire [31:0] vertex_in,
  // input wire [31:0] vertex_addr_in,
  input wire [31:0] vertex_id_in,
  // input wire vertex_valid_in,
  input wire valid_in,
  input wire [31:0] query_in [DIM-1:0],
  // input wire [15:0] pq_length_in,
  input wire [15:0] k_in,
  output logic [31:0] top_k_out,
  output logic valid_out,
  output logic [2:0] state,

  output logic [31:0] debug,
  output logic [31:0] debug2
  );


  logic [31:0] point_addr;

  logic [$clog2(DIM):0] ct_dist;
  
  logic pos_valid [DIM-1:0];
  logic [31:0] pos_vec [DIM-1:0];

  logic [31:0] neigh_fifo_out, data_out, v_addr_in;
  logic pos_empty_out, pos_full_out, fetch_data_valid_out, pos_deq_in, ready_out;
  logic neigh_full_out, neigh_empty_out, neigh_valid_out, reached_neigh_end_out;

  logic [31:0] pq_out, pq_dist_out;
  logic pq_valid_out;
  logic [3:0] pq_size;
  logic pq_deq_in;
  logic pq_empty_out;



  logic mem_valid_in, mem_valid_out;
  logic [31:0] mem_data_in, mem_req_out;

  logic mem_valid_in2, mem_valid_out2;
  logic [31:0] mem_data_in2, mem_req_out2;



  logic data_valid_out;


  logic neigh_deq, pos_deq;


  logic [31:0] dist_out;
  logic dist_valid_out, distance_complete;


  logic visited, valid_visited;
  logic [31:0] visited_addr_in;
  logic visited_addr_valid_in;


  logic checked_valid_in, checked_valid_out;
  logic checked_max_deq, checked_min_deq;
  logic checked_full_out, checked_empty_out;
  logic [31:0] checked_data_in, checked_tag_in;
  logic [31:0] checked_data_out, checked_tag_out, checked_max_tag;
  logic [$clog2(PQ_LENGTH):0] checked_size;
  logic [5:0] checked_counter;


  logic [15:0] k_count;

  logic initial_lookup;

  logic [31:0] idx_lookup_addr;
  logic idx_lookup_addr_valid;
  logic [31:0] idxaddr_out;
  logic idxaddr_out_valid, checked_proc_deq;

  logic vertex_addr_in;
  logic [31:0] vertex_in, first_pos_lookup_addr, mem_req_out2_route, mem_data_in2_route;
  logic vertex_valid_in, first_pos_lookup_addr_valid, mem_valid_out2_route, mem_valid_in2_route;

  logic add_checked;
  logic [$clog2(PQ_LENGTH):0] prev_checked_size;

  // always_comb begin
  //   if (state == 3'b1 || state==3'b110) begin
  //     // mem_req_out2_route = first_pos_lookup_addr;
  //     // mem_valid_out2_route = first_pos_lookup_addr_valid;
  //     // vertex_in = mem_data_in2_route;
  //     // vertex_valid_in = mem_valid_in2_route;
  //   end else begin
  //     // mem_req_out2_route = mem_req_out2;
  //     // mem_valid_out2_route = mem_valid_out2;
  //     // mem_data_in2 = mem_data_in2_route;
  //     // mem_valid_in2 = mem_valid_in2_route;
  //   end
  // end


  // assign debug = pq_size | (dist_valid_out << 30);
  assign debug = v_addr_in;
  assign debug2 = checked_valid_in;


  always_ff @ (posedge clk_in) begin
    if (rst_in) begin
        // top_k_out <= 0;
        valid_out <= 1'b0;

        state <= 3'b0;
        // initial_lookup <= 1'b1;
        initial_lookup <= 1'b0;

        ct_dist <= 0;
        pq_deq_in <= 1'b0;
        // point_addr <= vertex_addr_in;
        point_addr <= 0;

        distance_complete <= 1'b0;

        checked_valid_in <= 1'b0;
        checked_max_deq <= 1'b0;
        checked_min_deq <= 1'b0;

        k_count <= 0;

        add_checked <= 1'b0;

        prev_checked_size <= 0;
    end

    //initial_lookup == 1'b1 && state ==  3'b0

    // state 0: computes distance between P and Q and adds P to S
    else if (state ==  3'b0) begin
        if (valid_in) initial_lookup <= 1'b1;

        if (initial_lookup) begin
          idx_lookup_addr <= vertex_id_in;
          idx_lookup_addr_valid <= 1'b1;
          initial_lookup <= 1'b0;
        end

        // top_k_out <= idxaddr_out_valid;
        // top_k_out[2] <= idx_lookup_addr_valid;
        // top_k_out[2] <= idxaddr_out_valid;
        // top_k_out[3] <= idxaddr_out;


        if (idxaddr_out_valid) begin
          idx_lookup_addr_valid <= 1'b0;
          // vertex_addr_in <= idxaddr_out;
          state <= 3'b1;

          point_addr <= idxaddr_out;
          // initial_lookup <= 1'b0;

          first_pos_lookup_addr <= idxaddr_out+1+ct_dist;
          first_pos_lookup_addr_valid <= 1'b1;
        end
        else if (idx_lookup_addr_valid) begin
          idx_lookup_addr_valid <= 1'b0;
        end

    // state==3'b0 && initial_lookup == 1'b0
    end else if (state==3'b1) begin
      // compute distance between the two
      // point_addr <= vertex_addr_in;

        // top_k_out <= dist_valid_out;
      
      // first_pos_lookup_addr <= point_addr+1+ct_dist;
      // first_pos_lookup_addr_valid <= 1'b1;

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
          // ct_dist <= 0;
          pos_valid[DIM-1] <= 1'b0;
        end
      end
      else if (first_pos_lookup_addr_valid) first_pos_lookup_addr_valid <= 1'b0;

      // add vertex to priority queue
      if (dist_valid_out) begin
          // if (pq_size >= 1) begin
            ct_dist <= 0;
            first_pos_lookup_addr_valid <= 0;
            first_pos_lookup_addr <= 0;

            pos_valid[DIM-1] <= 0;
            pos_valid[DIM-2] <= 0;
            state <= 3'b10;
            pq_deq_in <= 1'b1;
            // sent <= 0;
            // valid_in <= 1'b1;
            // v_addr_in <= vertex_addr_in;
          // end
      end


      // top_k_out[2] <= dist_valid_out;// mem_valid_in; //mem_req_out;
      // top_k_out[3] <= dist_valid_out;// mem_valid_in; //mem_req_out;
    end

    // state 1
    else if (state==3'b10) begin
      // neigh_deq_in <= 1;
      pq_deq_in <= 1'b0;
      // visited_addr_in <= v_addr_in;
      // visited_addr_valid_in <= (pq_valid_out && (sent == 0));
      // valid_in <= 1'b1;
      // top_k_out[0] <= neigh_fifo_out;//neigh_fifo_out;//mem_req_out2; // v_addr_in;//mem_req_out; //v_addr_in;
      // top_k_out[1] <= neigh_valid_out;//neigh_valid_out;// mem_data_in2;//neigh_fifo_out;
      // top_k_out[2] <= data_out;//data_out;//mem_valid_out2;//mem_data_in;
      // top_k_out[3] <= fetch_data_valid_out ;//fetch_data_valid_out;//mem_valid_in2;//dist_valid_out;// mem_valid_in; //mem_req_out;

      // top_k_out <= checked_valid_out;

      // if (prev_checked_size < checked_size) begin
      //     state <= 3'b11;
      //     // add_checked <= 1'b0;
      // end
      if (pq_valid_out) begin
        if ((checked_full_out && checked_max_tag < pq_dist_out)) begin
          state <= 3'b110;
          k_count <= 4'b0;
        end
        else if (checked_full_out && pq_dist_out < checked_max_tag) begin
          checked_max_deq <= 1'b1;
        // end else if (~checked_proc_deq) begin
        //   checked_max_deq <= 1'b0;
        end else if (~checked_full_out) begin
          checked_valid_in <= 1'b1;
          state <= 3'b11;
          // add_checked <= 1'b1;

          checked_counter <= 2'b0;
          k_count <= 4'b0;
          // if (checked_max_deq) checked_max_deq <= 1'b0;
        end
      end
      else if (checked_valid_out) begin
        checked_valid_in <= 1'b1;
        checked_max_deq <= 1'b0;
        state <= 3'b11;
        // add_checked <= 1'b1;
        prev_checked_size <= checked_size;
      end
      else if (checked_max_deq) checked_max_deq <= 1'b0;

      // if (checked_valid_in) checked_valid_in <= 1'b0;

    end

    else if (state==3'b11) begin
      checked_valid_in <= 1'b0;
      // deqs first neighbor
      if (~neigh_empty_out) begin
          // sent <= 0;
        
        // if (visited == 0) begin
          state <= 3'b100;
        // end else state <= 0;
        neigh_deq <= 1'b1;
      end 
      else if (reached_neigh_end_out && neigh_empty_out) begin
        state <= 3'b101;
      end
      // else if (visited_addr_valid_in) sent <=1;
    end

    else if (state==3'b100) begin
      // top_k_out <= neigh_fifo_out;//neigh_fifo_out;//mem_req_out2; // v_addr_in;//mem_req_out; //v_addr_in;
      // top_k_out[1] <= neigh_valid_out;//neigh_valid_out;// mem_data_in2;//neigh_fifo_out;
      top_k_out <= neigh_fifo_out;//pos_deq <= 1'b0;;//mem_valid_out2;//mem_data_in;
      // top_k_out[3] <= fetch_data_valid_out ;//fetch_data_valid_out;//mem_valid_in2;//dist_valid_out;// mem_valid_in; //mem_req_out;

      // retrieve position after retrieving neighbor
      //visited_addr_valid_in <= neigh_valid_out;
      if (neigh_valid_out) begin
          // visited_addr_in <= neigh_fifo_out;
          point_addr <= neigh_fifo_out;
          pos_deq <= 1'b1;
          ct_dist <= 0;
      end
      //  else pos_deq <= 1'b0;


      // top_k_out <= {fetch_data_valid_out};//{dist_valid_out,pos_valid[0],pos_valid[1],pos_valid[2],pos_valid[3]};

      // calculate distance 
      if(fetch_data_valid_out) begin
        pos_vec[ct_dist] <= data_out;
        if (ct_dist<DIM) begin 
          ct_dist <= ct_dist+1;
          pos_valid[ct_dist] <= 1'b1;
          if (ct_dist != 0) pos_valid[ct_dist-1] <= 1'b0;
          if (ct_dist == DIM-1) pos_deq <= 1'b0;

        end else begin 
          pos_valid[DIM-1] <= 1'b0;
        end
      end

      // if distance calculated and not all neighbors visited, get next neighbor
      // if(dist_valid_out && ~reached_neigh_end_out && neigh_empty_out) begin
      //   distance_complete <= 1'b1;
      //   pos_deq <= 1'b1;
      // end
      // else if (dist_valid_out && ~reached_neigh_end_out) begin
      if (dist_valid_out && ~neigh_empty_out) begin
        neigh_deq <= 1'b1;
        pos_deq <= 1'b0;
      end
      // else if (distance_complete && ~neigh_empty_out) begin
      //   neigh_deq <= 1'b1;
      //   pos_deq <= 1'b0;
      //   distance_complete <= 1'b0;
      // end
      else neigh_deq <= 1'b0;

      // if all distances calculated, go to next state
      // if(reached_neigh_end_out && pos_empty_out && dist_valid_out) state <= 5'b100;
      // else if (reached_neigh_end_out && pos_empty_out && distance_complete) begin
      //   distance_complete <= 1'b0;
      //   state <= 5'b100;
      // end

      // added neigh_empty_out
      if (distance_complete && ~pq_empty_out) begin
          distance_complete <= 1'b0;
          state <= 3'b101;
      end
      else if (reached_neigh_end_out && pos_empty_out && neigh_empty_out) begin
        if (dist_valid_out) distance_complete <= 1'b1;
        // if (dist_valid_out) state <= 3'b101;
        // else if (distance_complete) begin
        //   distance_complete <= 1'b0;
        //   state <= 3'b101;
        // end
      end
    end

    else if (state==3'b101) begin
      // if (pq_size > 3) state <= 3'b111;
      if (pq_empty_out && ~checked_empty_out) begin
        state <= 3'b110;
        k_count <= 4'b0;
      end
      else begin
        pq_deq_in <= 1'b1;
        state <= 3'b10;
        prev_checked_size <= checked_size;
      end
    end

    else if (state==3'b110) begin
      // top_k_out <= k_in;
      // if (k_count < k_in) begin
      //   checked_min_deq <= 1'b1;
      //   k_count <= k_count + 1;
      // end
      // else begin
      //   checked_min_deq <= 1'b0;
      // end

      if (k_count==0) begin
        checked_min_deq <= 1'b1;
        k_count <= k_count + 1;
      end 
      else if (checked_min_deq) checked_min_deq <= 1'b0;

      if (checked_valid_out) begin
        // first_pos_lookup_addr <= checked_data_out;
        // first_pos_lookup_addr_valid <= 1'b1;
          
        if (k_count < k_in) begin
          checked_min_deq <= 1'b1;
        end
        else begin
          checked_min_deq <= 1'b0;
        end

        k_count <= k_count + 1;
      // vertex_in ;
      // vertex_valid_in;
        // valid_out <= 1'b1;
        // top_k_out <= checked_data_out;//checked_data_out;
        top_k_out <= checked_data_out;
      end
      else first_pos_lookup_addr_valid <= 1'b0;

      // top_k_out <= mem_data_in2_route;//checked_data_out;
      //valid_out <= mem_valid_in2_route;
      valid_out <= checked_valid_out;

      // if (k_count >= k_in) state <= 3'b111;

    end

    else if (state==3'b111) begin
      valid_out <= 1'b0;
    end


    // if (state!=3'b101) 
    // top_k_out <= checked_max_deq| checked_min_deq;;// 

  end


  distance #(.DIM(DIM)) distance_calc (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .data_valid_in(pos_valid),
    .vertex_pos_in(pos_vec),
    .query_pos_in(query_in),
    .distance_sq_out(dist_out),
    .data_valid_out(dist_valid_out)
  );



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
    .proc_deq_ready(checked_proc_deq)
  );



  CheckedQueue #(.DATA_WIDTH(32), .TAG_WIDTH(32), .DEPTH(16'd8)) pq (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .deq_smallest_in(pq_deq_in),
    .deq_largest_in(1'b0),
    .enq_data_in(point_addr),
    .enq_tag_in(dist_out),
    .enq_in(dist_valid_out),
    // .full_out(),
    .data_out(v_addr_in),
    .tag_out(pq_dist_out),
    .size_out(pq_size),
    .empty_out(pq_empty_out),
    // .size_out(debug),
    .valid_out(pq_valid_out)
  );


  // always_ff @( posedge clk_in ) begin
  //   if (rst_in) ct_dist <= 0;
  //   if (data_valid_out) begin
  //     pos_vec[ct_dist] <= data_out;
  //     dist_valid <= 1;
  //     if (ct_dist<DIM) begin 
  //       ct_dist <= ct_dist+1;
  //       pos_valid[ct_dist] <= 1;
  //     end else begin 
  //       ct_dist <= 0;
  //       pos_valid <= 0;
  //     end
  //   end
  // end


  // logic start_cycle;

  graph_memory# (.DIM(DIM), .PROC_BITS(0)) gmem (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .data_addra(mem_req_out),
    .data_addrb((state==3'b1||state==3'b110)?first_pos_lookup_addr:mem_req_out2),
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



  visited #(.PROC_BITS(0)) vmem (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .v_addr_in(visited_addr_in), //neigh_fifo_out
    .v_addr_valid_in(visited_addr_valid_in), //neigh_valid_out
    .visited_out(visited),
    .valid_v_out(valid_visited)  
  );


  graph_fetch #(.DIM(DIM)) graph(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .v_addr_in(v_addr_in),
    .valid_in(pq_valid_out), // && !visited && valid_visited
    .ready_out(ready_out),

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
    .visited_val_returned_in(visited),
    .visited_val_returned_valid_in(valid_visited)
  );


endmodule

`default_nettype wire
