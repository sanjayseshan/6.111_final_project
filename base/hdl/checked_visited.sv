`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"data/X`"
`endif  /* ! SYNTHESIS */

module checked_visited #(parameter PROC_BITS = 4) (
    input wire clk_in,
    input wire rst_in,
    input wire [31+PROC_BITS:0] c_addr_in,
    input wire [31+PROC_BITS:0] v_addr_in,
    input wire c_addr_valid_in,
    input wire v_addr_valid_in,
    input wire write_c_data_in,
    input wire write_c_valid_in,
    input wire write_v_data_in,
    input wire write_v_valid_in,
    output logic checked_out,
    output logic visited_out,
    output logic valid_c_out,
    output logic valid_v_out
);

logic counter;

always_ff @ (posedge clk_in) begin
    if (rst_in) begin
        valid_c_out <= 1'b0;
    end
    else begin
        if (c_addr_valid_in) begin
            counter <= 1'b1;
            valid_c_out <= 1'b0;
        end
        else if (counter) begin
            counter <= 1'b0;
            valid_c_out <= 1'b1;
        end
        else begin
            valid_c_out <= 1'b0;
        end
    end
end

logic counter2;

always_ff @ (posedge clk_in) begin
    if (rst_in) begin
        valid_v_out <= 1'b0;
    end
    else begin
        if (c_addr_valid_in) begin
            counter2 <= 1'b1;
            valid_v_out <= 1'b0;
        end
        else if (counter2) begin
            counter2 <= 1'b0;
            valid_v_out <= 1'b1;
        end
        else begin
            valid_v_out <= 1'b0;
        end
    end
end


// INSERT FILE WITH INITIALIZED 0s

 xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(1),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(empty.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
 ) bram_3 (
    .addra(c_addr_in[9:0]),     // Address bus, width determined from RAM_DEPTH
    .dina(write_c_data_in),       // RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),       // Clock
    .wea(write_c_valid_in),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(checked_out)      // RAM output data, width determined from RAM_WIDTH
  );

 xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(2),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(empty.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
 ) bram_3 (
    .addra(v_addr_in[9:0]),     // Address bus, width determined from RAM_DEPTH
    .dina(write_v_data_in),       // RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),       // Clock
    .wea(write_v_valid_in),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(visited_out)      // RAM output data, width determined from RAM_WIDTH
  );

endmodule


`default_nettype wire



// checked_visited #(.PROC_BITS(4)) bram_3m (
//     .clk_in(clk_in),
//     .rst_in(rst_in),
//     .idx_addr_in(),  // vertex addr for retrieving checked/visited
//     .idx_valid_in(), // valid input for reading/writing
//     .write_data_in(), // write data, doesn't matter if reading
//     .write_valid_in(), // 1 = write, 0 = read (don't write)
//     .bram3_out(), // 2 bit output from BRAM, 1st bit is checked, 0th is visited
//     .valid_out() // valid output from BRAM
// ); 