build:
	make basic
fail:
	clear
	wsrun.pl -pipe -list ./fail.list proc_hier_pbench *.v
one:
	clear
	wsrun.pl -pipe -list ./one.list proc_hier_pbench *.v

all1:
	clear
	wsrun.pl -pipe -list ../../demo2/tests/inst_tests/part1.list proc_hier_pbench *.v

all2:
	clear
	wsrun.pl -pipe -list ../../demo2/tests/inst_tests/part4.list proc_hier_pbench *.v

all3:
	clear
	wsrun.pl -pipe -list ../../demo2/tests/inst_tests/part3.list proc_hier_pbench *.v
all4:
	clear
	wsrun.pl -pipe -list ../../demo2/tests/inst_tests/all.list proc_hier_pbench *.v

# Basic Pipelined program
basic:
	wsrun.pl -pipe -prog ../../demo2/tests/inst_tests/add_0.asm proc_hier_pbench *.v

# Run a non-pipelined basic program
old:
	wsrun.pl -prog ../tests/inst_tests/addi_0.asm proc_hier_bench *.v

# If using mobaXterm or you have X-Forwarding setup, open the waveforms in ModelSim
waves:
	vsim -view dataset=dump.wlf

p:
	vim diff.ptrace
o:
	vim ../../demo2/tests/inst_tests/jal_11.asm

todo:
	../scripts/todo.sh
