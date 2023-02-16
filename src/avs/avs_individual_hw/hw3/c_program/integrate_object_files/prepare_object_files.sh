#!/bin/bash
echo "Started preparing integrate object files with different optimization flags..."
gcc -c integrate_C_st.c -o integrate_C_st.o
gcc -O0 -c integrate_C_O0.c -o integrate_C_O0.o
gcc -O1 -c integrate_C_O1.c -o integrate_C_O1.o
gcc -O2 -c integrate_C_O2.c -o integrate_C_O2.o
gcc -O3 -c integrate_C_O3.c -o integrate_C_O3.o
gcc -Ofast -c integrate_C_Ofast.c -o integrate_C_Ofast.o
echo "Finished successfully!"