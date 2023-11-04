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

  logic [2:0] state; // for distance calc FSM, 3 states

  logic [31:0] intermediate_subs_out [DIM-1:0], intermediate_mults_out [DIM-1:0], distance;
  logic valid_subs_out [DIM-1:0], valid_mults_out [DIM-1:0], valid_add_out;

  logic [0:$clog2(DIM)-1] i; // index into array for subtraction
  logic [0:$clog2(DIM)-1] j; // index into array for multiplication


  // state machine for distance calc
  always_ff @ (posedge clk_in) begin
    if (rst_in) begin
        state <= 0;
        i <= 0;
    end
    else if (state==2'b0) begin
        // data_valid_out <= 1'b0;
        // distance_sq_out <= 0;

        // subtraction (q_i - p_i) one substraction per cycle
        if (data_valid_in[i]) begin
            intermediate_subs_out[i] = query_pos_in[i] - vertex_pos_in[i]; 
            valid_subs_out[i] <= 1'b1;
            
            // increment indexing counter
            if (i>=(DIM-1)) i <= 0;
            else i <= i + 1;

            j <= i; // update mul indexing counter
            
        end

        // if last subtraction is complete, move to next state
        // if (valid_subs_out[DIM-1]==1'b1) begin
        //     state <= 2'b1;
        //     valid_subs_out[DIM-1] <= 0;
        // end

        // find square of difference if subtraction complete
        if (valid_subs_out[j]) begin
            intermediate_mults_out[j] = intermediate_subs_out[j]*intermediate_subs_out[j];
            valid_mults_out[j] <= 1'b1;

            // reset valid bit when complete
            valid_subs_out[j] <= 1'b0;

            if (j>=(DIM-1)) j <= 0;
        end
            
        // move to next state if all multiplications are complete
        if (valid_mults_out[DIM-1]==1'b1) begin
            state <= 2'b1;
            valid_mults_out[DIM-1] <= 1'b0;
        end
    end

    // multiplication (square difference), one multiplication per cycle
    // else if (state==2'b1) begin
    //     if (intermediate_subs_out[i]) begin
    //         intermediate_mults_out[i] = intermediate_subs_out[i]*intermediate_subs_out[i];
    //         valid_mults_out[i] <= 1'b1;
            
    //         // increment indexing counter
    //         if (i>=(DIM-1)) i <= 0;
    //         else i <= i + 1;
            
    //         if (valid_mults_out[DIM-1]==1'b1) state <= 2'b10;

    //     end
    // end

    // recursively add squares of differences
    else if (state==2'b1) begin
        if (data_valid_out) state <= 2'b0; 
        // if(valid_add_out) begin
        //     data_valid_out <= 1'b1;
        //     distance_sq_out <= distance;
        //     state <= 2'b0;
        // end
    end

 end

 // use recursive addition module
 recursive_add_n_dim  #(
    .DIM(DIM)
    ) add_distances(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .data_valid_in((state==2'b1)),
        .intermediate_mults_in(intermediate_mults_out),
        .distance_sq_out(distance_sq_out),
        .data_valid_out(data_valid_out)
    );
 
endmodule


// recursive addition module 
module recursive_add_n_dim # (parameter DIM = 1)(
  input wire clk_in,
  input wire rst_in,
  input wire data_valid_in,
  input wire [31:0] intermediate_mults_in [DIM-1:0],
  output logic [31:0] distance_sq_out,
  output logic data_valid_out
);

  generate 
    // base case 1 (DIM=1): return square of difference
    if (DIM==1) begin
      always_ff @ (posedge clk_in) begin
        if (rst_in) begin
            distance_sq_out <= 0;
            data_valid_out <= 1'b0;
        end
        else if (data_valid_in) begin
          distance_sq_out <= intermediate_mults_in[0];
          data_valid_out <= 1;

        end 
        else data_valid_out <= 1'b0;

      end
    end

    // base case 2 (DIM=2): return sum of squares of differences
    else if (DIM==2) begin
      always_ff @ (posedge clk_in) begin
        if (rst_in) begin
            distance_sq_out <= 0;
            data_valid_out <= 1'b0;
        end
        if (data_valid_in) begin
          distance_sq_out = intermediate_mults_in[1] + intermediate_mults_in[0];
          data_valid_out <= 1;
        end
         else data_valid_out <= 1'b0;
      end
    end

    // otherwise, recursively add values
    else begin
      logic [31:0] distance1, distance2, total_distance;
      logic add_valid1, add_valid2;
      
      // recursively add first half of values
      recursive_add_n_dim # (
        .DIM(DIM/2)
      ) adder1 (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .data_valid_in(data_valid_in),
        .intermediate_mults_in(intermediate_mults_in[DIM/2-1:0]),
        .distance_sq_out(distance1),
        .data_valid_out(add_valid1)
      );

      // recursively second half of values
      recursive_add_n_dim # (
        .DIM(DIM-(DIM/2))
      ) adder2 (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .data_valid_in(data_valid_in),
        .intermediate_mults_in(intermediate_mults_in[DIM-1:DIM/2]),
        .distance_sq_out(distance2),
        .data_valid_out(add_valid2)
      );

      // add outputs of recursive modules
      always_ff @ (posedge clk_in) begin
        if (add_valid1 && add_valid2) begin
          distance_sq_out = distance1+distance2;
          data_valid_out = 1'b1;      
        end else begin
          distance_sq_out = 0;
          data_valid_out = 1'b0;      
        end
      end
    end
  endgenerate
endmodule

`default_nettype wire