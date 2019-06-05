transcript on
if ![file isdirectory sc_computer_iputf_libs] {
	file mkdir sc_computer_iputf_libs
}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

###### Libraries for IPUTF cores 
###### End libraries for IPUTF cores 
###### MIF file copy and HDL compilation commands for IPUTF cores 


vlog "D:/ComputerOrganization/Experiment2/pll_sim/pll.vo"

vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/sc_instmen.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/sc_datamem.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/sc_cu.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/sc_cpu.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/sc_computer.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/regfile.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/mux4x32.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/mux2x32.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/mux2x5.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/lpm_rom_irom.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/lpm_ram_dq_dram.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/dff32.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/alu.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/io_output_reg.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2/source {D:/ComputerOrganization/Experiment2/source/io_input_reg.v}

vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/Experiment2 {D:/ComputerOrganization/Experiment2/sc_computer_sim.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  sc_computer_sim

add wave *
view structure
view signals
run -all
