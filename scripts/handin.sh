#!/bin/sh
clear

start_timer.sh
all_tests.sh	# Runs all tests, moves logs to summary folder
my_tests.sh	
synth.sh	# Synthesis, checks for latches.
vcheck_all.sh	# Runs all vcheck, copies to a vcheck folder
findfail.sh	# Finds failed/relax pass tests
findslack.sh	# Finds slack violations
		
# Does not find unsynthesized/zero-area cells. FYI

end_timer.sh
