`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"data/X`"
`endif  /* ! SYNTHESIS */


module cache #(parameter DIM = 8, parameter PROC_BITS = 0)(
  input wire clk_in,
  input wire rst_in,
  input wire [31:0] addr,
  input wire addr_validin,
  output logic [31:0] val_out,
  output logic valid_out
  );


 mainmem #(.DIM(DIM),  .PROC_BITS(0)) mm (
  .clk_in(clk_in),
  .rst_in(rst_in),
  .addr(mm_addr),
  .addr_validin(mm_addr_vin),
  .val_out(mm_out),
  .valid_out(mm_out_v)
  );

  logic [31:0] cache_out;

  logic [1:0] cta;
  logic ctb;
  logic [1:0] ctc;

  logic [21:0] tag;
  logic [9:0] index;
  logic [1:0] offset;

//   always_comb begin

//   end

  logic [31:0] working_addr;


  always_ff @( posedge clk_in) begin 
    if (rst_in) begin
      cta <= 0;
    end
    // if (data_validina) cta <= 0;
    // else cta <= cta+1;
    // if (data_validinb) ctb <= 0;
    // else ctb <= ctb+1;


    // count 2 cycles to get BRAM values
    if (addr_validin) begin
      cta <= 1;
      data_valid_outa <= 0;
      working_addr <= addr;

      tag <= addr[31:12];
      index <= addr[11:2];
      offset <= addr[1:0];
    end
    else begin
      cta <= 0;
    end

    if (cta) begin
      valid_out_temp <= 1;
      // data_outa <= 1;
      if (!addr_validin)
          cta <= 0;
    end else valid_out_temp <= 0;

    if (valid_out_temp) begin
        if (cache_out[32*4]==1) begin
            valid_out <= 1;
            val_out <= cache_out[32*offset+32:32*offset];
        end else begin
            mm_addr <= index;
            mm_addr_vin <= 1;
        end

    end

    if (mm_out_v) begin
        din<={1,mm_out};
        addrb <= index;
        valid_out <= 1;
        val_out <= mm_out[32*offset+32:32*offset];
    end

  end



  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(32*4+1),                       // Specify RAM data width
    .RAM_DEPTH(16384),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE(`FPATH(samples/tester_8/out_addrs.mem))                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) data_mem (
    .addra(addr[11:2]),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(addrb),   // Port B address bus, width determined from RAM_DEPTH
    .dina(0),     // Port A RAM input data, width determined from RAM_WIDTH4
    .dinb(din),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),     // Port A clock
    .clkb(clk_in),     // Port B clock
    .wea(1'b0),       // Port A write enable
    .web(1'b1),       // Port B write enable
    .ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),     // Port A output reset (does not affect memory contents)
    .rstb(rst_in),     // Port B output reset (does not affect memory contents)
    .regcea(1'b1), // Port A output register enable
    .regceb(1'b1), // Port B output register enable
    .douta(cache_out),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(data_outb)    // Port B RAM output data, width determined from RAM_WIDTH
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
