build:
	make d 
fail:
	clear
	wsrun.pl -pipe -list ./fail.list proc_hier_pbench *.v
ld:
	clear
	wsrun.pl -pipe -list ./ld.list proc_hier_pbench *.v
instld:
	clear
	wsrun.pl -pipe -list ./instld.list proc_hier_pbench *.v
one:
	clear
	wsrun.pl -pipe -list ./one.list proc_hier_pbench *.v

all1:
	clear
	wsrun.pl -pipe -list ../../demo2/tests/inst_tests/all.list proc_hier_pbench *.v
all2:
	clear
	wsrun.pl -pipe -list ../../demo2/tests/rand_simple/all.list proc_hier_pbench *.v
all3:
	clear
	wsrun.pl -pipe -list ../../demo2/tests/rand_ctrl/all.list proc_hier_pbench *.v
all4:
	clear
	wsrun.pl -pipe -list ../../demo2/tests/rand_mem/all.list proc_hier_pbench *.v
all5:
	clear
	wsrun.pl -pipe -list ../../demo2/tests/rand_complex/all.list proc_hier_pbench *.v
all6:
	clear
	wsrun.pl -pipe -list ../../demo2/tests/complex_demo1/all.list proc_hier_pbench *.v
all7:
	clear
	wsrun.pl -pipe -list ../../demo2/tests/complex_demo2/all.list proc_hier_pbench *.v

# Basic Pipelined program
basic:
	wsrun.pl -pipe -prog ../../demo2/tests/inst_tests/add_0.asm proc_hier_pbench *.v

# Run a non-pipelined basic program
old:
	wsrun.pl -prog ../tests/inst_tests/addi_0.asm proc_hier_bench *.v

# If using mobaXterm or you have X-Forwarding setup, open the waveforms in ModelSim
waves:
	vsim -view dataset=dump.wlf
check_synth:
	../scripts/check_synth.sh
d:
	vim diff.ptrace
i:
	vim ../../demo2/tests/inst_tests/siic_0.asm
v:
	vim verilogsim.ptrace
a:	
	vim archsim.ptrace
todo:
	../scripts/todo.sh
