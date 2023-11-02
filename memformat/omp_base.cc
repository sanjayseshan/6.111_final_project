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
    ofstream outfile("out.mem"); 

    uint32_t* mappings = calloc(g.size()+1,sizeof(uint32_t));
    mappings[0] = 0;

    // std::vector<uint32_t> memlayout (1);

    int pos = 1;
    for (vidType v0=0; v0<g.size(); g++) {
        auto v = v+1;
        mappings[v] = pos;
        fd.write();
        // memlayout.push_back(v);
        outfile << v << endl; 
        pos++;
        for (float i:points[v]) {
            // memlayout.push_back((uint32_t)i);
            outfile << (uint32_t)i << endl; 
            pos++;
        }
        for (vidType m:g.N(v)) {
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

}