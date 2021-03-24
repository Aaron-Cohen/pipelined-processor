#!/bin/sh
clear

# Run all tests, rename output summaries so they are not overwritten
rm handin.time
echo "Began at" > handin.time
\date >> handin.time
echo "\033[0;36mPlease keep in mind that this process will take a very long time. It may appear as if the terminal is hanging\33[0m"
cd ../verilog
rm -f *summary.log
wsrun.pl -brief -list ../tests/inst_tests/all.list proc_hier_bench *.v
mv summary.log simple.summary.log
wsrun.pl -brief -list ../tests/rand_simple/all.list proc_hier_bench *.v
mv summary.log rand_simple.summary.log
wsrun.pl -brief -list ../tests/rand_ctrl/all.list proc_hier_bench *.v
mv summary.log rand_ctrl.summary.log
wsrun.pl -brief -list ../tests/rand_mem/all.list proc_hier_bench *.v
mv summary.log rand_mem.summary.log
wsrun.pl -brief -list ../tests/rand_complex/all.list proc_hier_bench *.v
mv summary.log rand_complex.summary.log
wsrun.pl -brief -list ../tests/complex_demo1/all.list proc_hier_bench *.v
mv summary.log complex.summary.log

# Assemble retained summaries in summary golder
cd ..
rm -rf summary
mkdir summary
mv ./verilog/*.summary.log ./summary/

# Begin synthesis
rm -rf synthesis
cd verilog
rm -rf synth/
rm -f log.of.synthesis
synth.pl --list=list.txt --type=proc --cmd=synth --top=proc --f=fetch --d=decode --e=exec --m=memory --wb=writeback | tee log.of.synthesis
mv ./synth ../synthesis

# Now that console is no longer being written to, show the test failures
grep --color=always -s "Latch" log.of.synthesis
rm -f log.of.synthesis
cd ../scripts/
vcheck_all.sh
findfail.sh
findslack.sh

echo "\nEnded at" >> handin.time
\date >> handin.time
cat handin.time
