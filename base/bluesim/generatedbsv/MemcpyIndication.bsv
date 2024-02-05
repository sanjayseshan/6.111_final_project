package MemcpyIndication;

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
    Bit#(32) padding;
} Started_Message deriving (Bits);

typedef struct {
    Bit#(32) padding;
} Done_Message deriving (Bits);

// exposed wrapper portal interface
interface MemcpyIndicationInputPipes;
    interface PipeOut#(Started_Message) started_PipeOut;
    interface PipeOut#(Done_Message) done_PipeOut;

endinterface
typedef PipePortal#(2, 0, SlaveDataBusWidth) MemcpyIndicationPortalInput;
interface MemcpyIndicationInput;
    interface MemcpyIndicationPortalInput portalIfc;
    interface MemcpyIndicationInputPipes pipes;
endinterface
interface MemcpyIndicationWrapperPortal;
    interface MemcpyIndicationPortalInput portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface MemcpyIndicationWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(MemcpyIndicationInputPipes,MemcpyIndication);
   module mkConnection#(MemcpyIndicationInputPipes pipes, MemcpyIndication ifc)(Empty);

    rule handle_started_request;
        let request <- toGet(pipes.started_PipeOut).get();
        ifc.started();
    endrule

    rule handle_done_request;
        let request <- toGet(pipes.done_PipeOut).get();
        ifc.done();
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkMemcpyIndicationInput(MemcpyIndicationInput);
    Vector#(2, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,Started_Message) started_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = started_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,Done_Message) done_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[1] = done_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(Started_Message)));
            1: return fromInteger(valueOf(SizeOf#(Done_Message)));
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
    interface MemcpyIndicationInputPipes pipes;
        interface started_PipeOut = started_requestAdapter.out;
        interface done_PipeOut = done_requestAdapter.out;
    endinterface
endmodule

module mkMemcpyIndicationWrapperPortal#(MemcpyIndication ifc)(MemcpyIndicationWrapperPortal);
    let dut <- mkMemcpyIndicationInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface MemcpyIndicationWrapperMemPortalPipes;
    interface MemcpyIndicationInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkMemcpyIndicationWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(MemcpyIndicationWrapperMemPortalPipes);

  let dut <- mkMemcpyIndicationInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface MemcpyIndicationInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkMemcpyIndicationWrapper#(idType id, MemcpyIndication ifc)(MemcpyIndicationWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkMemcpyIndicationWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
typedef PipePortal#(0, 2, SlaveDataBusWidth) MemcpyIndicationPortalOutput;
interface MemcpyIndicationOutput;
    interface MemcpyIndicationPortalOutput portalIfc;
    interface Memcpy::MemcpyIndication ifc;
endinterface
interface MemcpyIndicationProxy;
    interface StdPortal portalIfc;
    interface Memcpy::MemcpyIndication ifc;
endinterface

interface MemcpyIndicationOutputPipeMethods;
    interface PipeIn#(Started_Message) started;
    interface PipeIn#(Done_Message) done;

endinterface

interface MemcpyIndicationOutputPipes;
    interface MemcpyIndicationOutputPipeMethods methods;
    interface MemcpyIndicationPortalOutput portalIfc;
endinterface

function Bit#(16) getMemcpyIndicationMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(Started_Message)));
            1: return fromInteger(valueOf(SizeOf#(Done_Message)));
    endcase
endfunction

(* synthesize *)
module mkMemcpyIndicationOutputPipes(MemcpyIndicationOutputPipes);
    Vector#(2, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,Started_Message) started_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = started_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,Done_Message) done_responseAdapter <- mkAdapterToBus();
    indicationPipes[1] = done_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface MemcpyIndicationOutputPipeMethods methods;
    interface started = started_responseAdapter.in;
    interface done = done_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getMemcpyIndicationMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkMemcpyIndicationOutput(MemcpyIndicationOutput);
    let indicationPipes <- mkMemcpyIndicationOutputPipes;
    interface Memcpy::MemcpyIndication ifc;

    method Action started();
        indicationPipes.methods.started.enq(Started_Message {padding: 0});
        //$display("indicationMethod 'started' invoked");
    endmethod
    method Action done();
        indicationPipes.methods.done.enq(Done_Message {padding: 0});
        //$display("indicationMethod 'done' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(MemcpyIndicationOutput);
   function Bit#(16) portalMessageSize(MemcpyIndicationOutput p, Bit#(16) methodNumber);
      return getMemcpyIndicationMessageSize(methodNumber);
   endfunction
endinstance


interface MemcpyIndicationInverse;
    method ActionValue#(Started_Message) started;
    method ActionValue#(Done_Message) done;

endinterface

interface MemcpyIndicationInverter;
    interface Memcpy::MemcpyIndication ifc;
    interface MemcpyIndicationInverse inverseIfc;
endinterface

instance Connectable#(MemcpyIndicationInverse, MemcpyIndicationOutputPipeMethods);
   module mkConnection#(MemcpyIndicationInverse in, MemcpyIndicationOutputPipeMethods out)(Empty);
    mkConnection(in.started, out.started);
    mkConnection(in.done, out.done);

   endmodule
endinstance

(* synthesize *)
module mkMemcpyIndicationInverter(MemcpyIndicationInverter);
    FIFOF#(Started_Message) fifo_started <- mkFIFOF();
    FIFOF#(Done_Message) fifo_done <- mkFIFOF();

    interface Memcpy::MemcpyIndication ifc;

    method Action started();
        fifo_started.enq(Started_Message {padding: 0});
    endmethod
    method Action done();
        fifo_done.enq(Done_Message {padding: 0});
    endmethod
    endinterface
    interface MemcpyIndicationInverse inverseIfc;

    method ActionValue#(Started_Message) started;
        fifo_started.deq;
        return fifo_started.first;
    endmethod
    method ActionValue#(Done_Message) done;
        fifo_done.deq;
        return fifo_done.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkMemcpyIndicationInverterV(MemcpyIndicationInverter);
    PutInverter#(Started_Message) inv_started <- mkPutInverter();
    PutInverter#(Done_Message) inv_done <- mkPutInverter();

    interface Memcpy::MemcpyIndication ifc;

    method Action started();
        inv_started.mod.put(Started_Message {padding: 0});
    endmethod
    method Action done();
        inv_done.mod.put(Done_Message {padding: 0});
    endmethod
    endinterface
    interface MemcpyIndicationInverse inverseIfc;

    method ActionValue#(Started_Message) started;
        let v <- inv_started.inverse.get;
        return v;
    endmethod
    method ActionValue#(Done_Message) done;
        let v <- inv_done.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkMemcpyIndicationProxySynth#(Bit#(SlaveDataBusWidth) id)(MemcpyIndicationProxy);
  let dut <- mkMemcpyIndicationOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface Memcpy::MemcpyIndication ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkMemcpyIndicationProxy#(idType id)(MemcpyIndicationProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkMemcpyIndicationProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: MemcpyIndication
