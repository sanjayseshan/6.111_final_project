// Copyright 2020 MIT
// Authors: Xuhao Chen <cxh@mit.edu>
#include "ann.h"
#include<tuple> 
#include <list>
#include <vector>
#include <cmath>
#include <queue>
#include <iostream>
#include <algorithm>
#include <bits/stdc++.h>

#include "utils.hh"
#include "common.hpp"
// using namespace std;

void kNN_search(int K, int qsize, int dim, size_t dsize, 
                const float *queries, const float *points, 
                vid_t *results, Graph &g) {
  
  int num_threads = 0;
  #pragma omp parallel
  {
    num_threads = omp_get_num_threads();
  }
  std::cout << "OpenMP ANN (" << num_threads << " threads)\n";
  Timer t;
  t.Start();

  // #pragma omp parallel for
  // for (vidType u = 0; u < g.V(); u ++) {
  //   auto adj_u = g.N(u);
  // }

  for (int query_id=0; query_id<qsize; query_id++) {
    // add code here

    // define query
      const float* query = queries + query_id * dim;

    // // fixed length L
      int L = 10*K;

    //   // how many elements to return 
    //   int k = K;

      // create visited list
      int visited [10000] = { 0 }; 

      // priority queues
      std::priority_queue<tuple<float,int>, vector<tuple<float, int>>, greater<tuple<float, int>>> S;
      std::priority_queue<tuple<float,int>> checked; 

      std::list<int> output;

      int index = 0;
      // Embedding P_loc = points[index];
      const float* P_loc = points;

      // for debugging
      // std::cout << "P loc size: " << P_loc.size();


      // distance calculation
      float dist = 0.0;
      for(int i=0; i< dim; i++){
        dist = dist + pow((P_loc[i]-query[i]), 2);

        // for debugging
        // std::cout << "\nP location: " << P_loc[i] << ", Query location: " << query[i] << " dist: " << dist;
      }
      dist = pow(dist, 0.5);
      //std::cout << "dist: " << dist << "\n";

      // add starting point to S
      S.push(make_tuple(dist, index));
      visited[index] = 1;


      while (!S.empty()) {
        // i = index of first unchecked vertex
        vidType v = get<1>(S.top());

        // for debugging
        // std::cout << "\nindex: " << v;

        // marked v_i as checked
        if (checked.size() < L || get<0>(S.top()) < get<0>(checked.top())) {
          checked.push(S.top());

          if (checked.size()>L) {
            checked.pop();
          }
        }
        else {
          if(checked.size()==L) {
            break;
          }
        }
        S.pop();

        // for debugging
        // std::cout << "\nS size: " << S.size();
        // std::cout << "\nchecked size: " << checked.size();

        // iterate through neighbors
        for(vidType u:g.N(v)) {
          if (visited[u] == 0) {
            visited[u] = 1;

            // for debugging
            // std::cout << "\nu: " << u;

            // find distance
            const float* point = points + u*dim; //points[u];
            dist = 0.0;
            for(int i=0; i< dim; i++){
              dist += pow(point[i]-query[i], 2);
            }
            dist = pow(dist, 0.5);
            // std::cout << "\ndist: " << dist;

            // add to S 
            // float max_dist = get<0>(S.top());
            // if (dist < max_dist || S.size() < L) {
              S.push(make_tuple(dist, u));
            // }

            // resize based on L
            std::vector<tuple<float, int>> temp;
            if (S.size() > L) {
              while (S.size() > 1) {
                temp.push_back(S.top());
                S.pop();
              }
              S.pop();
              for (tuple<float, int> element: temp){
                S.push(element);
              }
              temp.clear();
            }
          }
        }
      }

      while (checked.size() > K) {
        checked.pop();
      }
      
      int checked_length = checked.size();
      for (int i=0; (i<K && i<checked_length); i++) {
        int element = get<1>(checked.top());
        float dist = get<0>(checked.top());
        // output.push_front(element);
        results[query_id * K + (K-i-1)] = get<1>(checked.top());
        checked.pop();

        // std::cout << "\nelement: " << element << ", dist: " << dist;
      }
    }


  t.Stop();
  std::cout << "\nruntime [omp_base] = " << t.Seconds() << " sec\n";
}

