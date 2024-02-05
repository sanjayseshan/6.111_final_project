#include "GeneratedTypes.h"

int MemcpyRequest_startCopy ( struct PortalInternal *p, const uint32_t wrPointer, const uint32_t rdPointer, const uint32_t numWords, const uint32_t burstLen, const uint32_t iterCnt )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MemcpyRequest_startCopy, 6);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MemcpyRequest_startCopy, "MemcpyRequest_startCopy")) return 1;
    p->transport->write(p, &temp_working_addr, wrPointer);
    p->transport->write(p, &temp_working_addr, rdPointer);
    p->transport->write(p, &temp_working_addr, numWords);
    p->transport->write(p, &temp_working_addr, burstLen);
    p->transport->write(p, &temp_working_addr, iterCnt);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MemcpyRequest_startCopy << 16) | 6, -1);
    return 0;
};

MemcpyRequestCb MemcpyRequestProxyReq = {
    portal_disconnect,
    MemcpyRequest_startCopy,
};
MemcpyRequestCb *pMemcpyRequestProxyReq = &MemcpyRequestProxyReq;

const uint32_t MemcpyRequest_reqinfo = 0x10018;
const char * MemcpyRequest_methodSignatures()
{
    return "{\"startCopy\": [\"long\", \"long\", \"long\", \"long\", \"long\"]}";
}

int MemcpyRequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MemcpyRequestData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_MemcpyRequest_startCopy: {
        p->transport->recv(p, temp_working_addr, 5, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.startCopy.wrPointer = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.startCopy.rdPointer = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.startCopy.numWords = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.startCopy.burstLen = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.startCopy.iterCnt = (uint32_t)(((tmp)&0xfffffffful));
        ((MemcpyRequestCb *)p->cb)->startCopy(p, tempdata.startCopy.wrPointer, tempdata.startCopy.rdPointer, tempdata.startCopy.numWords, tempdata.startCopy.burstLen, tempdata.startCopy.iterCnt);
      } break;
    default:
        PORTAL_PRINTF("MemcpyRequest_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MemcpyRequest_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
