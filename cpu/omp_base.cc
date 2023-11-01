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
// using namespace std;

void ANN(Graph &g, std::vector<Embedding> points, Embedding query) {
  // int num_threads = 1;
  // #pragma omp parallel
  // {
  //   num_threads = omp_get_num_threads();
  // }
  // std::cout << "OpenMP ANN (" << num_threads << " threads)\n";
  Timer t;
  t.Start();
  // #pragma omp parallel for
  // for (vidType u = 0; u < g.V(); u ++) {
  //   auto adj_u = g.N(u);
  // }

    // add code here
    // int visited[g.V] = 0;

    // fixed length L
    int L = 50;

    // how many elements to return 
    int k = 30;

    // create visited list
    int visited [points.size()] = { 0 }; 

    // priority queues
    std::priority_queue<tuple<float,int>, vector<tuple<float, int>>, greater<tuple<float, int>>> S;
    std::priority_queue<tuple<float,int>> checked; 

    std::list<int> output;

    int index = 0;
    Embedding P_loc = points[index];

    // for debugging
    // std::cout << "P loc size: " << P_loc.size();


    // distance calculation
    float dist = 0.0;
    for(int i=0; i< P_loc.size(); i++){
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
          std::vector<float> point = points[u];
          dist = 0.0;
          for(int i=0; i< point.size(); i++){
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

    while (checked.size() > k) {
      checked.pop();
    }
    
    int checked_length = checked.size();
    for (int i=0; (i<k && i<checked_length); i++) {
      int element = get<1>(checked.top());
      float dist = get<0>(checked.top());
      output.push_front(element);
      checked.pop();

      std::cout << "\nelement: " << element << ", dist: " << dist;
    }

    // std::cout << "output = " << output;


  t.Stop();
  std::cout << "\nruntime [omp_base] = " << t.Seconds() << " sec\n";
  return;
}

