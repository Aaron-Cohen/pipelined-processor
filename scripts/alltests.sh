#!/bin/sh
clear

# Run all tests, rename output summaries so they are not overwritten
rm handin.time
echo "Began at" > handin.time
\date >> handin.time
echo "\033[0;36mPlease keep in mind that this process will take a very long time. It may appear as if the terminal is hanging\33[0m"
cd ../verilog
rm -f *summary.log

wsrun.pl -brief -pipe -list ../../demo2/tests/inst_tests/all.list proc_hier_pbench *.v
mv summary.log simple.summary.log

wsrun.pl -brief -pipe -list ../../demo2/tests/rand_simple/all.list proc_hier_pbench *.v
mv summary.log rand_simple.summary.log

wsrun.pl -brief -pipe -list ../../demo2/tests/rand_ctrl/all.list proc_hier_pbench *.v
mv summary.log rand_ctrl.summary.log

wsrun.pl -brief -pipe -list ../../demo2/tests/rand_mem/all.list proc_hier_pbench *.v
mv summary.log rand_mem.summary.log

wsrun.pl -brief -pipe -list ../../demo2/tests/rand_complex/all.list proc_hier_pbench *.v
mv summary.log rand_complex.summary.log

wsrun.pl -brief -pipe -list ../../demo2/tests/complex_demo1/all.list proc_hier_pbench *.v
mv summary.log complex_demo1.summary.log

wsrun.pl -brief -pipe -list ../../demo2/tests/complex_demo2/all.list proc_hier_pbench *.v
mv summary.log complex_demo2.summary.log

# Assemble retained summaries in summary folder
cd ..
rm -rf summary
mkdir summary
mv ./verilog/*.summary.log ./summary/
cd ./scripts/
findfail.sh

echo "\nEnded at" >> handin.time
\date >> handin.time
cat handin.time
