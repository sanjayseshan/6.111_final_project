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

  assign led = sw; //for debugging
  //shut up those rgb LEDs (active high):
  // assign rgb1= 0;
  // assign rgb0 = 0;

  logic sys_rst;
  assign sys_rst = 0;
   btn[0];



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
   


endmodule // top_level

`default_nettype wire
