#pragma once
#include <vector>
#include "graph.h"

typedef std::vector<float> Embedding;
void ANN(Graph &g, std::vector<Embedding> points, Embedding query);

// inline std::vector<Embedding> generate_embeddings(vidType num, int dim) {
//   std::vector<Embedding> points(num);
//   for (auto pt : points) {
//     pt.resize(dim);
//     for (int j = 0; j < dim; j++)
//       pt[j] = rand() / (RAND_MAX + 1.0);
//   }
//   return points;
// }

inline std::vector<Embedding> generate_embeddings(vidType num, int dim) {
  std::vector<Embedding> points(num);
  // (num);
  for (int i=0; i<num;i++) {
    // pt.resize(dim);
    std::vector<float> emb (dim);
    for (int j = 0; j < dim; j++) {
      // printf("pushed point %d\n",0);
      emb.push_back(rand() / (RAND_MAX + 1.0));
      // pt[j] = rand() / (RAND_MAX + 1.0);
    }
    // printf("push emb %d\n",0);
    points.push_back(emb);
    // printf("pushed emb %d\n",0);
  }
  return points;
}

inline Embedding generate_query(int dim) {
  Embedding pt(dim);
  for (int j = 0; j < dim; j++)
    pt[j] = rand() / (RAND_MAX + 1.0);
  return pt;
}

