// `timescale 1ns / 1ps
// `default_nettype none // prevents system from inferring an undeclared logic (good practice)

// `ifdef SYNTHESIS
// `define FPATH(X) `"X`"
// `else /* ! SYNTHESIS */
// `define FPATH(X) `"data/X`"
// `endif  /* ! SYNTHESIS */


// module cache #(parameter DIM = 8, parameter PROC_BITS = 0)(
//   input wire clk_in,
//   input wire rst_in,
//   input wire [31:0] addr,
//   input wire addr_validin,
//   output logic [31:0] val_out,
//   output logic valid_out
//   );


//  mainmem #(.DIM(DIM),  .PROC_BITS(0)) mm (
//   input wire clk_in,
//   input wire rst_in,
//   input wire [31:0] addr,
//   input wire addr_validin,
//   output logic [31:0] val_out,
//   output logic addr_validin
//   );

//   logic [31:0] cache_out;

//   logic [1:0] cta;
//   logic ctb;
//   logic [1:0] ctc;

//   logic [21:0] tag;
//   logic [9:0] index;
//   logic [1:0] offset;

//   always_comb begin
//     if (addr_validin) begin
//       tag = addr[31:12];
//       index = addr[11:2];
//       offset = addr[1:0];
//     end
//   end

//   logic [31:0] working_addr;


//   always_ff @( posedge clk_in) begin 
//     if (rst_in) begin
//       cta <= 0;
//     end
//     // if (data_validina) cta <= 0;
//     // else cta <= cta+1;
//     // if (data_validinb) ctb <= 0;
//     // else ctb <= ctb+1;


//     // count 2 cycles to get BRAM values
//     if (addr_validin) begin
//       cta <= 1;
//       data_valid_outa <= 0;
//       working_addr <= addr;
//     end
//     else begin
//       cta <= 0;
//     end

//     if (cta) begin
//       valid_out <= 1;
//       // data_outa <= 1;
//       if (!addr_validin)
//           cta <= 0;
//     end else valid_out <= 0;

//   end


//   xilinx_single_port_ram_read_first #(
//     .RAM_WIDTH(32),                       // Specify RAM data width
//     .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
//     .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
//     // .INIT_FILE(`FPATH(out_ids2.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
//   ) ptr_mem (
//     .addra(index),     // Address bus, width determined from RAM_DEPTH
//     .dina(0),       // RAM input data, width determined from RAM_WIDTH
//     .clka(clk_in),       // Clock
//     .wea(1'b0),         // Write enable
//     .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
//     .rsta(rst_in),       // Output reset (does not affect memory contents)
//     .regcea(1'b1),   // Output register enable
//     .douta(cache_out)      // RAM output data, width determined from RAM_WIDTH
//   );


// endmodule

// `default_nettype wire


//     // FIFO#(.DATA_WIDTH(32),.DEPTH(8)) data_pta_res (
//     //     .clk_in(clk_in),
//     //     .rst_in(rst_in),
//     //     .deq,
//     //     .enq_data,
//     //     .enq,
//     //     .full,
//     //     .data_out,
//     //     .empty
//     // );
//     // FIFO#(.DATA_WIDTH(PROC_BITS),.DEPTH(8)) data_pta_proc (
//     //     .clk_in(clk_in),
//     //     .rst_in(rst_in),
//     //     .deq,
//     //     .enq_data,
//     //     .enq,
//     //     .full,
//     //     .data_out,
//     //     .empty
//     // );

//     //   FIFO#(.DATA_WIDTH(32),.DEPTH(8)) data_ptb_res (
//     //     .clk_in(clk_in),
//     //     .rst_in(rst_in),
//     //     .deq,
//     //     .enq_data,
//     //     .enq,
//     //     .full,
//     //     .data_out,
//     //     .empty
//     // );
//     // FIFO#(.DATA_WIDTH(PROC_BITS),.DEPTH(8)) data_ptb_proc(
//     //     .clk_in(clk_in),
//     //     .rst_in(rst_in),
//     //     .deq,
//     //     .enq_data,
//     //     .enq,
//     //     .full,
//     //     .data_out,
//     //     .empty
//     // );   
    
//     // FIFO#(.DATA_WIDTH(32),.DEPTH(8))vidx_pta_res(
//     //     .clk_in(clk_in),
//     //     .rst_in(rst_in),
//     //     .deq,
//     //     .enq_data,
//     //     .enq,
//     //     .full,
//     //     .data_out,
//     //     .empty
//     // );
//     // FIFO#(.DATA_WIDTH(PROC_BITS),.DEPTH(8)) vidx_pta_proc(
//     //     .clk_in(clk_in),
//     //     .rst_in(rst_in),
//     //     .deq,
//     //     .enq_data,
//     //     .enq,
//     //     .full,
//     //     .data_out,
//     //     .empty
//     // );
