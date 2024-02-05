#include "GeneratedTypes.h"

int MemcpyIndication_started ( struct PortalInternal *p )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MemcpyIndication_started, 1);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MemcpyIndication_started, "MemcpyIndication_started")) return 1;
    p->transport->write(p, &temp_working_addr, 0);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MemcpyIndication_started << 16) | 1, -1);
    return 0;
};

int MemcpyIndication_done ( struct PortalInternal *p )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MemcpyIndication_done, 1);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MemcpyIndication_done, "MemcpyIndication_done")) return 1;
    p->transport->write(p, &temp_working_addr, 0);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MemcpyIndication_done << 16) | 1, -1);
    return 0;
};

MemcpyIndicationCb MemcpyIndicationProxyReq = {
    portal_disconnect,
    MemcpyIndication_started,
    MemcpyIndication_done,
};
MemcpyIndicationCb *pMemcpyIndicationProxyReq = &MemcpyIndicationProxyReq;

const uint32_t MemcpyIndication_reqinfo = 0x20004;
const char * MemcpyIndication_methodSignatures()
{
    return "{\"started\": [], \"done\": []}";
}

int MemcpyIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MemcpyIndicationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_MemcpyIndication_started: {
        p->transport->recv(p, temp_working_addr, 0, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        ((MemcpyIndicationCb *)p->cb)->started(p);
      } break;
    case CHAN_NUM_MemcpyIndication_done: {
        p->transport->recv(p, temp_working_addr, 0, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        ((MemcpyIndicationCb *)p->cb)->done(p);
      } break;
    default:
        PORTAL_PRINTF("MemcpyIndication_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MemcpyIndication_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
