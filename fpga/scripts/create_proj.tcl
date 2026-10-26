

set proj_name "fpga-life"
set top_name "main"
set part "xc7a35tcpg236-1"

set fpga_dir [file normalize [file join [file dirname [info script]] ..]]
set proj_dir [file join $fpga_dir vivado_proj]

create_project $proj_name $proj_dir -part $part -force

add_files -norecurse [glob [file join $fpga_dir rtl *.sv]]
set_property top $top_name [get_filesets sources_1]

add_files -fileset constrs_1 -norecurse [glob [file join $fpga_dir constraints *.xdc]]