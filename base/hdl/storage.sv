`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module graph_memory #(parameter DIM = 2)(
  input wire clk_in,
  input wire rst_in,
  input wire [4:0] tag,
  input wire [31:0] rowidx_addr,
  input wire [31:0] data_addr,
  output logic [31:0] rowidx_out,
  output logic [31:0] data_out,
  output logic data_valid_out,
  output logic rowidx_valid_out
  );


    FIFO#(.DATA_WIDTH(32+5),.DEPTH(8))(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .deq,
        .enq_data,
        .enq,
        .full,
        .data_out,
        .empty
    );

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(8),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH*HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(image.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) image_ram (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(0),         // Write enable
    .ena(1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1),   // Output register enable
    .douta(douta_img)      // RAM output data, width determined from RAM_WIDTH
  );

  assign addra_pal = douta_img;

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(24),                       // Specify RAM data width
    .RAM_DEPTH(256),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(palette.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) palette_ram (
    .addra(addra_pal),     // Address bus, width determined from RAM_DEPTH
    .dina(0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(0),         // Write enable
    .ena(1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1),   // Output register enable
    .douta(douta_pal)      // RAM output data, width determined from RAM_WIDTH
  );


endmodule

`default_nettype wire