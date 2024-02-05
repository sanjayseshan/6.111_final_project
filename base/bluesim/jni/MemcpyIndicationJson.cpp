#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int MemcpyIndicationJson_started ( struct PortalInternal *p )
{
    Json::Value request;
    request.append(Json::Value("started"));
    

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MemcpyIndication_started);
    return 0;
};

int MemcpyIndicationJson_done ( struct PortalInternal *p )
{
    Json::Value request;
    request.append(Json::Value("done"));
    

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MemcpyIndication_done);
    return 0;
};

MemcpyIndicationCb MemcpyIndicationJsonProxyReq = {
    portal_disconnect,
    MemcpyIndicationJson_started,
    MemcpyIndicationJson_done,
};
MemcpyIndicationCb *pMemcpyIndicationJsonProxyReq = &MemcpyIndicationJsonProxyReq;
const char * MemcpyIndicationJson_methodSignatures()
{
    return "{\"started\": [], \"done\": []}";
}

int MemcpyIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MemcpyIndicationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_MemcpyIndication_started: {
        ((MemcpyIndicationCb *)p->cb)->started(p);
      } break;
    case CHAN_NUM_MemcpyIndication_done: {
        ((MemcpyIndicationCb *)p->cb)->done(p);
      } break;
    default:
        PORTAL_PRINTF("MemcpyIndicationJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MemcpyIndicationJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
