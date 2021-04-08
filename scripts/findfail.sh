#!/bin/sh
cd ../verification/
grep --color=always -s "FAILED" ./*.summary.log
grep --color=always -s "RELAX" ./*.summary.log
cd ../scripts/
