module routerFIFO(V_CLK, V_RST_N, V_D_IN, V_ENQ, V_FULL_N, V_D_OUT, V_DEQ, V_EMPTY_N, V_CLR);
parameter V_P1WIDTH = 1; // data width
parameter V_P2DEPTH = 3;
parameter V_P3CNTR_WIDTH = 1; // log(p2depth-1)
// The -1 is allowed since this model has a fast output register
parameter V_GUARDED = 1;
input V_CLK;
input V_RST_N;
input V_CLR;
input [V_P1WIDTH - 1 : 0] V_D_IN;
input V_ENQ;
input V_DEQ;
output V_FULL_N;
output V_EMPTY_N;
output [V_P1WIDTH - 1 : 0] V_D_OUT;

top_level bfis_main (
    .clk(V_CLK),
    .reset(V_RST_N)
);



assign V_D_OUT = 8;
assign V_EMPTY_N = 0;
assign V_FULL_N = 0;
endmodule
