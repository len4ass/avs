typedef long long int int64;
#include <malloc.h>
#include <memory.h>

int64 check_sequence_O0(const char *sequence) {
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

char *find_sequence_O0(const char *string, int64 size, int64 sequence_length) {
    char *sequence = malloc(sequence_length + 1);
    int64 valid = 0;

    for (int64 i = 0; i < size - sequence_length + 1; ++i) {
        memcpy(sequence, string + i, sequence_length);
        sequence[sequence_length] = '\0';
        valid = check_sequence_O0(sequence);

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