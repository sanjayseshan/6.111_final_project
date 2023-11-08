`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module graph_fetch #(parameter DIM = 2)(
  input wire clk_in,
  input wire rst_in,
  input wire [31:0] v_addr,
  output wire ready,
  output logic [31:0] neigh_out_fifo,
  output logic [31:0] data_out [DIM:0],
  output logic data_valid_out [DIM:0],
  input wire neigh_deq,
  output logic neigh_valid_out,

  output logic neigh_full,
  output logic neigh_empty,

  input wire mem_valid_in,
  input wire mem_data_in,
  output logic mem_valid_out,
  output logic [31+4:0] mem_req_out,

  input wire mem_valid_in2,
  input wire mem_data_in2,
  output logic mem_valid_out2,
  output logic [31+4:0] mem_req_out2
  );

  logic [31:0] read_addr_neigh;
  logic [31:0] read_addr_data;

  logic neigh_ready;
  logic data_ready;

  logic [$clog2(DIM)+1:0] ct;


  logic req_ready_n;
  logic req_ready_d;

  message_router #( PROC_BITS = 4,  DATA_SIZE = 32,  PROC_ID=4'b0000) neigh_port1 (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .addr_req(read_addr_neigh),
    .data_route_in(mem_data_in),
    .valid_in(mem_valid_in),
    .req_ready_in(req_ready_n),
    .valid_req_out(mem_valid_out),
    .valid_out_route(neigh_ready),
    .msg_out(mem_req_out),
    .data_route_out(neigh_out)
  );

  FIFO#(.DATA_WIDTH(32),.DEPTH(8)) neighbors (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .deq(neigh_deq),
        .enq_data(neigh_out),
        .enq(mem_valid_in),
        .full(neigh_full),
        .data_out(neigh_out_fifo),
        .valid_out(neigh_valid_out),
        .empty(neigh_empty)
  );

  message_router #( PROC_BITS = 4,  DATA_SIZE = 32,  PROC_ID=4'b0001) data_port2 (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .addr_req(read_addr_data),
    .data_route_in(mem_data_in2),
    .valid_in(mem_valid_in2),
    .req_ready_in(req_ready_d),
    .valid_req_out(mem_valid_out2),
    .valid_out_route(data_ready),
    .msg_out(mem_req_out2),
    .data_route_out(data_out[ct])
  );

  always_comb begin
    data_valid_out[ct] = mem_valid_in;

  end


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
    




    always_ff @( posedge clk_in ) begin
      if (rst_in) begin
        ready <= 1;
        ct <= 0;
        req_ready_d <= 0;
        req_ready_n <= 0;
      end else begin
        if (valid_in) begin
          read_addr_data <= v_addr + 1;
          read_addr_neigh <= v_addr + 1 + DIM;
        end

        if (read_addr_data != v_addr +1+DIM ) begin
          read_addr_data <= read_addr_data + 1;
          req_ready_d <= 1;
        end else req_ready_d <= 0;
        
        if (neigh_out != 0 && !neigh_full) begin 
          read_addr_neigh <= read_addr_neigh + 1;
          req_ready_n <= 1;
        end else req_ready_n <= 0;
        
      
        if (data_ready) ct <= ct +1;
      end
      
    end


endmodule

`default_nettype wire