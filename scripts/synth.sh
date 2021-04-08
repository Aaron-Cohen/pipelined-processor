#!/bin/sh
clear

echo "\033[0;36mBeginning synthesis\33[0m"
cd ..
rm -rf synthesis
cd verilog
rm -rf synth/
rm -f log.of.synthesis
synth.pl --list=list.txt --type=proc --cmd=synth --top=proc --f=fetch --d=decode --e=exec --m=memory --wb=writeback | tee log.of.synthesis
mv ./synth ../synthesis

# Now that console is no longer being written to, show the test failures
grep --color=always -s "Latch" log.of.synthesis
rm -f log.of.synthesis
