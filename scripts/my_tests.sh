#!/bin/sh
clear

# Run all tests, rename output summaries so they are not overwritten
cd ../verilog
rm -f mytests.summary.log

wsrun.pl -pipe -brief -prog ../verification/mytests/jal_0.asm proc_hier_pbench *.v
cat summary.log > mytests.summary.log
wsrun.pl -pipe -brief -prog ../verification/mytests/jalr_0.asm proc_hier_pbench *.v
cat summary.log >> mytests.summary.log
wsrun.pl  -pipe -brief -prog ../verification/mytests/jr_0.asm proc_hier_pbench *.v
cat summary.log >> mytests.summary.log
wsrun.pl -pipe -brief -prog ../verification/mytests/jr_1.asm proc_hier_pbench *.v
cat summary.log >> mytests.summary.log

# Assemble retained summaries in summary folder
cd ..
mv ./verilog/*.summary.log ./verification/results/
