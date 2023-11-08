`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module graph_memory #(parameter DIM = 2, parameter PROC_BITS = 4)(
  input wire clk_in,
  input wire rst_in,
  input wire [31+PROC_BITS:0] idx_addr,
  input wire idx_validin,
  input wire [31+PROC_BITS:0] data_addra,
  input wire [31+PROC_BITS:0] data_addrb,
  input wire data_validina,
  input wire data_validinb,
  output logic [31:0] rowidx_out,
  output logic [31:0] data_outa,
  output logic [31:0] data_outb,
  output logic [31:0] data_outc,
  output logic data_valid_outa,
  output logic data_valid_outb,
  output logic rowidx_valid_out
  );




  logic [31:0] addra;
  logic [31:0] addrb;
  logic [31:0] addrc;

  logic [1:0] cta;
  logic [1:0] ctb;
  logic [1:0] ctc;

  always_ff @( posedge clk_in) begin 
    if (rst_in) begin
      cta <= 0;
      ctb <= 0;
      ctb <= 0;
    end
    if (data_validina) cta <= 0;
    else cta <= cta+1;
    if (data_validinb) ctb <= 0;
    else ctb <= ctb+1;
    if (idx_validin) ctc <= 0;
    else ctc <= ctc+1;

    if (cta == 2) data_valid_outa <= 1;
    else data_valid_outa <= 0;
    if (ctb == 2) data_valid_outb <= 1;
    else data_valid_ouba <= 0;
    if (ctc == 2) rowidx_valid_out <= 1;
    else rowidx_valid_out <= 0;
  end

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(32),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("out_addrs.mem")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) data_mem (
    .addra(data_addra),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(data_addrb),   // Port B address bus, width determined from RAM_DEPTH
    .dina(0),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(0),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),     // Port A clock
    .clkb(clk_in),     // Port B clock
    .wea(0),       // Port A write enable
    .web(0),       // Port B write enable
    .ena(1),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),     // Port A output reset (does not affect memory contents)
    .rstb(rst_in),     // Port B output reset (does not affect memory contents)
    .regcea(1), // Port A output register enable
    .regceb(1), // Port B output register enable
    .douta(data_outa),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(data_outb)    // Port B RAM output data, width determined from RAM_WIDTH
  );

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(32),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(out_ids.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) ptr_mem (
    .addra(idx_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(0),       // RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),       // Clock
    .wea(0),         // Write enable
    .ena(1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1),   // Output register enable
    .douta(rowidx_out)      // RAM output data, width determined from RAM_WIDTH
  );


endmodule

`default_nettype wire


    // FIFO#(.DATA_WIDTH(32),.DEPTH(8)) data_pta_res (
    //     .clk_in(clk_in),
    //     .rst_in(rst_in),
    //     .deq,
    //     .enq_data,
    //     .enq,
    //     .full,
    //     .data_out,
    //     .empty
    // );
    // FIFO#(.DATA_WIDTH(PROC_BITS),.DEPTH(8)) data_pta_proc (
    //     .clk_in(clk_in),
    //     .rst_in(rst_in),
    //     .deq,
    //     .enq_data,
    //     .enq,
    //     .full,
    //     .data_out,
    //     .empty
    // );

    //   FIFO#(.DATA_WIDTH(32),.DEPTH(8)) data_ptb_res (
    //     .clk_in(clk_in),
    //     .rst_in(rst_in),
    //     .deq,
    //     .enq_data,
    //     .enq,
    //     .full,
    //     .data_out,
    //     .empty
    // );
    // FIFO#(.DATA_WIDTH(PROC_BITS),.DEPTH(8)) data_ptb_proc(
    //     .clk_in(clk_in),
    //     .rst_in(rst_in),
    //     .deq,
    //     .enq_data,
    //     .enq,
    //     .full,
    //     .data_out,
    //     .empty
    // );   
    
    // FIFO#(.DATA_WIDTH(32),.DEPTH(8))vidx_pta_res(
    //     .clk_in(clk_in),
    //     .rst_in(rst_in),
    //     .deq,
    //     .enq_data,
    //     .enq,
    //     .full,
    //     .data_out,
    //     .empty
    // );
    // FIFO#(.DATA_WIDTH(PROC_BITS),.DEPTH(8)) vidx_pta_proc(
    //     .clk_in(clk_in),
    //     .rst_in(rst_in),
    //     .deq,
    //     .enq_data,
    //     .enq,
    //     .full,
    //     .data_out,
    //     .empty
    // );
