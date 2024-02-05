
import ConnectalConfig::*;
import Vector::*;
import BuildVector::*;
import Portal::*;
import CnocPortal::*;
import Connectable::*;
import HostInterface::*;
import ConnectalMemTypes::*;
`include "ConnectalProjectConfig.bsv"
import IfcNames::*;
import `PinTypeInclude::*;
import MemcpyIndication::*;
import Memcpy::*;
import MemcpyRequest::*;

typedef 1 NumberOfRequests;
typedef 1 NumberOfIndications;

`ifndef IMPORT_HOSTIF
(* synthesize *)
`endif
module mkCnocTop
`ifdef IMPORT_HOSTIF
       #(HostInterface host)
`else
`ifdef IMPORT_HOST_CLOCKS // enables synthesis boundary
       #(Clock derivedClockIn, Reset derivedResetIn)
`else
// otherwise no params
`endif
`endif
       (CnocTop#(NumberOfRequests,NumberOfIndications,PhysAddrWidth,DataBusWidth,`PinType,NumberOfMasters));
   Clock defaultClock <- exposeCurrentClock();
   Reset defaultReset <- exposeCurrentReset();
`ifdef IMPORT_HOST_CLOCKS // enables synthesis boundary
   HostInterface host = (interface HostInterface;
                           interface Clock derivedClock = derivedClockIn;
                           interface Reset derivedReset = derivedResetIn;
                         endinterface);
`endif
   MemcpyIndicationOutput lMemcpyIndicationOutput <- mkMemcpyIndicationOutput;
   MemcpyRequestInput lMemcpyRequestInput <- mkMemcpyRequestInput;

   let lMemcpy <- mkMemcpy(lMemcpyIndicationOutput.ifc);

   mkConnection(lMemcpyRequestInput.pipes, lMemcpy.request);

   let lMemcpyIndicationOutputNoc <- mkPortalMsgIndication(extend(pack(IfcNames_MemcpyIndicationH2S)), lMemcpyIndicationOutput.portalIfc.indications, lMemcpyIndicationOutput.portalIfc.messageSize);
   let lMemcpyRequestInputNoc <- mkPortalMsgRequest(extend(pack(IfcNames_MemcpyRequestS2H)), lMemcpyRequestInput.portalIfc.requests);
   Vector#(NumWriteClients,MemWriteClient#(DataBusWidth)) nullWriters = replicate(null_mem_write_client());
   Vector#(NumReadClients,MemReadClient#(DataBusWidth)) nullReaders = replicate(null_mem_read_client());

   interface requests = vec(lMemcpyRequestInputNoc);
   interface indications = vec(lMemcpyIndicationOutputNoc);
   interface readers = take(append(lMemcpy.dmaReadClient,nullReaders));
   interface writers = take(append(lMemcpy.dmaWriteClient,nullWriters));
`ifdef TOP_SOURCES_PORTAL_CLOCK
   interface portalClockSource = None;
`endif


endmodule : mkCnocTop
export mkCnocTop;
export NumberOfRequests;
export NumberOfIndications;
export `PinTypeInclude::*;
