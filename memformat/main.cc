// Copyright 2020, MIT
// Authors: Xuhao Chen <cxh@mit.edu>
#include "ann.h"

int main(int argc, char *argv[]) {
  if (argc < 2) {
    std::cout << "Usage: " << argv[0] << " <graph> [dim(100)]\n";
    std::cout << "Example: " << argv[0] << " /graph_inputs/mico/graph\n";
    exit(1);
  }

  std::cout << "Graph-based Nearest Neighbor Search.\n";
  Graph g(argv[1]);
  g.print_meta_data();
  int dim = 100; // vector dimension
  if (argc > 2) dim = atoi(argv[2]);
  auto inputs = generate_embeddings(g.V(), dim);

    //   for(Embedding i:inputs) {
    //     printf("embedding found size %d\n",(i).size());
    //   // std::cout << "here\n";
    //   for (float j:i) {
    //     printf("point found %f\n",j);
    //     // std::cout << "P: " << j;
    //   }
    // }
  
  auto query = generate_query(dim);
  parse(g, inputs);
  return 0;
}

