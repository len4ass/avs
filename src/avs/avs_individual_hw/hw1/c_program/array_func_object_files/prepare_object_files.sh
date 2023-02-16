#!/bin/bash
echo "Started preparing array function object files with different optimization flags..."
gcc -c array_func_C_st.c -o array_func_C_st.o
gcc -O0 -c array_func_C_O0.c -o array_func_C_O0.o
gcc -O1 -c array_func_C_O1.c -o array_func_C_O1.o
gcc -O2 -c array_func_C_O2.c -o array_func_C_O2.o
gcc -O3 -c array_func_C_O3.c -o array_func_C_O3.o
gcc -Ofast -c array_func_C_Ofast.c -o array_func_C_Ofast.o
echo "Finished successfully!"