`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module graph_fetch #(parameter DIM = 2)(
  input wire clk_in,
  input wire rst_in,
  input wire [31:0] v_addr,
  output wire ready,
  output logic [31:0] rowidx_out,
  output logic [31:0] data_out [DIM:0],
  output logic data_valid_out,
  output logic rowidx_valid_out
  );

  message_router #( PROC_BITS = 4,  DATA_SIZE = 32,  PROC_ID=4'b0000) neigh_port1 (
    .clk_in,
    .rst_in,
    .addr_req(read_addr_neigh),
    .data_route_in,
    .valid_in,
    .req_ready_out,
    .valid_out,
    .data_route_out
  );
  message_router #( PROC_BITS = 4,  DATA_SIZE = 32,  PROC_ID=4'b0000) data_port2 (
    .clk_in,
    .rst_in,
    .addr_req(read_addr_data),
    .data_route_in,
    .valid_in,
    .req_ready_out,
    .valid_out,
    .data_route_out
  );


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
    
    // FIFO#(.DATA_WIDTH(32+5),.DEPTH(8))(
    //     .clk_in(clk_in),
    //     .rst_in(rst_in),
    //     .deq,
    //     .enq_data,
    //     .enq,
    //     .full,
    //     .data_out,
    //     .empty
    // );

    logic [31:0] read_addr_neigh;
    logic [31:0] read_addr_data;
    logic [$clog2(DIM):0] ct;

    always_ff @( posedge clk_in ) begin
      if (rst_in) begin
        ready <= 1;
        ct <= 0;
      end else begin
        if (valid_in) begin
          read_addr_data <= v_addr + 1;
          read_addr_neigh <= v_addr + 1 + DIM;
        end

        if (read_addr_data != v_addr +1+DIM) read_addr_data <= read_addr_data + 1;
        if (neigh_data_route_out != 0) read_addr_neigh <= read_addr_neigh + 1;
        
      end
    end


endmodule

`default_nettype wire