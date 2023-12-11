`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module graph_fetch #(parameter DIM = 2)(
  input wire clk_in,
  input wire rst_in,
  input wire [31:0] v_addr_in,
  input wire valid_in,
  
  input wire pos_deq_in, // output position vector value
  output logic [31:0] data_out, // output position vector values one by one
  output logic data_valid_out,
  output logic pos_full_out,
  output logic pos_empty_out,

  input wire neigh_deq_in, // output neighbor
  output logic [31:0] neigh_fifo_out, // output neighbors one by one
  output logic neigh_valid_out,
  output logic neigh_full_out,
  output logic neigh_empty_out,
  output logic reached_neigh_end_out,

  input wire mem_valid_in,
  input wire [31:0] mem_data_in,
  output logic mem_valid_out,
  output logic [31:0] mem_req_out,

  input wire mem_valid_in2,
  input wire [31:0] mem_data_in2,
  output logic mem_valid_out2,
  output logic [31:0] mem_req_out2,

  output logic [31:0] visited_req_out,
  output logic visited_req_valid_out,
  input wire visited_val_returned_in,
  input wire visited_val_returned_valid_in
  );

  // logic [31:0] mem_req_out2; // neighbor address
  // logic [31:0] mem_req_out; // data address
  // logic mem_valid_in2, mem_valid_in; // valid values from BRAM

  // logic neigh_ready;
  // logic data_ready;

  // logic [31:0] mem_data_in2; // neighbor output from BRAM
  // logic [31:0] mem_data_in; // position output from BRAM

  logic [$clog2(DIM)+1:0] ct; // count for position dims retrieved

  logic req_ready_n;
  logic req_ready_d;
  logic valid_bit;
  // logic mem_valid_out;

  // always_comb begin
  //   // mem_req_out = mem_req_out;
  //   // mem_valid_out = mem_valid_out;
  //   // mem_data_in = mem_data_in;
  //   // mem_valid_in = mem_valid_in;

  //   // mem_req_out2 = mem_req_out2;
  //   mem_valid_out2 = req_ready_n&&(neigh_full_out!=1'b1);
  //   // mem_data_in2 = mem_data_in2;
  //   // mem_valid_in2 = mem_valid_in2;

  // end



  // fetch neighbors for vertex
  // message_router #( .PROC_BITS(4),  .DATA_SIZE(32),  .PROC_ID(4'b0000)) neigh_port1 (
  //   .clk_in(clk_in),
  //   .rst_in(rst_in),
  //   .addr_req_in(mem_req_out2),
  //   .data_route_in(mem_data_in),
  //   .valid_in(mem_valid_in),
  //   .req_ready_in(req_ready_n),
  //   .valid_req_out(mem_valid_out),
  //   .valid_route_out(neigh_ready),
  //   .msg_out(mem_req_out),
  //   .data_route_out(mem_data_in2)
  // );

  // FIFO for outputting neighbor values
  // add neighbor if valid and not 0
  FIFO#(.DATA_WIDTH(32),.DEPTH(4)) neighbors (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .deq_in(neigh_deq_in),
        .enq_data_in(mem_data_in2),
        .enq_in(visited_val_returned_valid_in&&(~visited_val_returned_in)&&(mem_data_in2!=0)), // mem_valid_in
        .full_out(neigh_full_out),
        .data_out(neigh_fifo_out),
        .valid_out(neigh_valid_out),
        .empty_out(neigh_empty_out)
  );


  // FIFO for outputting position vector values
  // add position if valid and haven't added all dimensions yet
  FIFO#(.DATA_WIDTH(32),.DEPTH(DIM<<2)) position (
      .clk_in(clk_in),
      .rst_in(rst_in),
      .deq_in(pos_deq_in),
      .enq_data_in(mem_data_in),
      .enq_in(mem_valid_in&&(ct<DIM)&&(~req_ready_v)), 
      .full_out(pos_full_out),
      .data_out(data_out),
      .valid_out(data_valid_out),
      .empty_out(pos_empty_out)
  );


  // fetch data values for vertex
  // message_router #( .PROC_BITS(4),  .DATA_SIZE(32),  .PROC_ID(4'b0001)) data_port2 (
  //   .clk_in(clk_in),
  //   .rst_in(rst_in),
  //   .addr_req_in(mem_req_out),
  //   .data_route_in(mem_data_in2),
  //   .valid_in(mem_valid_in2),
  //   .req_ready_in(mem_valid_out),
  //   .valid_req_out(mem_valid_out2),
  //   .valid_route_out(data_ready),
  //   .msg_out(mem_req_out2),
  //   .data_route_out(mem_data_in)
  // );

  // always_comb begin
  //   data_valid_out[ct] = mem_valid_in;
  //   data_out[ct] = mem_data_in;

  // end


    // graph_memory #(parameter DIM = 2)(
    // input wire clk_in,
    // input wire rst_in,
    // input wire [4:0] tag,
    // input wire [31:0] rowidx_addr,
    // input wire [31:0] data_addr,
    // output logic [31:0] rowidx_out,
    // output logic [31:0] data_out,
    // output logic data_valid_out,
    // output logic rowidx_valid_out
    // );
    

    logic req_ready_v;


    always_ff @( posedge clk_in ) begin
      if (rst_in) begin
        ct <= 0;
        
        mem_valid_out <= 1'b0;
        mem_valid_out2 <= 1'b0;

        req_ready_n <= 1'b0;
        req_ready_d <=1'b0;
        req_ready_v <= 1'b0;

        reached_neigh_end_out <= 1'b0;
      end else begin
        if (valid_in) begin
          mem_req_out2 <= v_addr_in + 1 + DIM;
          mem_valid_out2 <= 1'b1;
          // mem_valid_out <= 1;
          req_ready_n <= 1'b0;
          req_ready_d <= 1'b0;
          req_ready_v <= 1'b0;
          ct <= 0;
          
          reached_neigh_end_out <= 1'b0;
        end
        else begin
          // find vertex id
          if(mem_data_in2 != 0 && mem_valid_in2) begin
            mem_req_out <= mem_data_in2;
            mem_valid_out <= 1'b1;
            req_ready_v <= 1'b1;
          end    

          // check if visited using vertex id
          else if (req_ready_v && mem_valid_in) begin
            // mem_req_out <= mem_data_in2 + 1;
            mem_valid_out <= 1'b0;
            visited_req_out <= mem_data_in;
            visited_req_valid_out <= 1'b1;
          
          // received visited result
          end else if (req_ready_v && visited_val_returned_valid_in) begin
            // if not visited, find data
            if (~visited_val_returned_in) begin
              req_ready_d <= 1'b1;
            
            // if visited, go to next neighbor
            end else begin
              req_ready_n <= 1'b1;
              req_ready_v <= 1'b0;
              // mem_req_out <= mem_req_out + 1;
              // mem_valid_out <= 1'b1;
              // req_ready_v <= 1'b1;
            end
          end

          // if just retrieved position and haven't read all positions yet
          else if (req_ready_d && ~req_ready_v && mem_req_out <= mem_data_in2 + DIM-1) begin
            mem_req_out <= mem_req_out + 1;
            mem_valid_out <= 1'b1;
          end 
          // retrieve first position
          else if (req_ready_d && req_ready_v) begin
            req_ready_v <= 1'b0;
            mem_req_out <= mem_data_in2 + 1;
            mem_valid_out <= 1'b1;
          end
          else begin
            mem_valid_out <= 1'b0;
            req_ready_d <= 1'b0;
            visited_req_valid_out <= 1'b0;
          end
          

          // && !neigh_full_out
          // if more neighbors left and just retrieved neighbor
          if (mem_data_in2 != 0 && ct>=(DIM-1)) begin 
            if (neigh_full_out) req_ready_n <= 1'b1;
            else begin
              mem_valid_out2 <= 1'b1;
              mem_req_out2 <= mem_req_out2 + 1;
            end
          end 
          // if neighbor fifo is full, stall retrieving from BRAM
          else if (req_ready_n && ~neigh_full_out) begin 
            mem_req_out2 <= mem_req_out2 + 1;
            mem_valid_out2 <= 1'b1;
            req_ready_n <= 1'b0;
          end
          else begin
            if (~neigh_full_out && ~req_ready_v) req_ready_n <= 1'b0; 
            mem_valid_out2 <= 1'b0;
          end
          // else req_ready_n <= 1'b0;
          
          // if end of neighbors
          if (mem_valid_in2 && mem_data_in2 == 0) reached_neigh_end_out <= 1'b1;
          else if (mem_data_in2 != 0) reached_neigh_end_out <= 1'b0;
        

          // if (data_ready) ct <= ct +1;
          // count for number of dimensions retrieved
          if (mem_valid_in && ~pos_full_out && ~req_ready_v) begin
            ct <= (ct>=DIM-1) ? 0 : ct+1;
          end
        end
      end
      
    end


endmodule

`default_nettype wire