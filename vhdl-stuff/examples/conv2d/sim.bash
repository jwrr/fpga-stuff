#!/usr/bin/env bash

# Bash script to run GHDL simulation
# Run all steps (except waves) when no command line arguments
# Run a single step with arguments clean, compile, sim and waves

# If not args then print error message and quit
if [[ "$#" == "0"  ]]; then
  echo "Example: $0 filelists/dpram.filelist"
else
  source $1
fi

# If one arg then it is the filelist, and all steps
# will be run.
if [[ "$#" == "1"  ]]; then
  echo "Running steps 'clean', 'compile' and 'sim'"
  echo "Use '$0 waves' to view simulaton waveform"
fi

# If 2nd arg is 'clean' then delete work and wave files.
if [[ "$2" == "clean" || "$#" == "1"  ]]; then
  echo "CLEAN"
  rm -f work-*.cf *.vcd
fi

# If 2nd arg is 'compile' then analyze and elaborate all files
if [[ "$2" == "compile" || "$#" == "1"  ]]; then
  echo "COMPILE DESIGN"
  ghdl -a --std=08 $filelist
  ghdl -e --std=08 tb
fi

# If 2nd arg is 'sim' then run the simulation
if [[ "$2" == "sim" || "$#" == "1"  ]]; then
  echo "RUN SIMULATION"
  ghdl -r --std=08 tb --vcd=waves.vcd
fi

# If the 2nd arg is "waves" then view the waves with GTKWave
if [[ "$2" == "waves" ]]; then
  echo "VIEW WAVES"
  gtkwave waves.vcd
fi

