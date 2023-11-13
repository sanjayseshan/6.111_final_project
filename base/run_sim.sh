#!/bin/bash
# xvlog --sv ./hdl/*
# xelab -svlog sim/distance_tb.sv --debug wave
# rm dump.vcd
# xsim distance_tb -t xsim_run.tcl

xvlog --sv ./hdl/*
xelab -svlog sim/fifo_tb.sv --debug wave
rm dump.vcd
xsim fifo_tb -t xsim_run.tcl
