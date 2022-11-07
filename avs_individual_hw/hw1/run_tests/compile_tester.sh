#!/bin/bash
g++ -std=c++2a run_tests.cpp array_func_asm.o array_func_C_st.o array_func_C_O0.o array_func_C_O1.o array_func_C_O2.o array_func_C_O3.o array_func_C_Ofast.o -o run_tests