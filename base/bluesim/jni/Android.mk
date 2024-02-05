
include $(CLEAR_VARS)
DTOP?=/home/seshan/6.111_final_project/base/bluesim
CONNECTALDIR?=/home/seshan/6.111_final_project/connectal
LOCAL_ARM_MODE := arm
include $(CONNECTALDIR)/scripts/Makefile.connectal.application
LOCAL_SRC_FILES := /home/seshan/6.111_final_project/base/testecho.cpp /home/seshan/6.111_final_project/connectal/cpp/dmaManager.c /home/seshan/6.111_final_project/connectal/cpp/platformMemory.cpp /home/seshan/6.111_final_project/connectal/cpp/transportXsim.c $(PORTAL_SRC_FILES)

LOCAL_PATH :=
LOCAL_MODULE := android.exe
LOCAL_MODULE_TAGS := optional
LOCAL_LDLIBS := -llog   
LOCAL_CPPFLAGS := "-march=armv7-a"
LOCAL_CFLAGS := -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp   -Werror
LOCAL_CXXFLAGS := -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp   -Werror
LOCAL_CFLAGS2 := $(cdefines2)s

include $(BUILD_EXECUTABLE)
