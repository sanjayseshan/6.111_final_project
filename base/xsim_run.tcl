# read_ip ./ip/multiplier/multiplier.xci
# read_ip ./ip/adder/adder.xci
# read_ip ./ip/adder/addsub.xci
# generate_target all [get_ips]
# synth_ip [get_ips]

# set_property target_simulator VCS [./ip/multiplier]
# set_property compxlib.vcs_compiled_library_dir 
# <compiled_library_location>[./ip/multiplier]
# launch_simulation -noclean_dir -of_objects [get_files multiplier.xci]


open_vcd
log_vcd  *
run all
close_vcd
quit