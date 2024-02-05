#ifndef __GENERATED_TYPES__
#define __GENERATED_TYPES__
#include "portal.h"
#ifdef __cplusplus
extern "C" {
#endif
typedef struct EchoPair {
    uint16_t a : 16;
    uint16_t b : 16;
} EchoPair;
typedef enum ChannelType { ChannelType_Read, ChannelType_Write,  } ChannelType;
typedef struct DmaDbgRec {
    uint32_t x : 32;
    uint32_t y : 32;
    uint32_t z : 32;
    uint32_t w : 32;
} DmaDbgRec;
typedef enum DmaErrorType { DmaErrorNone, DmaErrorSGLIdOutOfRange_r, DmaErrorSGLIdOutOfRange_w, DmaErrorMMUOutOfRange_r, DmaErrorMMUOutOfRange_w, DmaErrorOffsetOutOfRange, DmaErrorSGLIdInvalid, DmaErrorTileTagOutOfRange,  } DmaErrorType;
typedef uint32_t SpecialTypeForSendingFd;
typedef enum TileState { Idle, Stopped, Running,  } TileState;
typedef struct TileControl {
    uint8_t tile : 2;
    TileState state;
} TileControl;
typedef enum XsimIfcNames { XsimIfcNames_XsimMsgRequest, XsimIfcNames_XsimMsgIndication,  } XsimIfcNames;
typedef enum IfcNames { IfcNamesNone=0, PlatformIfcNames_MemServerRequestS2H=1, PlatformIfcNames_MMURequestS2H=2, PlatformIfcNames_MemServerIndicationH2S=3, PlatformIfcNames_MMUIndicationH2S=4, IfcNames_MemcpyIndicationH2S=5, IfcNames_MemcpyRequestS2H=6,  } IfcNames;


int MemServerRequest_addrTrans ( struct PortalInternal *p, const uint32_t sglId, const uint32_t offset );
int MemServerRequest_setTileState ( struct PortalInternal *p, const TileControl tc );
int MemServerRequest_stateDbg ( struct PortalInternal *p, const ChannelType rc );
int MemServerRequest_memoryTraffic ( struct PortalInternal *p, const ChannelType rc );
enum { CHAN_NUM_MemServerRequest_addrTrans,CHAN_NUM_MemServerRequest_setTileState,CHAN_NUM_MemServerRequest_stateDbg,CHAN_NUM_MemServerRequest_memoryTraffic};
extern const uint32_t MemServerRequest_reqinfo;

typedef struct {
    uint32_t sglId;
    uint32_t offset;
} MemServerRequest_addrTransData;
typedef struct {
    TileControl tc;
} MemServerRequest_setTileStateData;
typedef struct {
    ChannelType rc;
} MemServerRequest_stateDbgData;
typedef struct {
    ChannelType rc;
} MemServerRequest_memoryTrafficData;
typedef union {
    MemServerRequest_addrTransData addrTrans;
    MemServerRequest_setTileStateData setTileState;
    MemServerRequest_stateDbgData stateDbg;
    MemServerRequest_memoryTrafficData memoryTraffic;
} MemServerRequestData;
int MemServerRequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*addrTrans) (  struct PortalInternal *p, const uint32_t sglId, const uint32_t offset );
    int (*setTileState) (  struct PortalInternal *p, const TileControl tc );
    int (*stateDbg) (  struct PortalInternal *p, const ChannelType rc );
    int (*memoryTraffic) (  struct PortalInternal *p, const ChannelType rc );
} MemServerRequestCb;
extern MemServerRequestCb MemServerRequestProxyReq;

int MemServerRequestJson_addrTrans ( struct PortalInternal *p, const uint32_t sglId, const uint32_t offset );
int MemServerRequestJson_setTileState ( struct PortalInternal *p, const TileControl tc );
int MemServerRequestJson_stateDbg ( struct PortalInternal *p, const ChannelType rc );
int MemServerRequestJson_memoryTraffic ( struct PortalInternal *p, const ChannelType rc );
int MemServerRequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern MemServerRequestCb MemServerRequestJsonProxyReq;

