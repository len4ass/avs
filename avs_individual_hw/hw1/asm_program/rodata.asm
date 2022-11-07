.section .rodata
    msg_input_size:
        .string "Enter array size: "

    input_element:
        .string "Enter element: "

    output_array_initial:
        .string "Initial array: "

    output_array_transformed:
        .string "New array: "

    new_line:
        .string "\n"

    format_output_qword:
        .string "%lld "

    format_input_qword:
        .string "%lld"
        
    format_file_input_element:
        .string " %lld"
    
    format_float:
        .string "%f s\n"
        
    file_read:
        .string "r"
        
    file_write:
        .string "w"
        
    file_failed_reading:
        .string "Failed to read from file\n"
        
    generated_failed:
        .string "Failed to generate array\n"
     
    console_failed:
        .string "Failed to read array from console\n"
        
    generated_file_name:
        .string "gen_array.txt"
        
    generated_transformed_file_name:
        .string "transformed_gen_array.txt"
    
    cpu_clock_const:
        .quad 4696837146684686336
        
    