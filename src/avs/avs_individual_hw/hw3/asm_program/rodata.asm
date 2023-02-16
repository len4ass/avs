.section .rodata
    input_scan_double:
        .string "%lf"

    input_coeff_a:
        .string "Enter coefficient a: "
        
    input_coeff_b:
        .string "Enter coefficient b: "
        
    input_integral_lower_bound:
        .string "Enter lower integration bound: "
        
    input_integral_upper_bound:
        .string "Enter upper integration bound: "
        
    output_integral_result:
        .string "Integration result: %.15lf\n"
        
    error_lower_more_than_upper:
        .string "Upper bound can't be less than lower bound\n"
        
    error_fopen:
        .string "Failed to read from file\n"
        
    file_scan_input:
        .string "%lf %lf %lf %lf"
        
    file_print_output:
        .string "%.15lf"
        
    file_print_generated_output:
        .string "%.15lf %.15lf %.15lf %.15lf"
       
    file_read_flag:
        .string "r"
        
    file_write_flag:
        .string "w"
        
    random_generated_file_name:
        .string "generated.txt"
        
    random_result_file_name:
        .string "result.txt"
        
    flag_file:
        .string "-f"
    