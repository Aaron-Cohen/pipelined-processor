build:
	make specific
alu:
	clear
	wsrun.pl alu_hier_bench *.v 
shifter:
	clear
	wsrun.pl shifter_hier_bench *.v

# Runs all inst_tests
all1:
	clear	
	wsrun.pl -brief -list ../tests/inst_tests/all.list proc_hier_bench *.v

# Runs all rand_simple tests
all2:
	clear
	wsrun.pl -brief -list ../tests/rand_simple/all.list proc_hier_bench *.v

# Runs all rand_ctrl tests
all3:
	clear
	wsrun.pl -brief -list ../tests/rand_ctrl/all.list proc_hier_bench *.v

# Runs all rand_mem tests
all4:
	clear
	wsrun.pl -brief -list ../tests/rand_mem/all.list proc_hier_bench *.v

# Runs all rand_complex tests
all5:
	clear
	wsrun.pl -brief -list ../tests/rand_complex/all.list proc_hier_bench *.v

# Runs all complex_demo1 tests
all6:
	clear
	wsrun.pl -brief -list ../tests/complex_demo1/all.list proc_hier_bench *.v

# Runs all the tests, and writes all output to same all.test.results file (so you can search for FAIL easily)
log:
	@echo "\033[0;36mPlease keep in mind that this process will take a very long time. It may appear as if the terminal is hanging\033[0m"
	rm -f all.test.results
	wsrun.pl -brief -list ../tests/inst_tests/all.list proc_hier_bench *.v >>all.test.results
	wsrun.pl -brief -list ../tests/rand_simple/all.list proc_hier_bench *.v >>all.test.results
	wsrun.pl -brief -list ../tests/rand_ctrl/all.list proc_hier_bench *.v >>all.test.results
	wsrun.pl -brief -list ../tests/rand_mem/all.list proc_hier_bench *.v >>all.test.results
	wsrun.pl -brief -list ../tests/rand_complex/all.list proc_hier_bench *.v >>all.test.results
	wsrun.pl -brief -list ../tests/complex_demo1/all.list proc_hier_bench *.v >>all.test.results

# Runs all tests, stores outputs to a summary log for that test, synthesizes. Shows latches and failed tests.
handin:
	../scripts/handin.sh

# Put failed tests in fail.list to run them as a batch
fail: 
	clear
	wsrun.pl -list fail.list proc_hier_bench *.v

# Run a basic add test to compile all code without a lengthy runtime
basic:
	wsrun.pl -prog ../tests/inst_tests/addi_0.asm proc_hier_bench *.v

# Run specific test
specific:
	wsrun.pl -list ./one.list proc_hier_bench *.v

# If using mobaXterm or you have X-Forwarding setup, open the waveforms in ModelSim
waves:
	vsim -view dataset=dump.wlf

# Run the check script for synthesis from wiki
check:
	../scripts/check_synth.sh		

# Run the synth script from wiki
synth:
	clear
	synth.pl --list=list.txt --type=proc --cmd=synth --top=proc --f=fetch --d=decode --e=exec --m=memory --wb=writeback

# Run after synthesizing to redo synth operations
clean:
	rm -rf synth/

# Run vcheck on everything. Ignore false positives from instructor provided files
vcheck:
	../scripts/vcheck_all.sh
