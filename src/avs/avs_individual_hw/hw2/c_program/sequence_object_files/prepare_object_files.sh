#!/bin/bash
echo "Started preparing sequence object files with different optimization flags..."
gcc -c sequence_C_st.c -o sequence_C_st.o
gcc -O0 -c sequence_C_O0.c -o sequence_C_O0.o
gcc -O1 -c sequence_C_O1.c -o sequence_C_O1.o
gcc -O2 -c sequence_C_O2.c -o sequence_C_O2.o
gcc -O3 -c sequence_C_O3.c -o sequence_C_O3.o
gcc -Ofast -c sequence_C_Ofast.c -o sequence_C_Ofast.o
echo "Finished successfully!"