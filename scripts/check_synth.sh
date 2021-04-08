#!/bin/sh
clear
cd ../verilog/
synth.pl --list=list.txt --type=proc --cmd=check --top=proc --f=fetch --d=decode --e=exec --m=memory --wb=writeback | tee make.check.output
grep -s --color=always "Latch" ./make.check.output || true
grep -s --color=always "Unable to resolve reference" ./make.check.output || true
grep -s --color=always "unresolved references" ./make.check.output || true
grep -s --color=always "is redefined" ./make.check.output || true
rm -f make.check.output 
