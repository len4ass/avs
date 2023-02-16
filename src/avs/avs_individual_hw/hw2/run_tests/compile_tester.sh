#!/bin/bash
g++ -std=c++2a run_tests.cpp sequence_asm.o sequence_C_st.o sequence_C_O0.o sequence_C_O1.o sequence_C_O2.o sequence_C_O3.o sequence_C_Ofast.o -o run_tests