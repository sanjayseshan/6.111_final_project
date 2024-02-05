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

import Vector::*;
import BuildVector::*;
import BRAMFIFO::*;
import GetPut::*;
import ClientServer::*;
import ConnectalConfig::*;
import ConnectalMemory::*;
import ConnectalMemTypes::*;
import MemReadEngine::*;
import MemWriteEngine::*;
import Pipe::*;

import Echo::*;


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

interface MemcpyRequest;
   method Action startCopy(Bit#(32) wrPointer, Bit#(32) rdPointer, Bit#(32) numWords, Bit#(32) burstLen, Bit#(32) iterCnt);
endinterface

interface MemcpyIndication;
   method Action started;
   method Action done;
endinterface

interface Memcpy;
   interface MemcpyRequest request;
   interface Vector#(1, MemReadClient#(DataBusWidth)) dmaReadClient;
   interface Vector#(1, MemWriteClient#(DataBusWidth)) dmaWriteClient;
endinterface


// NOTE: this test doesn't rely on mkDma[Read|Write]Buffer to ensure that
//       speculative read/write requests are not unsafely issued.  As a 
//       result this must be enforced manually (mdk)

typedef 8 CmdQDepth;
typedef TDiv#(DataBusWidth,32) WordsPerBeat;



module mkMemcpy#(MemcpyIndication indication)(Memcpy);

   MemReadEngine#(DataBusWidth,DataBusWidth,CmdQDepth,1)  re <- mkMemReadEngineBuff(valueOf(CmdQDepth)*512);
   MemWriteEngine#(DataBusWidth,DataBusWidth,CmdQDepth,1) we <- mkMemWriteEngineBuff(valueOf(CmdQDepth)*512);

   Integer wordsPerBeat = valueOf(WordsPerBeat);

   Reg#(Bit#(32))        rdIterCnt <- mkReg(0);
   Reg#(Bit#(32))        wrIterCnt <- mkReg(0);
   Reg#(SGLId)           rdPointer <- mkReg(0);
   Reg#(SGLId)           wrPointer <- mkReg(0);
   Reg#(Bit#(32))         burstLen <- mkReg(0);
   Reg#(Bit#(32))         numWords <- mkReg(0);
   
   FIFOF#(Bit#(DataBusWidth))    buffer <- mkSizedBRAMFIFOF(valueOf(CmdQDepth)*32);
   
   Bool verbose = True; //True;

   rule start_read(rdIterCnt > 0);
      if (verbose) $display("start_read obj %d numWords %d wordsPerBeat %d rditercnt %d", rdPointer, numWords, wordsPerBeat, rdIterCnt);
      re.readServers[0].request.put(MemengineCmd{sglId:rdPointer, base:0, len:extend(numWords*4), burstLen:truncate(burstLen*4), tag:0});
      rdIterCnt <= rdIterCnt-1;
      // rdPointer <= rdPointer +1;
   endrule

   rule start_write(wrIterCnt > 0);
      if (verbose) $display("                    start_write obj %d numWords %d", wrPointer, numWords);
      we.writeServers[0].request.put(MemengineCmd{sglId:wrPointer, base:0, len:extend(numWords*4), burstLen:truncate(burstLen*4), tag:0});
      wrIterCnt <= wrIterCnt-1;
   endrule
   
   rule write_finish;
      if (verbose) $display("                    write_finish %d", wrIterCnt);
      let rv1 <- we.writeServers[0].done.get;
      if(wrIterCnt==0)
	 indication.done;

    $display("DONE WR");
   endrule
   
   rule fill_buffer;
      let v <- toGet(re.readServers[0].data).get;
      buffer.enq(v.data);
      if (verbose) $display("fill_buffer %h %h",  v.data[63:32], v.data[31:0]);
      $display("filling status ",v.last);
      if (v.last && verbose) $display("read_finish %d", rdIterCnt);
   endrule
   
   rule drain_buffer;
      let v <- toGet(buffer).get();
      $display("drain_buffer %h %h", buffer.first[63:32],  buffer.first[31:0]);
      we.writeServers[0].data.enq(v);
      $display("drain status %h",v);

      // re.readServers[0].request.put(MemengineCmd{sglId:0, base:0, len:extend(numWords*4), burstLen:truncate(burstLen*4), tag:0});
   endrule

   rule test;
         let x <-toGet(re.readServers[0].data).get;
         $display("READING %x",x);
   endrule

   interface MemcpyRequest request;
   method Action startCopy(Bit#(32) wp, Bit#(32) rp, Bit#(32) nw, Bit#(32) bl, Bit#(32) ic);
      $display("startCopy wrPointer=%d rdPointer=%d numWords=%h burstLen=%d iterCnt=%d", wp, rp, nw, bl, ic);
      indication.started;
      // initialized
      wrPointer <= wp;
      rdPointer <= rp;
      numWords  <= nw;
      wrIterCnt <= ic;
      rdIterCnt <= ic;
      burstLen  <= bl;
   endmethod
   endinterface
   interface MemReadClient dmaReadClient = vec(re.dmaClient);
   interface MemWriteClient dmaWriteClient = vec(we.dmaClient);
endmodule


