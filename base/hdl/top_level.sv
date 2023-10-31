`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module top_level(
  input wire clk_100mhz,
  input wire [15:0] sw, //all 16 input slide switches
  // input wire [3:0] btn, //all four momentary button switches
  input wire uart_rxd,
  output wire uart_txd,
  output logic [15:0] led //16 green output LEDs (located right above switches)
  );

  assign led = sw; //for debugging
  //shut up those rgb LEDs (active high):
  // assign rgb1= 0;
  // assign rgb0 = 0;

  // logic sys_rst;
  // assign sys_rst = 0;
  //  btn[0];


  logic[31:0] dividend_in;
  logic[31:0] divisor_in;
  logic data_valid_in;
  logic[31:0] quotient_out;
  logic[31:0] remainder_out;
  // logic data_valid_out;
  // logic error_out;
  // logic busy_out;
  logic[31:0] val1_in;
  logic[31:0] val2_in;


  logic [31:0]m_axis_result_tdata1;
  logic m_axis_result_tvalid1;
  logic [31:0]m_axis_result_tdata2;
  logic m_axis_result_tvalid2;

  logic m_axis_result_tvalid3;
  logic [31:0]m_axis_result_tdata3;

  logic m_axis_result_tvalid4;
  logic [31:0]m_axis_result_tdata4;


always_comb begin
  if (sw[0]) begin
    val1_in = m_axis_result_tdata3;
    val2_in = m_axis_result_tdata4;
  end else begin
    val1_in = quotient_out;
    val2_in = remainder_out;
  end
  
end


  divider #(.WIDTH(32)) div (.clk_in(clk_100mhz),
                // .rst_in(sys_rst),
                .dividend_in(dividend_in),
                .divisor_in(divisor_in),
                .data_valid_in(data_valid_in),
                .quotient_out(quotient_out),
                .remainder_out(remainder_out)
                // .data_valid_out(data_valid_out),
                // .error_out(error_out),
                // .busy_out(busy_out)
                );



  manta man (
      .clk(clk_100mhz),
      .rx(uart_rxd),
      .tx(uart_txd),
      .val1_in(val1_in),
      .val2_in(val2_in),
      .val3_out(divisor_in),
     .val4_out(dividend_in));
    //lots of stuff


  logic [13:0] cycle;

  always_ff @(posedge clk_100mhz ) begin
    // if (sys_rst) begin
    //   cycle <= 0;
    //   data_valid_in <= 0;

    // end else begin
      if (cycle == 10000) begin
        cycle <= 0;
        data_valid_in <= 1;
      end else begin
        cycle <= cycle + 1;
        data_valid_in <= 0;
      end
    // end
  end
   
  // multiplier(.aclk(clk_100mhz), .s_axis_a_tvalid(data_valid_in), .s_axis_a_tready(), 
  // .s_axis_a_tdata(), .s_axis_b_tvalid(), .s_axis_b_tready(), .s_axis_b_tdata(), .m_axis_result_tvalid(), 
  // .m_axis_result_tready(), .m_axis_result_tdata())


  multiplier mult1(.aclk(clk_100mhz), .s_axis_a_tvalid(data_valid_in),
  .s_axis_a_tdata(dividend_in), .s_axis_b_tvalid(data_valid_in),  .s_axis_b_tdata(dividend_in), 
  .m_axis_result_tready(1), .m_axis_result_tvalid(m_axis_result_tvalid1), .m_axis_result_tdata(m_axis_result_tdata1));

  multiplier mult2(.aclk(clk_100mhz), .s_axis_a_tvalid(data_valid_in),
  .s_axis_a_tdata(divisor_in), .s_axis_b_tvalid(data_valid_in),  .s_axis_b_tdata(divisor_in), 
  .m_axis_result_tready(1), .m_axis_result_tvalid(m_axis_result_tvalid2), .m_axis_result_tdata(m_axis_result_tdata2));


  adder add(.aclk(clk_100mhz), .s_axis_a_tvalid(m_axis_result_tvalid1), 
  .s_axis_a_tdata(m_axis_result_tdata1), .s_axis_b_tvalid(m_axis_result_tvalid2), .s_axis_b_tdata(m_axis_result_tdata2), .m_axis_result_tvalid(m_axis_result_tvalid3), 
  .m_axis_result_tready(1), .m_axis_result_tdata(m_axis_result_tdata3));

  inv_sqrt isqrt (.aclk(clk_100mhz), .s_axis_a_tvalid(m_axis_result_tvalid3), 
  .s_axis_a_tdata(m_axis_result_tdata3), .m_axis_result_tvalid(m_axis_result_tvalid4), .m_axis_result_tready(1), .m_axis_result_tdata(m_axis_result_tdata4));


/* synthesis syn_black_box black_box_pad_pin="s_axis_a_tvalid,s_axis_a_tready,s_axis_a_tdata[31:0],s_axis_b_tvalid,s_axis_b_tready,s_axis_b_tdata[31:0],m_axis_result_tvalid,m_axis_result_tready,m_axis_result_tdata[31:0]" */
/* synthesis syn_force_seq_prim="aclk" */;
  // input aclk /* synthesis syn_isclock = 1 */;
  // input s_axis_a_tvalid;
  // output s_axis_a_tready;
  // input [31:0]s_axis_a_tdata;
  // input s_axis_b_tvalid;
  // output s_axis_b_tready;
  // input [31:0]s_axis_b_tdata;
  // output m_axis_result_tvalid;
  // input m_axis_result_tready;
  // output [31:0]m_axis_result_tdata;
// endmodule


// adder(aclk, s_axis_a_tvalid, s_axis_a_tready, 
//   s_axis_a_tdata, s_axis_b_tvalid, s_axis_b_tready, s_axis_b_tdata, m_axis_result_tvalid, 
//   m_axis_result_tready, m_axis_result_tdata);

/* synthesis syn_black_box black_box_pad_pin="s_axis_a_tvalid,s_axis_a_tready,s_axis_a_tdata[31:0],s_axis_b_tvalid,s_axis_b_tready,s_axis_b_tdata[31:0],m_axis_result_tvalid,m_axis_result_tready,m_axis_result_tdata[31:0]" */
/* synthesis syn_force_seq_prim="aclk" */;
  // input aclk /* synthesis syn_isclock = 1 */;
  // input s_axis_a_tvalid;
  // output s_axis_a_tready;
  // input [31:0]s_axis_a_tdata;
  // input s_axis_b_tvalid;
  // output s_axis_b_tready;
  // input [31:0]s_axis_b_tdata;
  // output m_axis_result_tvalid;
  // input m_axis_result_tready;
  // output [31:0]m_axis_result_tdata;

// inv_sqrt(aclk, s_axis_a_tvalid, s_axis_a_tready, 
//   s_axis_a_tdata, m_axis_result_tvalid, m_axis_result_tready, m_axis_result_tdata)
/* synthesis syn_black_box black_box_pad_pin="s_axis_a_tvalid,s_axis_a_tready,s_axis_a_tdata[31:0],m_axis_result_tvalid,m_axis_result_tready,m_axis_result_tdata[31:0]" */
/* synthesis syn_force_seq_prim="aclk" */;
  // input aclk /* synthesis syn_isclock = 1 */;
  // input s_axis_a_tvalid;
  // output s_axis_a_tready;
  // input [31:0]s_axis_a_tdata;
  // output m_axis_result_tvalid;
  // input m_axis_result_tready;
  // output [31:0]m_axis_result_tdata;

endmodule // top_level

`default_nettype wire
