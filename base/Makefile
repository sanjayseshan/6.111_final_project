CONNECTALDIR?=../connectal
# S2H_INTERFACES = EchoRequest:Echo.request
# H2S_INTERFACES = Echo:EchoIndication
S2H_INTERFACES = MemcpyRequest:Memcpy.request
H2S_INTERFACES = Memcpy:MemcpyIndication
MEM_READ_INTERFACES = lMemcpy.dmaReadClient
MEM_WRITE_INTERFACES = lMemcpy.dmaWriteClient


# BSVFILES = Echo.bsv 
BSVFILES = Memcpy.bsv
CPPFILES= testecho.cpp

CONNECTALFLAGS += -D TRACE_PORTAL

include $(CONNECTALDIR)/Makefile.connectal

