#!/bin/bash
echo "Started compiling c_program with different optimization flags..."
gcc c_program.c -o c_program
gcc c_program.c -O0 -o c_program_O0
gcc c_program.c -O1 -o c_program_O1
gcc c_program.c -O2 -o c_program_O2
gcc c_program.c -O3 -o c_program_O3
gcc c_program.c -Ofast -o c_program_Ofast
gcc c_program.c -Os -o c_program_Os
echo "Finished successfully!"



