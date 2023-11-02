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
  logic [31:0] intermediate_mults_out [DIM-1:0];
  logic valid_subs_out [DIM-1:0], valid_mults_out [DIM-1:0];


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
        if (intermediate_subs_out[i]) begin
            intermediate_mults_out[i] = intermediate_subs_out[i]*intermediate_subs_out[i];
            valid_mults_out[i] <= 1'b1;
            
            if (i>=(DIM-1)) begin
                i <= 0;
            end
            else i <= i + 1;
            
            if (valid_mults_out[DIM-1]==1'b1) begin
                state <= 3'b10;
            end

            data_valid_out <= 1'b0;
        end
        state <= 3'b10;
    end
    else if (state==3'b10) begin
        state <= 3'b10;
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


module recursive_add_n_dim # (parameter DIM = 1)(
  input wire clk_in,
  input wire rst_in,
  input wire data_valid_in,
  input wire [31:0] intermediate_mults_in [DIM-1:0],
  output logic [31:0] distance_sq_out,
  output logic data_valid_out
);

  generate 
    if (DIM==1) begin
      always_ff @ (posedge clk_in) begin
        if (rst_in) begin
            distance_sq_out <= 0;
            data_valid_out <= 1'b0;
        end
        else if (data_valid_in) distance_sq_out <= intermediate_mults_in[0];
      end
    end
    else if (DIM==2) begin
      always_ff @ (posedge clk_in) begin
        if (rst_in) begin
            distance_sq_out <= 0;
            data_valid_out <= 1'b0;
        end
        if (data_valid_in) distance_sq_out = intermediate_mults_in[1] + intermediate_mults_in[0];
      end
    end
    else begin
      logic [31:0] distance1, distance2, total_distance;
      logic add_valid1, add_valid2, added_dist1, added_dist2;
      
      add_n_dimensions # (
        .DIM(DIM >> 1)
      ) adder1 (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .data_valid_in(data_valid_in),
        .intermediate_muls_in(intermediate_mults_in[0:(DIM>>2)]),
        .distance_sq_out(distance1),
        .data_valid_out(add_valid1)
      );

      add_n_dimensions # (
        .DIM(DIM >> 1)
      ) adder2 (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .data_valid_in(data_valid_in),
        .intermediate_muls_in(intermediate_mults_in[(DIM>>2)+1:DIM-1]),
        .distance_sq_out(distance2),
        .data_valid_out(add_valid2)
      );

      always_ff @ (posedge clk_in) begin
        if (rst_in) begin
            total_distance <= 0;
            distance_sq_out <= 0;
            distance_valid_out <= 1'b0;
        end
        else begin
            if (add_valid1) begin
                total_distance <= total_distance + distance1;
                added_dist1 <= 1'b1;
            end
            if (add_valid2) begin
                total_distance <= total_distance + distance2;
                added_dist2 <= 1'b1;
            end

            if (added_dist1 && added_dist2) begin
                data_valid_out <= 1'b1;
                distance_sq_out <= total_distance;

                added_dist1 <= 1'b0;
                added_dist2 <= 1'b0;
            end
        end
      end
    end
  endgenerate
endmodule

`default_nettype wire