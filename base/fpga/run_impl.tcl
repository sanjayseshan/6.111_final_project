open_project top_level.xpr
reset_run impl_1
launch_runs -jobs 4 impl_1
wait_on_run impl_1
open_run impl_1
report_utilization -file top_level_utilization.rpt
report_utilization -hierarchical -file top_level_utilization_hierarchical.rpt
