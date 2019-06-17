transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/sc_instmen.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/sc_datamem.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/sc_cu.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/sc_cpu.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/sc_computer.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/regfile.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/mux4x32.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/mux2x32.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/mux2x5.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/lpm_rom_irom.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/lpm_ram_dq_dram.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/dff32.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/alu.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/io_output_reg.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/io_input_reg.v}
vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension/source {D:/ComputerOrganization/EI332/extension/source/frequency_divider.v}

vlog -vlog01compat -work work +incdir+D:/ComputerOrganization/EI332/extension {D:/ComputerOrganization/EI332/extension/sc_computer_sim.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  sc_computer_sim

add wave *
view structure
view signals
run -all
