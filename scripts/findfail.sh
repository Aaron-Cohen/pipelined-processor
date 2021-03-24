#!/bin/sh
cd ../summary/
grep --color=always -s "FAILED" ./*.summary.log
cd ../scripts/
