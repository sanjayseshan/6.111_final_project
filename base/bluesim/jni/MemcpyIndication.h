#include "GeneratedTypes.h"
#ifndef _MEMCPYINDICATION_H_
#define _MEMCPYINDICATION_H_
#include "portal.h"

class MemcpyIndicationProxy : public Portal {
    MemcpyIndicationCb *cb;
public:
    MemcpyIndicationProxy(int id, int tile = DEFAULT_TILE, MemcpyIndicationCb *cbarg = &MemcpyIndicationProxyReq, int bufsize = MemcpyIndication_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    MemcpyIndicationProxy(int id, PortalTransportFunctions *transport, void *param, MemcpyIndicationCb *cbarg = &MemcpyIndicationProxyReq, int bufsize = MemcpyIndication_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, transport, param, this, poller), cb(cbarg) {};
    MemcpyIndicationProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, MemcpyIndication_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&MemcpyIndicationProxyReq) {};
    int started (  ) { return cb->started (&pint); };
    int done (  ) { return cb->done (&pint); };
};

extern MemcpyIndicationCb MemcpyIndication_cbTable;
class MemcpyIndicationWrapper : public Portal {
public:
    MemcpyIndicationWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = MemcpyIndication_handleMessage, int bufsize = MemcpyIndication_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&MemcpyIndication_cbTable, this, poller) {
    };
    MemcpyIndicationWrapper(int id, PortalTransportFunctions *transport, void *param, PORTAL_INDFUNC cba = MemcpyIndication_handleMessage, int bufsize = MemcpyIndication_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&MemcpyIndication_cbTable, transport, param, this, poller) {
    };
    MemcpyIndicationWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, MemcpyIndication_reqinfo, MemcpyIndication_handleMessage, (void *)&MemcpyIndication_cbTable, this, poller) {
    };
    MemcpyIndicationWrapper(int id, PortalTransportFunctions *transport, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, MemcpyIndication_reqinfo, MemcpyIndication_handleMessage, (void *)&MemcpyIndication_cbTable, transport, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("MemcpyIndicationWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void started (  ) = 0;
    virtual void done (  ) = 0;
};
#endif // _MEMCPYINDICATION_H_
