typedef long long int int64_t;
#include <malloc.h>

int64_t *transform_array_O0(int64_t *array, int64_t size) {
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
