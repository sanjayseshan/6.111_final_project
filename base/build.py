import os
import subprocess

xvlog = "/opt/Xilinx/Vivado/2023.1/bin/xvlog"
xelab = "/opt/Xilinx/Vivado/2023.1/bin/xelab"
xsim = "/opt/Xilinx/Vivado/2023.1/bin/xsim"

class VivadoBuildError(Exception): pass

if not os.access("xsim_run.tcl", os.R_OK):
	raise VivadoBuildError("you should pass a build script for us to run!")

print("starting vivado, please wait...")
proc = subprocess.Popen(f"{xvlog} --sv ./hdl/*",
	shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

while True:
	line = proc.stdout.readline()
	if not line: break
	else: print(str(line.rstrip(), encoding='ascii'))


# proc = subprocess.Popen(f"{xvlog} --sv ./sim_scripts/multiplier/xsim/glbl.v",
# 	shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

# while True:
# 	line = proc.stdout.readline()
# 	if not line: break
# 	else: print(str(line.rstrip(), encoding='ascii'))


proc.wait()

if proc.returncode != 0:
  #save("vivado.log")
  raise VivadoBuildError(f"vivado exited with code {proc.returncode}")
else:
  pass
  #save("vivado.log")

proc = subprocess.Popen(f"{xelab} -svlog ./sim/distance_float_tb.sv --debug wave",
	shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

while True:
	line = proc.stdout.readline()
	if not line: break
	else: print(str(line.rstrip(), encoding='ascii'))

proc.wait()

if proc.returncode != 0:
  #save("vivado.log")
  raise VivadoBuildError(f"vivado exited with code {proc.returncode}")
else:
  pass
  #save("vivado.log")


proc = subprocess.Popen(f"{xsim} distance_float_tb -t xsim_run.tcl",
	shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

while True:
	line = proc.stdout.readline()
	if not line: break
	else: print(str(line.rstrip(), encoding='ascii'))

proc.wait()

if proc.returncode != 0:
  #save("vivado.log")
  raise VivadoBuildError(f"vivado exited with code {proc.returncode}")
else:
  pass
  #save("vivado.log")

proc = subprocess.Popen(f"tar -czvf dump.tar.gz dump.vcd",
	shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

while True:
	line = proc.stdout.readline()
	if not line: break
	else: print(str(line.rstrip(), encoding='ascii'))

proc.wait()

#files to look for:
files = [ "distance_float.tar.gz","distance_float.vcd"
]

for file in files:
  # look for out.bit, because we've hard coded that for now i guess
  if not os.access(f"{file}", os.R_OK):
	  raise VivadoBuildError(f"vivado suite exited successfully, but no {file} generated")
  save(f"{file}")