int MMURequest_sglist ( struct PortalInternal *p, const uint32_t sglId, const uint32_t sglIndex, const uint64_t addr, const uint32_t len );
int MMURequest_region ( struct PortalInternal *p, const uint32_t sglId, const uint64_t barr12, const uint32_t index12, const uint64_t barr8, const uint32_t index8, const uint64_t barr4, const uint32_t index4, const uint64_t barr0, const uint32_t index0 );
int MMURequest_idRequest ( struct PortalInternal *p, const SpecialTypeForSendingFd fd );
int MMURequest_idReturn ( struct PortalInternal *p, const uint32_t sglId );
int MMURequest_setInterface ( struct PortalInternal *p, const uint32_t interfaceId, const uint32_t sglId );
enum { CHAN_NUM_MMURequest_sglist,CHAN_NUM_MMURequest_region,CHAN_NUM_MMURequest_idRequest,CHAN_NUM_MMURequest_idReturn,CHAN_NUM_MMURequest_setInterface};
extern const uint32_t MMURequest_reqinfo;

typedef struct {
    uint32_t sglId;
    uint32_t sglIndex;
    uint64_t addr;
    uint32_t len;
} MMURequest_sglistData;
typedef struct {
    uint32_t sglId;
    uint64_t barr12;
    uint32_t index12;
    uint64_t barr8;
    uint32_t index8;
    uint64_t barr4;
    uint32_t index4;
    uint64_t barr0;
    uint32_t index0;
} MMURequest_regionData;
typedef struct {
    SpecialTypeForSendingFd fd;
} MMURequest_idRequestData;
typedef struct {
    uint32_t sglId;
} MMURequest_idReturnData;
typedef struct {
    uint32_t interfaceId;
    uint32_t sglId;
} MMURequest_setInterfaceData;
typedef union {
    MMURequest_sglistData sglist;
    MMURequest_regionData region;
    MMURequest_idRequestData idRequest;
    MMURequest_idReturnData idReturn;
    MMURequest_setInterfaceData setInterface;
} MMURequestData;
int MMURequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*sglist) (  struct PortalInternal *p, const uint32_t sglId, const uint32_t sglIndex, const uint64_t addr, const uint32_t len );
    int (*region) (  struct PortalInternal *p, const uint32_t sglId, const uint64_t barr12, const uint32_t index12, const uint64_t barr8, const uint32_t index8, const uint64_t barr4, const uint32_t index4, const uint64_t barr0, const uint32_t index0 );
    int (*idRequest) (  struct PortalInternal *p, const SpecialTypeForSendingFd fd );
    int (*idReturn) (  struct PortalInternal *p, const uint32_t sglId );
    int (*setInterface) (  struct PortalInternal *p, const uint32_t interfaceId, const uint32_t sglId );
} MMURequestCb;
extern MMURequestCb MMURequestProxyReq;

int MMURequestJson_sglist ( struct PortalInternal *p, const uint32_t sglId, const uint32_t sglIndex, const uint64_t addr, const uint32_t len );
int MMURequestJson_region ( struct PortalInternal *p, const uint32_t sglId, const uint64_t barr12, const uint32_t index12, const uint64_t barr8, const uint32_t index8, const uint64_t barr4, const uint32_t index4, const uint64_t barr0, const uint32_t index0 );
int MMURequestJson_idRequest ( struct PortalInternal *p, const SpecialTypeForSendingFd fd );
int MMURequestJson_idReturn ( struct PortalInternal *p, const uint32_t sglId );
int MMURequestJson_setInterface ( struct PortalInternal *p, const uint32_t interfaceId, const uint32_t sglId );
int MMURequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern MMURequestCb MMURequestJsonProxyReq;

int MemServerIndication_addrResponse ( struct PortalInternal *p, const uint64_t physAddr );
int MemServerIndication_reportStateDbg ( struct PortalInternal *p, const DmaDbgRec rec );
int MemServerIndication_reportMemoryTraffic ( struct PortalInternal *p, const uint64_t words );
int MemServerIndication_error ( struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra );
enum { CHAN_NUM_MemServerIndication_addrResponse,CHAN_NUM_MemServerIndication_reportStateDbg,CHAN_NUM_MemServerIndication_reportMemoryTraffic,CHAN_NUM_MemServerIndication_error};
extern const uint32_t MemServerIndication_reqinfo;

