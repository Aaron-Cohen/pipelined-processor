#!/bin/sh
cd ../synthesis/
grep --color=always -s "slack (VIOLATED)" ./timing_report.txt
cd ../scripts/
