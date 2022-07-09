#!/usr/bin/env bash

# Bash script to run GHDL simulation
# Run all steps (except waves) when no command line arguments
# Run a single step with arguments clean, compile, sim and waves

if [[ "$#" == "0"  ]]; then
  echo "Example: $0 dpram.filelist"
else
  source $1
fi


if [[ "$#" == "1"  ]]; then
  echo "Running steps 'clean', 'compile' and 'sim'"
  echo "Use '$0 waves' to view simulaton waveform"
fi

if [[ "$2" == "clean" || "$#" == "1"  ]]; then
  echo "CLEAN"
  rm -f work-*.cf *.vcd
fi


if [[ "$2" == "compile" || "$#" == "1"  ]]; then
  echo "COMPILE DESIGN"
  ghdl -a --std=08 $filelist
  ghdl -e --std=08 tb
fi


if [[ "$2" == "sim" || "$#" == "1"  ]]; then
  echo "RUN SIMULATION"
  ghdl -r --std=08 tb --vcd=waves.vcd
fi


if [[ "$2" == "waves" ]]; then
  echo "VIEW WAVES"
  gtkwave waves.vcd
fi

