#include <stdio.h>
#include <malloc.h>

unsigned long* read_array(unsigned long size) {
    unsigned long* array = malloc(size * 8);
    unsigned long current_value;
    for (unsigned long i = 0; i < size; i++) {
        scanf("%lu", &current_value);
        array[i] = current_value;
    }

    return array;
}

unsigned long* transform_array(unsigned long* array, unsigned long size) {
    unsigned long* transformed_array = malloc(size * 8);
    unsigned long array_index = 1;
    unsigned long array_transform_index = 0;
    while (array_index < size) {
        transformed_array[array_transform_index] = array[array_index];
        array_index += 2;
        array_transform_index++;
    }

    array_index = 0;
    array_transform_index = size / 2;
    while (array_index < size) {
        transformed_array[array_transform_index] = array[array_index];
        array_index += 2;
        array_transform_index++;
    }

    return transformed_array;
}

void print_array(unsigned long* array, unsigned long size) {
    printf("Array: ");
    for (unsigned long i = 0; i < size; i++) {
        printf("%lu ", array[i]);
    }

    printf("\n");
}

int main() {
    printf("Enter array size: ");
    unsigned long size = 0;
    scanf("%lu", &size);
    unsigned long* array = read_array(size);
    unsigned long* transformed_array = transform_array(array, size);
    print_array(transformed_array, size);

    free(array);
    free(transformed_array);
    return 0;
}
