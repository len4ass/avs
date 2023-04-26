#include <stdio.h>
#include <stdlib.h>

int* read_text(const char *file_name, int *size) {
    FILE *file_handle = fopen(file_name, "r");
    if (file_handle == NULL) {
        return 0;
    }

    fscanf(file_handle, "%d", size);
    if (*size <= 0) {
        fclose(file_handle);
        return 0;
    }

    int *arr = (int*)malloc(sizeof(int) * (*size));
    for (int i = 0; i < *size; ++i) {
        fscanf(file_handle, " %d", &arr[i]);
    }

    fclose(file_handle);
    return arr;
}

void write_text(const char *output, const char *text) {
    FILE *file_handle = fopen(output, "w");
    fprintf(file_handle, "%s", text);
    fclose(file_handle);
}