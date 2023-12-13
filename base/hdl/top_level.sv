`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module top_level(
  input wire clk_100mhz,
  input wire [15:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  input wire uart_rxd,
  output wire uart_txd,
  output logic [15:0] led //16 green output LEDs (located right above switches)
  );

  parameter DIM=4;
  // assign led = sw; //for debugging
  //shut up those rgb LEDs (active high):
  // assign rgb1= 0;
  // assign rgb0 = 0;

  logic [2:0] state;

  logic sys_rst;
  assign sys_rst = btn[0];

  logic valid_out;

  logic [31:0] vertex_in;
  logic [31:0] query_in [48-1:0];
  logic [31:0] query_in_real [DIM-1:0];
  logic [31:0] top_k_out;

  logic [24:0] new_clk;

  always_ff @( posedge clk_100mhz ) begin 
    if (sys_rst) begin 
      new_clk <= 0;
    end
    else begin
      new_clk <= new_clk + 1;
    end
    
  end

  // assign    query_in_real[0] = 5;
  // assign    query_in_real[1] = 7;
  // assign    query_in_real[2] = 1;
  // assign    query_in_real[3] = 1;
  // assign    query_in_real[4] = 5;
  // assign    query_in_real[5] = 7;
  // assign    query_in_real[6] = 1;
  // assign    query_in_real[7] = 1;
  logic [15:0] k_in;

  // assign k_in = 16'd4;

  logic [4:0] count_in;
  logic [31:0] data_in [DIM:0];
  logic ready;



  logic [31:0] debug, debug2;

  bfis #(.DIM(4), .PQ_LENGTH(5)) main(
  // .clk_in(new_clk[24]),
  .clk_in(clk_100mhz),
  .rst_in(sys_rst),
  .vertex_id_in(1),
  .valid_in(ready),
  .query_in(query_in_real),
  .k_in(k_in),
  .top_k_out(top_k_out),
  .valid_out(valid_out),
  .state(state),
  .debug(debug),
  .debug2(debug2)
  );

  logic [31:0] val_3, last_val_3, buf_k_out;
  logic [31:0] tmp;
  logic [31:0] sig_in;
  logic [31:0] last_sig_in;
  
  logic started_seq;

  always_ff @( posedge clk_100mhz ) begin 
    if (sys_rst) begin 
      count_in <= 0;
      ready <= 0;
      for (int i=0; i<10; i=i+1)
        data_in[i] <= 0;
    end
    else begin
      // if (val_3==1 && (val_3 != last_val_3) && count_in != DIM+2) begin
      //   count_in <= count_in+1;

      if (sig_in == 32'hFFFFFFFF && !started_seq) begin
        started_seq <= 1;
        count_in <= 0;
      end

      last_sig_in <= sig_in;


      if (sig_in == 32'hFFFFFFFF && started_seq && last_sig_in != sig_in) begin
      end

      if (sig_in != 32'hFFFFFFFF && started_seq && last_sig_in != sig_in) begin
        data_in[count_in] <= sig_in;
        count_in <= count_in + 1;
      end


      // end

      // if (data_in[count_in] == 0 && tmp != 0)
      //   data_in[count_in] <= tmp;

      if (count_in == DIM+1) begin
        query_in_real <= data_in[DIM-1:0];
        k_in <= data_in[DIM];
        ready <= 1;//data_in[9];
        count_in <= DIM+2;

      end else ready <= 0;

    end
    
  end

  // assign query_in_real = data_in[7:0];
  // assign k_in = data_in[8];
  always_comb begin
    if (count_in < DIM && count_in != 0) begin
      led[15:11] = count_in;
      led[10:0]  = data_in[count_in-1];//data_in[count_in];//data_in[count_in];//data_in[count_in];
    end
  end

  always_ff @( posedge clk_100mhz ) begin
    last_val_3 <= val_3;
    
  end

  logic [31:0] buf_valid_out;

  FIFO #(.DATA_WIDTH(32),.DEPTH(DIM)) buf_out (
  .clk_in(clk_100mhz),
  .rst_in(sys_rst),
  .enq_data_in(top_k_out),
  .enq_in((state==3'b110)&&valid_out),
  .deq_in((state==3'b111)&&(count==0)),
  .full_out(),
  .data_out(buf_k_out),
  .empty_out(),
  .valid_out(buf_valid_out)
  );

  //   input wire clk_in,
//  assign led = buf_k_out[15:0]; //state;//buf_k_out[15:0];
  // input wire rst_in,
  // input wire [31:0] vertex_id_in,
  // input wire [31:0] query_in [DIM-1:0],
  // input wire [15:0] k_in,
  // output logic [31:0] top_k_out,
  // output logic valid_out,
  // output logic [2:0] state

logic [31:0] count;

always_ff @ (posedge clk_100mhz) begin
  if (sys_rst) count <= 0;
  else begin
    count <= (count > 10000000) ? 0 : count + 1;
  end
end


// assign led = state;//top_k_out;//state;
// assign led[15] = valid_out;//state;
// assign led[14:12] = state;//state;
// always_ff @ (posedge clk_100mhz) begin
//   if (valid_out) led <= 1'b1;
// end

  logic [2:0] i;

  // always_ff @( posedge clk_100mhz ) begin 
  //   if (sys_rst) i <= 0;
  //   else begin
  //     if (i==4) i<=0;
  //     else i<=i+1;
  //   end
    
  // end


  manta man (
      .clk(clk_100mhz),
      .rx(uart_rxd),
      .tx(uart_txd),
      .val1_in(buf_k_out),
      .val2_in(buf_valid_out),
      .val3_out(val_3),
      .val4_out(sig_in)
    );


  //   //lots of stuff


  // logic [13:0] cycle;

  // always_ff @(posedge clk_100mhz ) begin
  //   // if (sys_rst) begin
  //   //   cycle <= 0;
  //   //   data_valid_in <= 0;

  //   // end else begin
  //     if (cycle == 10000) begin
  //       cycle <= 0;
  //       data_valid_in <= 1;
  //     end else begin
  //       cycle <= cycle + 1;
  //       data_valid_in <= 0;
  //     end
  //   // end
  // end
   


endmodule // top_level

`default_nettype wire
