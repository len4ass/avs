typedef long long int int64_t;
typedef unsigned int uint32_t;
#include <stdio.h>
#include <malloc.h>
#include <time.h>

int64_t *read_array(int64_t size) {
    int64_t *array = malloc(size * 8);
    for (int64_t i = 0; i < size; ++i) {
        printf("Enter element: ");
        scanf("%lld", &array[i]);
    }

    return array;
}

int64_t *transform_array(int64_t *array, int64_t size) {
    int64_t *new_array = malloc(size * 8);
    int64_t i = 1;
    int64_t j = 0;
    while (j < size && i < size) {
        new_array[j] = array[i];
        ++j;
        i += 2;
    }

    i = 0;
    j = size >> 1;
    while (j < size && i < size) {
        new_array[j] = array[i];
        ++j;
        i += 2;
    }

    return new_array;
}

void print_array(int64_t *array, int64_t size, const char *message) {
    printf(message);
    for (int64_t i = 0; i < size; ++i) {
        printf(" %lld", array[i]);
    }

    printf("\n");
}

void run_console() {
    int64_t size;

    printf("Enter array size: ");
    scanf("%lld", &size);
    if (size <= 0) {
        printf("Failed to read array from console\n");
        return;
    }

    if (size > 1000000) {
        printf("Failed to read array from console\n");
        return;
    }

    int64_t *array = read_array(size);
    int64_t *transformed_array = transform_array(array, size);

    print_array(transformed_array, size, "New array:");
    print_array(array, size, "Initial array:");

    free(array);
    free(transformed_array);
}

int64_t *read_array_from_file(const char *input, int64_t *size) {
    FILE *file_handle = fopen(input, "r");
    if (file_handle == NULL) {
        return NULL;
    }

    fscanf(file_handle, "%lld", size);

    if (*size <= 0) {
        fclose(file_handle);
        return NULL;
    }

    if (*size > 1000000) {
        fclose(file_handle);
        return NULL;
    }

    int64_t *array = malloc(*size * 8);
    for (int64_t i = 0; i < *size; ++i) {
        fscanf(file_handle, " %lld", &array[i]);
    }

    fclose(file_handle);
    return array;
}

void write_array_to_file(int64_t *array, int64_t size, const char *output) {
    FILE *file_handle = fopen(output, "w");
    fprintf(file_handle, "%lld", size);
    for (int64_t i = 0; i < size; ++i) {
        fprintf(file_handle, " %lld", array[i]);
    }

    fclose(file_handle);
}


void run_files(const char *input, const char *output) {
    int64_t size;
    int64_t *array = read_array_from_file(input, &size);
    if (array == NULL) {
       printf("Failed to read array from file\n");
       return;
    }

    int64_t *new_array = transform_array(array, size);
    write_array_to_file(new_array, size, output);
    free(new_array);
    free(array);
}

int64_t* generate_array(int64_t *size) {
    time_t unix_time = time(NULL);
    srand(unix_time);

    if (*size < 0) {
        return NULL;
    }

    if (*size > 1000000) {
        return NULL;
    }

    if (*size == 0) {
        *size = rand() % 1000001;
    }

    if (*size == 0) {
        (*size)++;
    }

    int64_t *array = malloc(*size * 8);
    for (int64_t i = 0; i < *size; ++i) {
        array[i] = rand();
    }

    return array;
}

void run_random_generated(int64_t size) {
    int64_t *generated_array = generate_array(&size);
    if (generated_array == NULL) {
        printf("Failed to generate array\n");
        return;
    }

    int64_t *new_array = transform_array(generated_array, size);
    write_array_to_file(generated_array, size, "gen_array.txt");
    write_array_to_file(new_array, size, "transformed_gen_array.txt");
    free(new_array);
    free(generated_array);
}


int main(int argc, const char **argv) {
    if (argc == 2) {
        run_random_generated(0);
    } else if (argc == 3) {
        int64_t size;
        sscanf(argv[2], "%lld", &size);
        run_random_generated(size);
    } else if (argc == 4) {
        run_files(argv[2], argv[3]);
    } else {
        run_console();
    }

    return 0;
}