typedef struct {
    uint64_t physAddr;
} MemServerIndication_addrResponseData;
typedef struct {
    DmaDbgRec rec;
} MemServerIndication_reportStateDbgData;
typedef struct {
    uint64_t words;
} MemServerIndication_reportMemoryTrafficData;
typedef struct {
    uint32_t code;
    uint32_t sglId;
    uint64_t offset;
    uint64_t extra;
} MemServerIndication_errorData;
typedef union {
    MemServerIndication_addrResponseData addrResponse;
    MemServerIndication_reportStateDbgData reportStateDbg;
    MemServerIndication_reportMemoryTrafficData reportMemoryTraffic;
    MemServerIndication_errorData error;
} MemServerIndicationData;
int MemServerIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*addrResponse) (  struct PortalInternal *p, const uint64_t physAddr );
    int (*reportStateDbg) (  struct PortalInternal *p, const DmaDbgRec rec );
    int (*reportMemoryTraffic) (  struct PortalInternal *p, const uint64_t words );
    int (*error) (  struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra );
} MemServerIndicationCb;
extern MemServerIndicationCb MemServerIndicationProxyReq;

int MemServerIndicationJson_addrResponse ( struct PortalInternal *p, const uint64_t physAddr );
int MemServerIndicationJson_reportStateDbg ( struct PortalInternal *p, const DmaDbgRec rec );
int MemServerIndicationJson_reportMemoryTraffic ( struct PortalInternal *p, const uint64_t words );
int MemServerIndicationJson_error ( struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra );
int MemServerIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern MemServerIndicationCb MemServerIndicationJsonProxyReq;

int MMUIndication_idResponse ( struct PortalInternal *p, const uint32_t sglId );
int MMUIndication_configResp ( struct PortalInternal *p, const uint32_t sglId );
int MMUIndication_error ( struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra );
enum { CHAN_NUM_MMUIndication_idResponse,CHAN_NUM_MMUIndication_configResp,CHAN_NUM_MMUIndication_error};
extern const uint32_t MMUIndication_reqinfo;

typedef struct {
    uint32_t sglId;
} MMUIndication_idResponseData;
typedef struct {
    uint32_t sglId;
} MMUIndication_configRespData;
typedef struct {
    uint32_t code;
    uint32_t sglId;
    uint64_t offset;
    uint64_t extra;
} MMUIndication_errorData;
typedef union {
    MMUIndication_idResponseData idResponse;
    MMUIndication_configRespData configResp;
    MMUIndication_errorData error;
} MMUIndicationData;
int MMUIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*idResponse) (  struct PortalInternal *p, const uint32_t sglId );
    int (*configResp) (  struct PortalInternal *p, const uint32_t sglId );
    int (*error) (  struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra );
} MMUIndicationCb;
extern MMUIndicationCb MMUIndicationProxyReq;

int MMUIndicationJson_idResponse ( struct PortalInternal *p, const uint32_t sglId );
int MMUIndicationJson_configResp ( struct PortalInternal *p, const uint32_t sglId );
int MMUIndicationJson_error ( struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra );
int MMUIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern MMUIndicationCb MMUIndicationJsonProxyReq;

int XsimMsgRequest_msgSink ( struct PortalInternal *p, const uint32_t portal, const uint32_t data );
int XsimMsgRequest_msgSinkFd ( struct PortalInternal *p, const uint32_t portal, const SpecialTypeForSendingFd data );
enum { CHAN_NUM_XsimMsgRequest_msgSink,CHAN_NUM_XsimMsgRequest_msgSinkFd};
extern const uint32_t XsimMsgRequest_reqinfo;

