#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <time.h>
#include <memory.h>

typedef long long int int64;

char *read_string(FILE *file, int64 *size) {
    if (file == NULL) {
        file = stdin;
    }

    int64 buffer_size = 1024;
    char *buffer = malloc(buffer_size);

    char current_char;
    int64 i = 0;
    while (1) {
        current_char = (char)getc(file);
        if (current_char == EOF || current_char == '\0') {
            break;
        }

        if (current_char == '\n' && file == stdin) {
            break;
        }

        buffer[i] = current_char;
        i++;

        if (i == buffer_size) {
            char *new_buffer = malloc(buffer_size * 2);
            memcpy(new_buffer, buffer, buffer_size);
            free(buffer);
            buffer = new_buffer;
            buffer_size = buffer_size * 2;
        }
    }

    if (buffer_size > i) {
        char *new_buffer = malloc(i + 1);
        memcpy(new_buffer, buffer, i);
        free(buffer);
        buffer = new_buffer;
    }

    buffer[i] = '\0';
    *size = i;

    if (i == 0) {
        free(buffer);
        return NULL;
    }

    return buffer;
}

char *generate_string(int64 *size, int64 *sequence_length) {
    time_t unix_time = time(NULL);
    srand(unix_time);
    if (*size == 0) {
        *size = rand();
    }
    *size = *size % 1000001;

    if (*sequence_length == 0) {
        *sequence_length = rand();
    }
    *sequence_length = *sequence_length % 21;

    char *string = malloc(*size + 1);
    int64 rnd;
    for (int64 i = 0; i < *size; ++i) {
        rnd = abs(rand());
        rnd = 32 + (rnd % 95);
        string[i] = (char)rnd;
    }

    string[*size] = '\0';
    return string;
}

int64 check_sequence(const char *sequence) {
    int64 i = 0;
    char current_char;
    char next_char;
    while (1) {
        if (sequence[i + 1] == '\0') {
            break;
        }

        current_char = sequence[i];
        next_char = sequence[i + 1];

        if (next_char >= current_char) {
            return 0;
        }

        i++;
    }

    return 1;
}

char *find_sequence(const char *string, int64 size, int64 sequence_length) {
    char *sequence = malloc(sequence_length + 1);
    int64 valid = 0;

    for (int64 i = 0; i < size - sequence_length + 1; ++i) {
        memcpy(sequence, string + i, sequence_length);
        sequence[sequence_length] = '\0';
        valid = check_sequence(sequence);

        if (valid == 1) {
            break;
        }
    }

    if (valid == 0) {
        free(sequence);
        return NULL;
    }

    return sequence;
}

void run_console() {
    int64 sequence_length;
    int64 size;
    printf("Enter sequence length: ");
    scanf("%lld", &sequence_length);
    getchar();
    if (sequence_length <= 0) {
        printf("Sequence length can't be less than 1\n");
        return;
    }

    printf("Enter your string: ");
    char *string = read_string(NULL, &size);
    if (string == NULL) {
        printf("Empty string\n");
        return;
    }

    if (sequence_length > size) {
        free(string);
        printf("Sequence length can't be greater than string size\n");
        return;
    }

    char *sequence = find_sequence(string, size, sequence_length);
    if (sequence == NULL) {
        free(string);
        printf("Couldn't find sequence of given length\n");
        return;
    }

    printf("Found sequence: %s\n", sequence);
    free(string);
    free(sequence);
}

void run_files(const char *input, const char *output) {
    int64 sequence_length;
    int64 size;

    FILE *file_handle = fopen(input, "r");
    if (file_handle == NULL) {
        printf("Failed to open file\n");
        return;
    }

    fscanf(file_handle, "%lld ", &sequence_length);
    if (sequence_length <= 0) {
        printf("Sequence length can't be less than 1\n");
        fclose(file_handle);
        return;
    }

    char *string = read_string(file_handle, &size);
    fclose(file_handle);
    if (string == NULL) {
        printf("Empty string\n");
        return;
    }

    if (sequence_length > size) {
        free(string);
        printf("Sequence length can't be greater than string size\n");
        return;
    }

    char *sequence = find_sequence(string, size, sequence_length);
    if (sequence == NULL) {
        free(string);
        printf("Couldn't find sequence of given length\n");
        return;
    }

    FILE *file = fopen(output, "w");
    fprintf(file, "%s", sequence);
    fclose(file);

    free(string);
    free(sequence);
}

void run_random_generated(int64 size, int64 sequence_length) {
    if (size < 0 || sequence_length < 0) {
        printf("Failed to generate string and find sequence size\n");
        return;
    }

    char *string = generate_string(&size, &sequence_length);
    if (sequence_length > size) {
        free(string);
        printf("Generated string is smaller than generated sequence length, aborting\n");
        return;
    }

    char *sequence = find_sequence(string, size, sequence_length);
    if (sequence == NULL) {
        free(string);
        printf("Couldn't find sequence of given length for generated string\n");
        return;
    }

    FILE *file = fopen("generated_string.txt", "w");
    fprintf(file, "%s", string);
    fclose(file);

    FILE *file_handle = fopen("sequence.txt", "w");
    fprintf(file_handle, "%s", sequence);
    fclose(file_handle);

    free(string);
    free(sequence);
}

int main(int argc, const char **argv) {
    if (argc == 2) {
        run_random_generated(0, 0);
    } else if (argc == 3) {
        int64 size;
        sscanf(argv[2], "%lld", &size);
        run_random_generated(size, 0);
    } else if (argc == 4) {
        if (strcmp(argv[1], "-f") != 0) {
            int64 size, sequence_length;
            sscanf(argv[2], "%lld", &size);
            sscanf(argv[3], "%lld", &sequence_length);
            run_random_generated(size, sequence_length);
        } else {
            run_files(argv[2], argv[3]);
        }
    } else {
        run_console();
    }

    return 0;
}
