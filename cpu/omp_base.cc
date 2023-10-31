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
    int L = 20;

    // how many elements to return 
    int k = 10;

    // create visited list
    int visited [points.size()] = { 0 }; 
    std::priority_queue<tuple<int,int,vidType>> checked; 
    // std::priority_queue<tuple<int,int,vidType>> checked;

    int dist;
    // std::priority_queue<tuple<int,std::vector<float>>> S;
    std::priority_queue<tuple<int,int,vidType>> S;
    // std::priority_queue<tuple<vidType,std::vector<float>>> output;
    // std::list<tuple<vidType,std::vector<float>>> output;
    std::list<int> output;

    int index = 0;
    int P = g.V(index);
    Embedding P_loc = points[index];

    // std::cout << "P loc size: " << P_loc.size();

    for(Embedding i:points) {
      std::cout << "here";
      for (float j:i) {
        std::cout << "P: " << j;
      }
    }

    dist = 0;
    for(int i=0; i< P_loc.size(); i++){
      dist += pow(P_loc[i]-query[i], 2);
      std::cout << "P location: " << P_loc[i] << "\nQuery location: " << query[i];
    }
    dist = pow(dist, 0.5);

    std::cout << "dist: " << dist;

    
    // // pq.push(make_tuple(starting_point);
    S.push(make_tuple(dist, index, P));


    while (!S.empty()) {
      // i = index of first unchecked vertex
      index = get<1>(S.top());
      
      // get vertex from pq
      vidType v = get<2>(S.top());

      // marked v_i as checked
      checked.push(S.top());
      S.pop();

      // iterate through neighbors
      for(vidType u:g.N(v)) {
        if (visited[v] == 0) {
          visited[v] = 1;
        
        // if(std::find(visited.begin(), visited.end(), u) != visited.end()) {
        //   visited.push_back(u);

          std::vector<float> point = points[v];
          dist = 0;
          for(int i=0; i< point.size(); i++){
            dist += pow(point[i]-query[i], 2);
          }
          dist = pow(dist, 0.5);

          if (dist < get<0>(S.top()) && S.size()>=L) {
            S.push(make_tuple(dist, v, u));
          }
        }
      }
    }

    // }

    while (checked.size() > k) {
      checked.pop();
    }
    for (int i=0; i<k; i++) {
      // output.push_front(make_tuple(get<2>(checked.top()), points[get<1>(checked.top())]));
      int element = get<1>(checked.top());
      output.push_front(element);
      checked.pop();

      std::cout << element << '\n';
    }

    // std::cout << "output = " << output;
  

  t.Stop();
  std::cout << "runtime [omp_base] = " << t.Seconds() << " sec\n";
  return;
}

