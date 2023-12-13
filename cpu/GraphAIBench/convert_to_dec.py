
f = open("GraphAIBench/src/nearest_neighbor_search/data/tester_4/out_addrs.mem", "r")


output = open("GraphAIBench/src/nearest_neighbor_search/data/tester_4/out_addrs2.in", 'w')

for line in f:
    converted = int(line, 16)
    output.write(str(converted) + "\n")

output.close()



    

