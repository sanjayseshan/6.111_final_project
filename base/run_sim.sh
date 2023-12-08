#!/bin/bash
xvlog --sv ./hdl/*
xelab -svlog sim/distance_tb.sv --debug wave
rm dump.vcd
xsim distance_tb -t xsim_run.tcl

# xvlog --sv ./hdl/*
# xelab -svlog sim/bfis_tb.sv --debug wave
# # xelab -svlog sim/checked_tb.sv --debug wave
# rm dump.vcd
# # xsim checked_tb -t xsim_run.tcl
# xsim bfis_tb -t xsim_run.tcl
