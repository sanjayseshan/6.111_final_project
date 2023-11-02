include ../common.mk
all: ann_omp_base ann_gpu_base

gen_out: $(OBJS) gen_out.o
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(OBJS) gen_out.o -o $@ -lgomp
	mv $@ $(BIN)

# ann_cilk_base: $(OBJS) cilk_base.o 
# 	$(CLANGXX) $(CILKFLAGS) $(INCLUDES) $(CILK_INC) $(OBJS) cilk_base.o -o $@
# 	mv $@ $(BIN)

# ann_gpu_base: $(OBJS) gpu_base.o
# 	$(CXX) $(CXXFLAGS) $(INCLUDES) $(OBJS) gpu_base.o -o $@ $(NVLIBS)
# 	mv $@ $(BIN)

clean:
	rm *.o
