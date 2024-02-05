#include "GeneratedTypes.h"
#ifndef _MEMCPYREQUEST_H_
#define _MEMCPYREQUEST_H_
#include "portal.h"

class MemcpyRequestProxy : public Portal {
    MemcpyRequestCb *cb;
public:
    MemcpyRequestProxy(int id, int tile = DEFAULT_TILE, MemcpyRequestCb *cbarg = &MemcpyRequestProxyReq, int bufsize = MemcpyRequest_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    MemcpyRequestProxy(int id, PortalTransportFunctions *transport, void *param, MemcpyRequestCb *cbarg = &MemcpyRequestProxyReq, int bufsize = MemcpyRequest_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, transport, param, this, poller), cb(cbarg) {};
    MemcpyRequestProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, MemcpyRequest_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&MemcpyRequestProxyReq) {};
    int startCopy ( const uint32_t wrPointer, const uint32_t rdPointer, const uint32_t numWords, const uint32_t burstLen, const uint32_t iterCnt ) { return cb->startCopy (&pint, wrPointer, rdPointer, numWords, burstLen, iterCnt); };
};

extern MemcpyRequestCb MemcpyRequest_cbTable;
class MemcpyRequestWrapper : public Portal {
public:
    MemcpyRequestWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = MemcpyRequest_handleMessage, int bufsize = MemcpyRequest_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&MemcpyRequest_cbTable, this, poller) {
    };
    MemcpyRequestWrapper(int id, PortalTransportFunctions *transport, void *param, PORTAL_INDFUNC cba = MemcpyRequest_handleMessage, int bufsize = MemcpyRequest_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&MemcpyRequest_cbTable, transport, param, this, poller) {
    };
    MemcpyRequestWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, MemcpyRequest_reqinfo, MemcpyRequest_handleMessage, (void *)&MemcpyRequest_cbTable, this, poller) {
    };
    MemcpyRequestWrapper(int id, PortalTransportFunctions *transport, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, MemcpyRequest_reqinfo, MemcpyRequest_handleMessage, (void *)&MemcpyRequest_cbTable, transport, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("MemcpyRequestWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void startCopy ( const uint32_t wrPointer, const uint32_t rdPointer, const uint32_t numWords, const uint32_t burstLen, const uint32_t iterCnt ) = 0;
};
#endif // _MEMCPYREQUEST_H_
