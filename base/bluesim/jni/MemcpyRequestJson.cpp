#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int MemcpyRequestJson_startCopy ( struct PortalInternal *p, const uint32_t wrPointer, const uint32_t rdPointer, const uint32_t numWords, const uint32_t burstLen, const uint32_t iterCnt )
{
    Json::Value request;
    request.append(Json::Value("startCopy"));
    request.append((Json::UInt64)wrPointer);
    request.append((Json::UInt64)rdPointer);
    request.append((Json::UInt64)numWords);
    request.append((Json::UInt64)burstLen);
    request.append((Json::UInt64)iterCnt);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MemcpyRequest_startCopy);
    return 0;
};

MemcpyRequestCb MemcpyRequestJsonProxyReq = {
    portal_disconnect,
    MemcpyRequestJson_startCopy,
};
MemcpyRequestCb *pMemcpyRequestJsonProxyReq = &MemcpyRequestJsonProxyReq;
const char * MemcpyRequestJson_methodSignatures()
{
    return "{\"startCopy\": [\"long\", \"long\", \"long\", \"long\", \"long\"]}";
}

int MemcpyRequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MemcpyRequestData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_MemcpyRequest_startCopy: {
        ((MemcpyRequestCb *)p->cb)->startCopy(p, tempdata.startCopy.wrPointer, tempdata.startCopy.rdPointer, tempdata.startCopy.numWords, tempdata.startCopy.burstLen, tempdata.startCopy.iterCnt);
      } break;
    default:
        PORTAL_PRINTF("MemcpyRequestJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MemcpyRequestJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
