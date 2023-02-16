#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

double generate_double(double lower_border, double upper_border) {
    double range = upper_border - lower_border;
    double div = RAND_MAX / range;
    return lower_border + (rand() / div);
}

double f(double a, double b, double x) {
    double l = x * x;
    return a + b * (1 / l);
}

double integrate(double a, double b, double lower, double upper) {
    int n = (int)(upper - lower) * 1000;
    double h = (upper - lower) / n;

    double result = 0;
    for (int i = 0; i < n; i++) {
        double x1 = lower + i * h;
        double x2 = lower + (i + 1) * h;
        double c = (x2 - x1) / 6;
        double par = f(a, b, x1) + 4.0 * f(a, b, 0.5 * (x1 + x2)) + f(a, b, x2);
        result += c * par;
    }

    return result;
}

void run_console() {
    double a, b;
    printf("Enter coefficient a: ");
    scanf("%lf", &a);

    printf("Enter coefficient b: ");
    scanf("%lf", &b);

    double lower, upper;
    printf("Enter lower integration bound: ");

    scanf("%lf", &lower);

    printf("Enter upper integration bound: ");
    scanf("%lf", &upper);

    if (upper < lower) {
        printf("Upper bound can't be less than lower bound\n");
        return;
    }

    double result = integrate(a, b, lower, upper);
    printf("Integration result: %.15lf\n", result);
}

void run_files(const char *input, const char *output) {
    FILE *input_handle = fopen(input, "r");
    if (input_handle == NULL) {
        printf("Failed to open the file\n");
        return;
    }

    double a, b, lower, upper;
    fscanf(input_handle, "%lf %lf %lf %lf", &a, &b, &lower, &upper);
    fclose(input_handle);

    if (upper < lower) {
        printf("Upper bound can't be less than lower bound\n");
        return;
    }

    double result = integrate(a, b, lower, upper);
    FILE *output_handle = fopen(output, "w");
    fprintf(output_handle, "%.15lf", result);
    fclose(output_handle);
}

void run_random_generated(double lower_bound, double upper_bound) {
    if (upper_bound < upper_bound) {
        printf("Upper bound can't be less than lower bound\n");
        return;
    }

    srand(time(NULL));
    if (lower_bound == 0 && upper_bound == 0) {
        lower_bound = generate_double(0, 100);
        upper_bound = generate_double(lower_bound, 100);
    }

    double a = generate_double(lower_bound, upper_bound);
    double b = generate_double(a, upper_bound);

    FILE *output_handle = fopen("generated.txt", "w");
    fprintf(output_handle, "%.15lf %.15lf %.15lf %.15lf", a, b, lower_bound, upper_bound);
    fclose(output_handle);

    double result = integrate(a, b, lower_bound, upper_bound);
    output_handle = fopen("result.txt", "w");
    fprintf(output_handle, "%.15lf", result);
    fclose(output_handle);
}

int main(int argc, const char **argv) {
    if (argc == 2) {
        run_random_generated(0, 0);
    } else if (argc == 3) {
        double right_border;
        sscanf(argv[2], "%lf", &right_border);
        run_random_generated(0, right_border);
    } else if (argc == 4) {
        if (strcmp(argv[1], "-f") != 0) {
            double left_border, right_border;
            sscanf(argv[2], "%lf", &left_border);
            sscanf(argv[3], "%lf", &right_border);
            run_random_generated(left_border, right_border);
        } else {
            run_files(argv[2], argv[3]);
        }
    } else {
        run_console();
    }

    return 0;
}
