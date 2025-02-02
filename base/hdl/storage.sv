`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"data/X`"
`endif  /* ! SYNTHESIS */


module graph_memory #(parameter DIM = 2, parameter PROC_BITS = 4)(
  input wire clk_in,
  input wire rst_in,
  input wire [31+PROC_BITS:0] idx_addr,
  input wire idx_validin,
  input wire [31+PROC_BITS:0] data_addra_in,
  input wire [31+PROC_BITS:0] data_addrb_in,
  input wire data_validina,
  input wire data_validinb,
  output logic [31:0] rowidx_out,
  output logic [31:0] data_outa,
  output logic [31:0] data_outb,
  // output logic [31:0] data_outc,
  output logic data_valid_outa,
  output logic data_valid_outb,
  output logic rowidx_valid_out
  );




  logic [31:0] addra;
  logic [31:0] addrb;
  logic [31:0] addrc;

  logic [1:0] cta;
  logic ctb;
  logic [1:0] ctc;

  always_ff @( posedge clk_in) begin 
    if (rst_in) begin
      cta <= 0;
      ctb <= 0;
      ctb <= 0;
    end
    // if (data_validina) cta <= 0;
    // else cta <= cta+1;
    // if (data_validinb) ctb <= 0;
    // else ctb <= ctb+1;


    // count 2 cycles to get BRAM values
    if (data_validina) begin
      cta <= 1;
      data_valid_outa <= 0;
    end
    else begin
      cta <= 0;
      
    end

      if (cta) begin
        data_valid_outa <= 1;
        // data_outa <= 1;
        if (!data_validina)
          cta <= 0;
      end else data_valid_outa <= 0;

    if (data_validinb) begin
      ctb <= 1;
      data_valid_outb <= 0;
    end
    else begin
      ctb <= 0;

    end
      if (ctb) begin 
        data_valid_outb <= 1;
        if (!data_validinb) ctb <= 0;
      end else data_valid_outb <= 0;
    // if (cta == 2) data_valid_outa <= 1;
    // else data_valid_outa <= 0;
    // if (ctb == 2) data_valid_outb <= 1;
    // else data_valid_outb <= 0;


    if (idx_validin) begin
      ctc <= 1;
      rowidx_valid_out <= 0;
    end 
    else ctc <= 0;

    if (ctc) begin
      rowidx_valid_out <= 1;
      if (!idx_validin) ctc <= 0;
    end else rowidx_valid_out <= 0;
  end

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(32),                       // Specify RAM data width
    .RAM_DEPTH(16384),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE(`FPATH(samples/citeseer_4/out_addrs.mem))                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) data_mem (
    .addra(data_addra_in[13:0]),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(data_addrb_in[13:0]),   // Port B address bus, width determined from RAM_DEPTH
    .dina(0),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(0),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),     // Port A clock
    .clkb(clk_in),     // Port B clock
    .wea(1'b0),       // Port A write enable
    .web(1'b0),       // Port B write enable
    .ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),     // Port A output reset (does not affect memory contents)
    .rstb(rst_in),     // Port B output reset (does not affect memory contents)
    .regcea(1'b1), // Port A output register enable
    .regceb(1'b1), // Port B output register enable
    .douta(data_outa),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(data_outb)    // Port B RAM output data, width determined from RAM_WIDTH
  );

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(32),                       // Specify RAM data width
    .RAM_DEPTH(4096),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(samples/citeseer_4/out_vidx.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) ptr_mem (
    .addra(idx_addr[11:0]),     // Address bus, width determined from RAM_DEPTH
    .dina(0),       // RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
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
