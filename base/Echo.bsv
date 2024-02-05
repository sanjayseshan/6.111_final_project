// Copyright (c) 2013 Nokia, Inc.
// Copyright (c) 2013 Quanta Research Cambridge, Inc.

// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
import FIFO::*;
import Vector::*;
import FIFOF :: * ;


interface EchoIndication;
    method Action heard(Bit#(32) v);
    method Action heard2(Bit#(16) a, Bit#(16) b);
endinterface

interface EchoRequest;
   method Action say(Bit#(32) v);
   method Action say2(Bit#(16) a, Bit#(16) b);
   method Action setLeds(Bit#(8) v);
endinterface

interface Echo;
   interface EchoRequest request;
endinterface

typedef struct {
	Bit#(16) a;
	Bit#(16) b;
} EchoPair deriving (Bits);


import "BVI" routerFIFO =
module mkrouterFIFOtest #(Integer depth, Bool g) (FIFOF#(a))
    //module mkSizedFIFOtest #(Integer depth) (FIFOF#(a))
    provisos(Bits#(a,size_a));
    parameter V_P1WIDTH = valueOf(size_a);
    parameter V_P2DEPTH = depth;
    parameter V_P3CNTR_WIDTH = log2(depth+1);
    parameter V_GUARDED = Bit#(1)'(pack(g));
    default_clock clk;
    default_reset rst_RST_N;
    input_clock clk (V_CLK) <- exposeCurrentClock;
    input_reset rst_RST_N (V_RST_N) clocked_by(clk) <- exposeCurrentReset;
    method enq (V_D_IN) enable(V_ENQ) ready(V_FULL_N);
    method deq () enable(V_DEQ) ready(V_EMPTY_N);
    // method V_D_OUT first () ready(V_EMPTY_N);
    method V_D_OUT first () ;
    method V_FULL_N notFull ();
    method V_EMPTY_N notEmpty ();
    method clear () enable (V_CLR);
    schedule deq CF enq ;
    schedule enq CF (deq, first) ;
    schedule (first, notEmpty, notFull) CF (first,notEmpty, notFull) ;
    schedule (clear, deq, enq) SBR clear ;
    schedule first SB (clear, deq) ;
    schedule (notEmpty, notFull) SB (clear, deq, enq) ;
    schedule deq C deq;
    schedule enq C enq;
endmodule   



module mkEcho#(EchoIndication indication)(Echo);
    FIFO#(Bit#(32)) delay <- mkSizedFIFO(8);
    FIFO#(EchoPair) delay2 <- mkSizedFIFO(8);

    // test f <- test(32);
    FIFOF#(Bit#(32)) f <- mkrouterFIFOtest(2, True);

    rule heard;
        delay.deq;
        indication.heard(delay.first);
    endrule

    rule heard2;
        delay2.deq;
        indication.heard2(delay2.first.b, delay2.first.a);
    endrule
   
   interface EchoRequest request;
      method Action say(Bit#(32) v);
        //  f.enq(v);
        //  f.deq();
    	 delay.enq(f.first());
      endmethod
      
      method Action say2(Bit#(16) a, Bit#(16) b);
	    delay2.enq(EchoPair { a: a, b: b});
      endmethod
      
      method Action setLeds(Bit#(8) v);
      endmethod
   endinterface
endmodule
