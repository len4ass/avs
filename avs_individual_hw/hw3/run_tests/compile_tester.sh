#!/bin/bash
g++ -std=c++2a run_tests.cpp integrate_asm.o integrate_C_st.o integrate_C_O0.o integrate_C_O1.o integrate_C_O2.o integrate_C_O3.o integrate_C_Ofast.o -o run_tests