typedef struct {
    uint32_t portal;
    uint32_t data;
} XsimMsgRequest_msgSinkData;
typedef struct {
    uint32_t portal;
    SpecialTypeForSendingFd data;
} XsimMsgRequest_msgSinkFdData;
typedef union {
    XsimMsgRequest_msgSinkData msgSink;
    XsimMsgRequest_msgSinkFdData msgSinkFd;
} XsimMsgRequestData;
int XsimMsgRequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*msgSink) (  struct PortalInternal *p, const uint32_t portal, const uint32_t data );
    int (*msgSinkFd) (  struct PortalInternal *p, const uint32_t portal, const SpecialTypeForSendingFd data );
} XsimMsgRequestCb;
extern XsimMsgRequestCb XsimMsgRequestProxyReq;

int XsimMsgRequestJson_msgSink ( struct PortalInternal *p, const uint32_t portal, const uint32_t data );
int XsimMsgRequestJson_msgSinkFd ( struct PortalInternal *p, const uint32_t portal, const SpecialTypeForSendingFd data );
int XsimMsgRequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern XsimMsgRequestCb XsimMsgRequestJsonProxyReq;

int XsimMsgIndication_msgSource ( struct PortalInternal *p, const uint32_t portal, const uint32_t data );
enum { CHAN_NUM_XsimMsgIndication_msgSource};
extern const uint32_t XsimMsgIndication_reqinfo;

typedef struct {
    uint32_t portal;
    uint32_t data;
} XsimMsgIndication_msgSourceData;
typedef union {
    XsimMsgIndication_msgSourceData msgSource;
} XsimMsgIndicationData;
int XsimMsgIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*msgSource) (  struct PortalInternal *p, const uint32_t portal, const uint32_t data );
} XsimMsgIndicationCb;
extern XsimMsgIndicationCb XsimMsgIndicationProxyReq;

int XsimMsgIndicationJson_msgSource ( struct PortalInternal *p, const uint32_t portal, const uint32_t data );
int XsimMsgIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern XsimMsgIndicationCb XsimMsgIndicationJsonProxyReq;

int MemcpyRequest_startCopy ( struct PortalInternal *p, const uint32_t wrPointer, const uint32_t rdPointer, const uint32_t numWords, const uint32_t burstLen, const uint32_t iterCnt );
enum { CHAN_NUM_MemcpyRequest_startCopy};
extern const uint32_t MemcpyRequest_reqinfo;

typedef struct {
    uint32_t wrPointer;
    uint32_t rdPointer;
    uint32_t numWords;
    uint32_t burstLen;
    uint32_t iterCnt;
} MemcpyRequest_startCopyData;
typedef union {
    MemcpyRequest_startCopyData startCopy;
} MemcpyRequestData;
int MemcpyRequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*startCopy) (  struct PortalInternal *p, const uint32_t wrPointer, const uint32_t rdPointer, const uint32_t numWords, const uint32_t burstLen, const uint32_t iterCnt );
} MemcpyRequestCb;
extern MemcpyRequestCb MemcpyRequestProxyReq;

int MemcpyRequestJson_startCopy ( struct PortalInternal *p, const uint32_t wrPointer, const uint32_t rdPointer, const uint32_t numWords, const uint32_t burstLen, const uint32_t iterCnt );
int MemcpyRequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern MemcpyRequestCb MemcpyRequestJsonProxyReq;

int MemcpyIndication_started ( struct PortalInternal *p );
int MemcpyIndication_done ( struct PortalInternal *p );
enum { CHAN_NUM_MemcpyIndication_started,CHAN_NUM_MemcpyIndication_done};
extern const uint32_t MemcpyIndication_reqinfo;

typedef struct {
        int padding;

} MemcpyIndication_startedData;
typedef struct {
        int padding;

} MemcpyIndication_doneData;
typedef union {
    MemcpyIndication_startedData started;
    MemcpyIndication_doneData done;
} MemcpyIndicationData;
int MemcpyIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*started) (  struct PortalInternal *p );
    int (*done) (  struct PortalInternal *p );
} MemcpyIndicationCb;
extern MemcpyIndicationCb MemcpyIndicationProxyReq;

int MemcpyIndicationJson_started ( struct PortalInternal *p );
int MemcpyIndicationJson_done ( struct PortalInternal *p );
int MemcpyIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern MemcpyIndicationCb MemcpyIndicationJsonProxyReq;
#ifdef __cplusplus
}
#endif
#endif //__GENERATED_TYPES__
