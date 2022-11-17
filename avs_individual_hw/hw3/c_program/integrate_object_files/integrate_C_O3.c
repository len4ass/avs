double f_O3(double a, double b, double x) {
    double l = x * x;
    return a + b * (1 / l);
}

double integrate_O3(double a, double b, double lower, double upper) {
    int n = (int)(upper - lower) * 1000;
    double h = (upper - lower) / n;

    double result = 0;
    for (int i = 0; i < n; i++) {
        double x1 = lower + i * h;
        double x2 = lower + (i + 1) * h;
        double c = (x2 - x1) / 6;
        double par = f_O3(a, b, x1) + 4.0 * f_O3(a, b, 0.5 * (x1 + x2)) + f_O3(a, b, x2);
        result += c * par;
    }

    return result;
}