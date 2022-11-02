cmake_minimum_required(VERSION 3.21)
project(array_func_object_files C)

set(CMAKE_C_STANDARD 11)

add_executable(array_func_object_files
        sequence_C_O0.c
        sequence_C_O1.c
        sequence_C_O2.c
        sequence_C_O3.c
        sequence_C_Ofast.c
        sequence_C_st.c)
