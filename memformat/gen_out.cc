#include "ann.h"
#include<tuple> 
#include <list>
#include <vector>
#include <cmath>
#include <queue>
#include <iostream>
#include <algorithm>
#include <bits/stdc++.h>
#include <stdlib.h>
#include <stdio.h>
#include <vector>
#include <fstream> 

void parse(Graph &g, std::vector<Embedding> points) {
    // fd = open("out.mem", O_WRONLY | O_CREAT, 0644);
    // printf("here\n");
    ofstream outfile("out_ids.mem"); 
    // printf("here2\n");

    uint32_t* mappings = (uint32_t*)calloc(g.size()+1,sizeof(uint32_t));
    mappings[0] = 0;
    // printf("here3\n");

    // std::vector<uint32_t> memlayout (1);
    outfile << 0 << endl; 
    int pos = 1;
    for (vidType v0=0; v0<g.size(); v0++) {
        // printf("v0=%d\n",v0);
        auto v = v0+1;
        mappings[v] = pos;
        // fd.write();
        // memlayout.push_back(v);
        outfile << v << endl; 
        pos++;
        for (float i:points[v0]) {
            // memlayout.push_back((uint32_t)i);
            // printf("e=%f\n",i);
            outfile << (uint32_t)int(i*100000000) << endl; 
            pos++;
        }
        for (vidType m:g.N(v0)) {
            // printf("n=%d\n",m);
            // memlayout.push_back(m);
            outfile << m << endl; 
            pos++;
        }
        outfile << (uint32_t)0 << endl; 
        // memlayout.push_back(0);
        pos++;
    }

    // close(fd);
    outfile.close();


    ofstream outfile3("out_addrs.mem"); 
    // printf("here2\n");

    // std::vector<uint32_t> memlayout (1);

    outfile3 << 0 << endl; 
    pos = 1;
    for (vidType v0=0; v0<g.size(); v0++) {
        // printf("v0=%d\n",v0);
        auto v = v0+1;
        // fd.write();
        // memlayout.push_back(v);
        outfile3 << v << endl; 
        pos++;
        for (float i:points[v0]) {
            // memlayout.push_back((uint32_t)i);
            // printf("e=%f\n",i);
            outfile3 << (uint32_t)int(i*100000000) << endl; 
            pos++;
        }
        for (vidType m:g.N(v0)) {
            // printf("n=%d\n",m);
            // memlayout.push_back(m);
            outfile3 << mappings[m] << endl; 
            pos++;
        }
        outfile3 << (uint32_t)0 << endl; 
        // memlayout.push_back(0);
        pos++;
    }

    // close(fd);
    outfile3.close();



    ofstream outfile2("out_vidx.mem"); 
    for (vidType i=0;i<g.size();i++)
        outfile2 << mappings[i] << endl; 
    free(mappings);
    outfile2.close();

}