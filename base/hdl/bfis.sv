`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module bfis #(parameter DIM = 2, parameter PQ_LENGTH = 8)(
  input wire clk_in,
  input wire rst_in,
  input wire [31:0] vertex_in,
  input wire [31:0] vertex_addr_in,
  input wire vertex_valid_in,
  input wire [31:0] query_in [DIM-1:0],
  // input wire [15:0] pq_length_in,
  input wire [15:0] k_in,
  output logic [31:0] top_k_out [4:0],
  output logic valid_out,
  output logic [4:0] state
  );


  logic [31:0] point_addr;

  logic [$clog2(DIM):0] ct_dist;
  
  logic pos_valid [DIM-1:0];
  logic [31:0] pos_vec [DIM-1:0];

  logic [31:0] neigh_fifo_out, data_out, v_addr_in;
  logic pos_empty_out, pos_full_out, fetch_data_valid_out, pos_deq_in, valid_in, ready_out;
  logic neigh_full_out, neigh_empty_out, neigh_valid_out, reached_neigh_end_out;

  logic [31:0] pq_out, pq_dist_out;
  logic pq_valid_out;
  logic [$clog2(PQ_LENGTH):0] pq_size;
  logic pq_deq_in;



  logic mem_valid_in;
  logic [31:0] mem_data_in;
  logic mem_valid_out;
  logic [31:0] mem_req_out;

  logic mem_valid_in2;
  logic [31:0] mem_data_in2;
  logic mem_valid_out2;
  logic [31:0] mem_req_out2;


  logic data_valid_out;

  logic neigh_deq, pos_deq;



  logic [31:0] dist_out;
  logic dist_valid_out; 


  logic checked, visited, valid_checked, valid_visited;
  // logic update_checked, update_visited;

  logic [31:0] visited_addr_in;
  logic visited_addr_valid_in;

  logic sent;

  always_ff @ (posedge clk_in) begin
    if (rst_in) begin
        // top_k_out <= 0;
        valid_out <= 1'b0;

        state <= 5'b0;

        ct_dist <= 0;
        pq_deq_in <= 1'b0;
        point_addr <= vertex_addr_in;
    end

    // state 0: computes distance between P and Q and adds P to S
    else if (state==5'b0) begin
      // compute distance between the two
      point_addr <= vertex_addr_in;

      if (vertex_valid_in) begin
        pos_vec[ct_dist] <= vertex_in;
        if (ct_dist<DIM) begin 
          ct_dist <= ct_dist+1;
          pos_valid[ct_dist] <= 1'b1;
          if (ct_dist != 0) pos_valid[ct_dist-1] <= 1'b0;

        end 
        // else begin 
        //   ct_dist <= 0;
        //   pos_valid[DIM-1] <= 1'b0;
        // end
      end

      // add vertex to priority queue
      else if (dist_valid_out) begin
          // if (pq_size >= 1) begin
            ct_dist <= 0;

            pos_valid[DIM-1] <= 0;
            pos_valid[DIM-2] <= 0;
            state <= 5'b1;
            pq_deq_in <= 1'b1;
            sent <= 0;

            // valid_in <= 1'b1;
            // v_addr_in <= vertex_addr_in;
          // end
      end


      top_k_out[2] <= dist_valid_out;// mem_valid_in; //mem_req_out;
      top_k_out[3] <= dist_valid_out;// mem_valid_in; //mem_req_out;
    end

    // state 1
    else if (state==5'b1) begin
      // neigh_deq_in <= 1;
      pq_deq_in <= 1'b0;
      visited_addr_in <= v_addr_in;
      visited_addr_valid_in <= (pq_valid_out && (sent == 0));
      // valid_in <= 1'b1;
      top_k_out[0] <= neigh_fifo_out;//neigh_fifo_out;//mem_req_out2; // v_addr_in;//mem_req_out; //v_addr_in;
      top_k_out[1] <= neigh_valid_out;//neigh_valid_out;// mem_data_in2;//neigh_fifo_out;
      top_k_out[2] <= data_out;//data_out;//mem_valid_out2;//mem_data_in;
      top_k_out[3] <= fetch_data_valid_out ;//fetch_data_valid_out;//mem_valid_in2;//dist_valid_out;// mem_valid_in; //mem_req_out;

      // deqs first neighbor
      if (~neigh_empty_out) begin
          sent <= 0;
        
        if (visited == 0) begin
          state <= 5'b10;
        end else state <= 0;
        neigh_deq <= 1'b1;
      end else if (visited_addr_valid_in) sent <=1;
    end

    else if (state==5'b10) begin
      top_k_out[0] <= neigh_fifo_out;//neigh_fifo_out;//mem_req_out2; // v_addr_in;//mem_req_out; //v_addr_in;
      top_k_out[1] <= neigh_valid_out;//neigh_valid_out;// mem_data_in2;//neigh_fifo_out;
      top_k_out[2] <= data_out;//data_out;//mem_valid_out2;//mem_data_in;
      top_k_out[3] <= fetch_data_valid_out ;//fetch_data_valid_out;//mem_valid_in2;//dist_valid_out;// mem_valid_in; //mem_req_out;

      // retrieve position after retrieving neighbor
      //visited_addr_valid_in <= neigh_valid_out;
      if (neigh_valid_out) begin
          visited_addr_in <= neigh_fifo_out;
          point_addr <= neigh_fifo_out;
          pos_deq <= 1'b1;
          ct_dist <= 0;
      end

      // calculate distance 
      if(fetch_data_valid_out) begin
        pos_vec[ct_dist] <= data_out;
        if (ct_dist<DIM) begin 
          ct_dist <= ct_dist+1;
          pos_valid[ct_dist] <= 1'b1;
          if (ct_dist != 0) pos_valid[ct_dist-1] <= 1'b0;
        end else begin 
          pos_valid[DIM-1] <= 1'b0;
        end
      end

      // if distance calculated and not all neighbors visited, get next neighbor
      if(dist_valid_out && ~reached_neigh_end_out) begin
        neigh_deq <= 1'b1;
        pos_deq <= 1'b0;
      end
      else neigh_deq <= 1'b0;

      // if all distances calculated, go to next state
      if(reached_neigh_end_out && pos_empty_out && dist_valid_out) state <= 5'b11;
    end

    else if (state==5'b11) begin
      pq_deq_in <= 1'b1;
      state <= 1'b1;
    end

    else if (state==5'b100) begin
    end

    else if (state==5'b101) begin
    end

    else if (state==5'b110) begin
    end
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




  PriorityQueue #(.DATA_WIDTH(32), .TAG_WIDTH(32), .DEPTH(PQ_LENGTH)) s (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .deq_in(pq_deq_in),
    .enq_data_in(point_addr),
    .enq_tag_in(dist_out),
    .enq_in(dist_valid_out),
    // .full_out(),
    .data_out(v_addr_in),
    .tag_out(pq_dist_out),
    .size_out(pq_size),
    // .empty_out(),
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


  // PriorityQueue #(.DATA_WIDTH(32), .TAG_WIDTH(32), .DEPTH(PQ_LENGTH)) s (
  //   .clk_in(clk_in),
  //   .rst_in(rst_in),
  //   .deq_in(1'b1),
  //   .enq_data_in(neigh_fifo_out),
  //   .enq_tag_in(dist_out),
  //   .enq_in(dist_valid_out),
  //   .full_out(),
  //   .data_out(pq_out),
  //   .tag_out(dist_out),
  //   .size_out(),
  //   .empty_out(),
  //   .valid_out(pq_valid_out)
  // );


  // logic start_cycle;

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
    .data_valid_outb(mem_valid_in2)


    // .idx_addr(vertex_in),
    // .idx_validin(start_cycle),
    // .rowidx_valid_out(start_addr_a_valid),
    // .rowidx_out(start_addr_a)
  );



  graph_fetch #(.DIM(DIM)) graph(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .v_addr_in(v_addr_in),
    .valid_in(!visited && valid_visited), //pq_valid_out && 
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
    .mem_valid_in2(mem_valid_in2),
    .mem_data_in2(mem_data_in2),
    .mem_valid_out2(mem_valid_out2),
    .mem_req_out2(mem_req_out2)
  );

 

  visited #(.PROC_BITS(0)) vmem (
    .clk_in(clk_in),
    .rst_in(rst_in),
    // .c_addr_in(pq_out),
    .v_addr_in(visited_addr_in), //neigh_fifo_out
    // .c_addr_valid_in(pq_valid_out),
    .v_addr_valid_in(visited_addr_valid_in), //neigh_valid_out
    // .write_c_data_in(1'b1),
    // .write_c_valid_in(pq_valid_out),
    // .write_v_data_in(1'b1),
    // .write_v_valid_in(neigh_valid_out),
    // .checked_out(checked),
    .visited_out(visited),
    // .valid_c_out(valid_checked),
    .valid_v_out(valid_visited)  
  );


endmodule

`default_nettype wire
