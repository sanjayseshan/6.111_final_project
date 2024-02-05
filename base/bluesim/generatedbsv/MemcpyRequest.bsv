package MemcpyRequest;

import FIFO::*;
import FIFOF::*;
import GetPut::*;
import Connectable::*;
import Clocks::*;
import FloatingPoint::*;
import Adapter::*;
import Leds::*;
import Vector::*;
import SpecialFIFOs::*;
import ConnectalConfig::*;
import ConnectalMemory::*;
import Portal::*;
import CtrlMux::*;
import ConnectalMemTypes::*;
import Pipe::*;
import HostInterface::*;
import LinkerLib::*;
import Memcpy::*;
import FIFO::*;
import Vector::*;
import FIFOF::*;
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
    Bit#(32) wrPointer;
    Bit#(32) rdPointer;
    Bit#(32) numWords;
    Bit#(32) burstLen;
    Bit#(32) iterCnt;
} StartCopy_Message deriving (Bits);

// exposed wrapper portal interface
interface MemcpyRequestInputPipes;
    interface PipeOut#(StartCopy_Message) startCopy_PipeOut;

endinterface
typedef PipePortal#(1, 0, SlaveDataBusWidth) MemcpyRequestPortalInput;
interface MemcpyRequestInput;
    interface MemcpyRequestPortalInput portalIfc;
    interface MemcpyRequestInputPipes pipes;
endinterface
interface MemcpyRequestWrapperPortal;
    interface MemcpyRequestPortalInput portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface MemcpyRequestWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(MemcpyRequestInputPipes,MemcpyRequest);
   module mkConnection#(MemcpyRequestInputPipes pipes, MemcpyRequest ifc)(Empty);

    rule handle_startCopy_request;
        let request <- toGet(pipes.startCopy_PipeOut).get();
        ifc.startCopy(request.wrPointer, request.rdPointer, request.numWords, request.burstLen, request.iterCnt);
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkMemcpyRequestInput(MemcpyRequestInput);
    Vector#(1, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,StartCopy_Message) startCopy_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = startCopy_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(StartCopy_Message)));
            endcase
        endmethod
        endinterface
        interface Vector requests = requestPipeIn;
        interface Vector indications = nil;
        interface PortalInterrupt intr;
           method Bool status();
              return False;
           endmethod
           method Bit#(dataWidth) channel();
              return -1;
           endmethod
        endinterface
    endinterface
    interface MemcpyRequestInputPipes pipes;
        interface startCopy_PipeOut = startCopy_requestAdapter.out;
    endinterface
endmodule

module mkMemcpyRequestWrapperPortal#(MemcpyRequest ifc)(MemcpyRequestWrapperPortal);
    let dut <- mkMemcpyRequestInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface MemcpyRequestWrapperMemPortalPipes;
    interface MemcpyRequestInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkMemcpyRequestWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(MemcpyRequestWrapperMemPortalPipes);

  let dut <- mkMemcpyRequestInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface MemcpyRequestInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkMemcpyRequestWrapper#(idType id, MemcpyRequest ifc)(MemcpyRequestWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkMemcpyRequestWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
typedef PipePortal#(0, 1, SlaveDataBusWidth) MemcpyRequestPortalOutput;
interface MemcpyRequestOutput;
    interface MemcpyRequestPortalOutput portalIfc;
    interface Memcpy::MemcpyRequest ifc;
endinterface
interface MemcpyRequestProxy;
    interface StdPortal portalIfc;
    interface Memcpy::MemcpyRequest ifc;
endinterface

interface MemcpyRequestOutputPipeMethods;
    interface PipeIn#(StartCopy_Message) startCopy;

endinterface

interface MemcpyRequestOutputPipes;
    interface MemcpyRequestOutputPipeMethods methods;
    interface MemcpyRequestPortalOutput portalIfc;
endinterface

function Bit#(16) getMemcpyRequestMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(StartCopy_Message)));
    endcase
endfunction

(* synthesize *)
module mkMemcpyRequestOutputPipes(MemcpyRequestOutputPipes);
    Vector#(1, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,StartCopy_Message) startCopy_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = startCopy_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface MemcpyRequestOutputPipeMethods methods;
    interface startCopy = startCopy_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getMemcpyRequestMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkMemcpyRequestOutput(MemcpyRequestOutput);
    let indicationPipes <- mkMemcpyRequestOutputPipes;
    interface Memcpy::MemcpyRequest ifc;

    method Action startCopy(Bit#(32) wrPointer, Bit#(32) rdPointer, Bit#(32) numWords, Bit#(32) burstLen, Bit#(32) iterCnt);
        indicationPipes.methods.startCopy.enq(StartCopy_Message {wrPointer: wrPointer, rdPointer: rdPointer, numWords: numWords, burstLen: burstLen, iterCnt: iterCnt});
        //$display("indicationMethod 'startCopy' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(MemcpyRequestOutput);
   function Bit#(16) portalMessageSize(MemcpyRequestOutput p, Bit#(16) methodNumber);
      return getMemcpyRequestMessageSize(methodNumber);
   endfunction
endinstance


interface MemcpyRequestInverse;
    method ActionValue#(StartCopy_Message) startCopy;

endinterface

interface MemcpyRequestInverter;
    interface Memcpy::MemcpyRequest ifc;
    interface MemcpyRequestInverse inverseIfc;
endinterface

instance Connectable#(MemcpyRequestInverse, MemcpyRequestOutputPipeMethods);
   module mkConnection#(MemcpyRequestInverse in, MemcpyRequestOutputPipeMethods out)(Empty);
    mkConnection(in.startCopy, out.startCopy);

   endmodule
endinstance

(* synthesize *)
module mkMemcpyRequestInverter(MemcpyRequestInverter);
    FIFOF#(StartCopy_Message) fifo_startCopy <- mkFIFOF();

    interface Memcpy::MemcpyRequest ifc;

    method Action startCopy(Bit#(32) wrPointer, Bit#(32) rdPointer, Bit#(32) numWords, Bit#(32) burstLen, Bit#(32) iterCnt);
        fifo_startCopy.enq(StartCopy_Message {wrPointer: wrPointer, rdPointer: rdPointer, numWords: numWords, burstLen: burstLen, iterCnt: iterCnt});
    endmethod
    endinterface
    interface MemcpyRequestInverse inverseIfc;

    method ActionValue#(StartCopy_Message) startCopy;
        fifo_startCopy.deq;
        return fifo_startCopy.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkMemcpyRequestInverterV(MemcpyRequestInverter);
    PutInverter#(StartCopy_Message) inv_startCopy <- mkPutInverter();

    interface Memcpy::MemcpyRequest ifc;

    method Action startCopy(Bit#(32) wrPointer, Bit#(32) rdPointer, Bit#(32) numWords, Bit#(32) burstLen, Bit#(32) iterCnt);
        inv_startCopy.mod.put(StartCopy_Message {wrPointer: wrPointer, rdPointer: rdPointer, numWords: numWords, burstLen: burstLen, iterCnt: iterCnt});
    endmethod
    endinterface
    interface MemcpyRequestInverse inverseIfc;

    method ActionValue#(StartCopy_Message) startCopy;
        let v <- inv_startCopy.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkMemcpyRequestProxySynth#(Bit#(SlaveDataBusWidth) id)(MemcpyRequestProxy);
  let dut <- mkMemcpyRequestOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface Memcpy::MemcpyRequest ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkMemcpyRequestProxy#(idType id)(MemcpyRequestProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkMemcpyRequestProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: MemcpyRequest
