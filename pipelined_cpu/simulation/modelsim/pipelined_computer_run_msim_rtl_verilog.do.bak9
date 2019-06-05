transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/alu.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/sevenseg.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/regfile.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/mux4x32.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/io_output_reg.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/io_input_reg.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/dram.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/pipelined_computer.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/mux2x32.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/pipepc.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/pipeif.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/pipeid.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/pipedereg.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/pipeexe.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/pipeemreg.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/pipemem.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/pipemwreg.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/pipefereg.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/irom.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3/source {D:/ComputerOrganization/Experiment3/source/pipecu.v}

vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment3 {D:/ComputerOrganization/Experiment3/pipelined_computer_sim.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  pipelined_computer_sim

add wave *
view structure
view signals
run -all
