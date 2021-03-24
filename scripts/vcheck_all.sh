#!/bin/sh
cd ../verilog
rm -f *.vcheck.out
vcheck-all.sh
rm -f clkrst.vcheck.out
rm -f *bench*.vcheck.out
rm -f *tb*.vcheck.out
rm -f *memory2c*.vcheck.out
rm -f dff.vcheck.out
cd ..
rm -rf vcheck
mkdir vcheck
cd vcheck
cp verilog/*.vcheck.out .
grep -s --color=always --exclude=Makefile -l "Line" ./*.vcheck.out
cd ../scripts
