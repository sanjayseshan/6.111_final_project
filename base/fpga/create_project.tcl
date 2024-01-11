create_project -force -part xcvu095-ffva2104-2-e top_level
add_files -fileset sources_1 defines.v ../hdl/bfis.sv ../hdl/checked.sv ../hdl/distance_calc.sv ../hdl/fifo.sv ../hdl/graph_fetch.sv ../hdl/manta.sv ../hdl/pq.sv ../hdl/storage.sv ../hdl/top_level.sv ../hdl/visited.sv ../hdl/xilinx_single_port_ram_read_first.v ../hdl/xilinx_true_dual_port_read_first_2_clock_ram.v
set_property top top_level [current_fileset]
add_files -fileset constrs_1 ../xdc/top_level.xdc
