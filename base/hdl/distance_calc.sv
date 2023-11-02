`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module distance #(parameter DIM = 2)(
  input wire clk_in,
  input wire rst_in,
  input wire data_valid_in [DIM-1:0],
  input wire [31:0] vertex_pos_in [DIM-1:0],
  input wire [31:0] query_pos_in [DIM-1:0],
  output logic [31:0] distance_sq_out,
  output logic data_valid_out
  );

  logic [2:0] state;

  logic [31:0] intermediate_subs_out [DIM-1:0];
  logic valid_subs_out [DIM-1:0];


  logic [0:$clog2(DIM)-1] i;

  
  always_ff @ (posedge clk_in) begin
    if (rst_in) begin
        distance_sq_out <= 0;
        data_valid_out <= 1'b0;
    end
    else if (state==3'b0) begin
        if (data_valid_in[i]) begin
            intermediate_subs_out[i] = (vertex_pos_in[i] < query_pos_in[i]) ? query_pos_in[i] + ~(vertex_pos_in[i]) + 1 : vertex_pos_in[i] + ~(query_pos_in[i]) + 1;
            valid_subs_out[i] <= 1'b1;
            
            if (i>=(DIM-1)) begin
                i <= 0;
            end
            else i <= i + 1;
            
            if (valid_subs_out[DIM-1]==1'b1) begin
                state <= 3'b1;
            end
            data_valid_out <= 1'b0;
        end
    end
    else if (state==3'b1) begin
        state <= 3'b1;
    end

 end
 
//  calculate_sub #(.DIM(DIM)) sub (
//     .clk_in(clk_in),
//     .rst_in(rst_in),
//     .data_valid_in(data_valid_in[i]),
//     .state(state),
//     .vertex_pos_in(vertex_pos_in[i]),
//     .query_pos_in(query_pos_in[i]),
//     .intermediate_subs_out(intermediate_subs_out[i]),
//     .data_valid_out(valid_subs_out[i])
//     );


endmodule



// module calculate_sub #(parameter DIM=2) (
//   input wire clk_in,
//   input wire rst_in,
//   input wire data_valid_in,
//   input wire [2:0] state,
//   input wire [31:0] vertex_pos_in,
//   input wire [31:0] query_pos_in,
//   output logic [31:0] intermediate_subs_out,
//   output logic data_valid_out
//   );

// //   logic [0:$clog2(DIM)-1] i;
 
//   always_ff @ (posedge clk_in) begin
//     if (rst_in) begin
//         intermediate_subs_out <= 0;
//         data_valid_out <= 1'b0;
//     end
//     if (data_valid_in && state==3'b0) begin
//         intermediate_subs_out = (vertex_pos_in < query_pos_in) ? query_pos_in + ~(vertex_pos_in) + 1 : vertex_pos_in + ~(query_pos_in) + 1;
    
//         // if (i>=(DIM-1)) begin
//         //     i <= 0;
//         // end
//         // else i <= i + 1;

//         data_valid_out <= 1'b1;
//     end
//   end

// endmodule

`default_nettype wire