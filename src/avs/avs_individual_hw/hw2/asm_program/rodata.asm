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
        
    format_string:
        .string "%s"
        
    file_read:
        .string "r"
        
    file_write:
        .string "w"
        
    flag_file:
        .string "-f"
        
    console_read_string:
        .string "Enter your string: "
        
    console_invalid_string:
        .string "Empty string\n"
        
    console_seq_len:
        .string "Enter sequence length: "
        
    console_invalid_seq_len:
        .string "Sequence length can't be less than 1\n"
        
    console_invalid_seq_len_g:
        .string "Sequence length can't be greater than string size\n"
    
    console_notfound_seq:
        .string "Couldn't find sequence of given length\n"
    
    console_found_seq:
        .string "Found sequence: %s\n"
        
    file_failed_reading:
        .string "Failed to read from file\n"
        
    generate_wrong_size:
        .string "Failed to generate string and find sequence size\n" 
        
    generate_string_smalller_size:
        .string "Generated string is smaller than generated sequence length, aborting\n"
        
    generated_failed:
        .string "Failed to generate array\n"
     
    generate_seq_not_found:
        .string "Couldn't find sequence of given length for generated string\n"
     
    console_failed:
        .string "Failed to read array from console\n"
        
    generated_file_name:
        .string "generated_string.txt"
        
    generated_seq_file_name:
        .string "sequence.txt"
    
    cpu_clock_const:
        .quad 4696837146684686336
        
    