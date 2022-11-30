#include <cstring>
#include <iostream>
#include <pthread.h>
#include <queue>
#include <random>
#include <set>
#include <algorithm>

// Создаем глобальную переменную, в которой будет храниться указатель на поток к файлу, в который будет происходить вывод последовательности обработки
static FILE *out;

// Создаем глобальную переменную, в которой после исполнения программы будет лежать количество обслуженных покупателей
static int customers_processed_count = 0;

// Создаем глобальную переменную мьютекс, чтобы заблокировать одновременный доступ двух тредов к нашему потоку
pthread_mutex_t mutex;

/**
 * Класс инкапсулирующий идентификатор покупателя
 */
class Customer {
public:
    /**
     * Конструктор, принимающий индентификатор покупателя
     * @param customer_id
     */
    explicit Customer(int customer_id) {
        this->customer_id = customer_id;
    }

    /**
     * Отдает идентификатор покупателя
     * @return Индендификатор покупателя
     */
    int get_id() const {
        return customer_id;
    }

    /**
     * Конвертирует покупателя в строку
     * @return Строчное представление покупателя
     */
    std::string to_string() const {
        return "customer with ID=" + std::to_string(customer_id);
    }

private:
    int customer_id;
};

/**
 * Класс содержащий очередь из покупателей и номер очереди
 */
class Queue {
public:
    /**
     * Конструктор, принимающий очередь покупателей и ее номер
     * @param customer_id
     */
    Queue(std::queue<Customer> customer_queue, int queue_id) {
        this->customer_queue = std::move(customer_queue);
        this->queue_id = queue_id;
    }

    /**
     * Проверяет, является ли очередь пустой
     * @return true, если очередь пуста, иначе false
     */
    bool is_empty() const {
        return customer_queue.empty();
    }

    /**
     * Производит удаление покупателя из очереди (обслуживание)
     * @return Строка с информацией о покупателе, прошедшем очередь под номером queue_id
     */
    std::string pop() {
        Customer first_out = customer_queue.front();
        customer_queue.pop();
        return "[Queue " + std::to_string(queue_id) + "] " + "Served to " + first_out.to_string() + '\n';
    }

private:
    int queue_id;
    std::queue<Customer> customer_queue;
};

/**
 * Метод, который обслуживает покупателей в переданной очереди и выводит в файл строку с информацией о покупателе и очереди
 * @param queue Указатель на очередь
 */
void simulate_queue(void *queue) {
    auto *proper_queue = static_cast<Queue*>(queue);

    // Пока очередь не пуста, произоводим обслуживание
    while (!proper_queue->is_empty()) {
        // Производим обслуживание в очереди
        auto str = proper_queue->pop();

        // Блокируем мьютекс, чтобы корректно выводить информацию в файл (не было битвы за ресурсы)
        pthread_mutex_lock(&mutex);
            // Увеличиваем количество обслуженных покупаталей
            ++customers_processed_count;

            // Выводим строковое представление обслуженного покупателя в файл
            fprintf(out, "%s", str.data());
        pthread_mutex_unlock(&mutex);
        // Разблокируем мьютекс как только осуществим вывод
    }
}

/**
 * Запускает две параллельных очереди
 * @param first_queue Первая очередь
 * @param second_queue Вторая очередь
 */
void run_parallel(Queue *first_queue, Queue *second_queue) {
    pthread_t first_thread;
    pthread_t second_thread;

    // Инициализируем наш глобальный мьютекс
    pthread_mutex_init(&mutex, nullptr);

    // Создаем первый поток (поток для первой очереди)
    if (pthread_create(
            &first_thread,
            nullptr,
            reinterpret_cast<void *(*)(void *)>(simulate_queue),
            reinterpret_cast<void*>(first_queue))) {
        puts("Failed to create first thread, discarding");
        return;
    }

    // Создаем второй поток (поток для второй очереди)
    if (pthread_create(
            &second_thread,
            nullptr,
            reinterpret_cast<void *(*)(void *)>(simulate_queue),
            reinterpret_cast<void*>(second_queue))) {
        puts("Failed to create second thread, discarding");
        return;
    }

    // Производим синхронизацию потоков
    pthread_join(first_thread, nullptr);
    pthread_join(second_thread, nullptr);

    // Деструцируем мьютекс
    pthread_mutex_destroy(&mutex);

    // Выводим количество обслуженных покупателей в консоль
    printf("Served to %d customers.\n", customers_processed_count);
}

/**
 * Нормально распределенный генератор целых чисел в диапазоне [minimum, maximum]
 * @param minimum Нижняя граница генерации
 * @param maximum Верхняя граница генерации
 * @return Случайное целое число в указанных рамках, подчиняющееся закону нормального распределения
 */
int generate_int(int minimum, int maximum) {
    std::random_device random_device;
    std::mt19937 generator(random_device());
    std::uniform_int_distribution<> distribution(minimum, maximum);

    return distribution(generator);
}

/**
 * Генерирует очередь, размер который генерируется в рамках [minimum, maximum]
 * @param minimum Нижняя граница размера очереди
 * @param maximum Верхняя граница размера очереди
 * @return Очередь из покупателей
 */
std::queue<Customer> generate_queue(int minimum, int maximum) {
    // Если аргументы нулевые, то нужно подправить рамки генерации
    if (minimum == 0) {
        minimum = 2;
    }

    if (maximum == 0) {
        maximum = 1000000;
    }

    // Создаем очередь и генерируем ее размер
    std::queue<Customer> queue;
    int size = generate_int(minimum, maximum);

    // Создаем вектор и заполняем его числами [1, size] - это идентификаторы покупателей
    std::vector<int> numbers(size);
    for (int i = 0; i < size; ++i) {
        numbers[i] = i + 1;
    }

    // Перемешиваем идентификаторы покупателей и наполняем ими очередь
    std::shuffle(numbers.begin(), numbers.end(), std::mt19937(std::random_device()()));
    for (int i = 0; i < size; ++i) {
        queue.push(Customer(numbers[i]));
    }

    return queue;
}

/**
 * Считываает очередь с переданного указателя на поток к файлу
 * @param file_handle Поток к файлу
 * @return Очередь из покупателей
 */
std::queue<Customer> read_queue(FILE *file_handle) {
    int size;
    std::queue<Customer> customer_queue;

    // Считываем размер очереди
    fscanf(file_handle, "%d", &size);

    // Если размер меньше двух, то возвращаем пустую очередь
    if (size < 2) {
        return {};
    }

    int id;
    for (int i = 0; i < size; ++i) {
        // Считываем идентификатор очередного покупателя и добавляем его в очередь
        fscanf(file_handle, " %d", &id);
        customer_queue.push(Customer(id));
    }

    return customer_queue;
}

/**
 * Выводит очередь в формате `size id1 id2 ... id_n` в указанный поток
 * @param file_handle Поток к файлу
 * @param queue Очередь, которую нужно вывести
 */
void print_queue(FILE *file_handle, std::queue<Customer> queue) {
    // Выводим размер очереди
    fprintf(file_handle, "%llu", queue.size());

    // Выводим идентификаторы пользователей через пробел
    while (!queue.empty()) {
        fprintf(file_handle, " %d", queue.front().get_id());
        queue.pop();
    }
}

/**
 * Перераспределяет очередь между двумя (меняя переданную)
 * @param queue Очередь для перераспределения
 * @return Половина покупателей из переданной очереди
 */
std::queue<Customer> redistribute_queue(std::queue<Customer> &queue) {
    auto size = queue.size();
    std::queue<Customer> other_queue;

    // Пока размер переданной очереди больше половины изначального размера, кладем первых покупателей в новую очередь
    while (queue.size() >= size / 2) {
        other_queue.push(queue.front());
        queue.pop();
    }

    return other_queue;
}

/**
 * Запускает программу в режиме работы с консолью
 */
void run_console() {
    int size;

    // Выводим подсказку о вводе размера
    printf("Input queue size: ");
    scanf("%d", &size);

    // Если размер меньше 2, то заканчиваем исполнение
    if (size < 2) {
        puts("Queue size can't be less than two.");
        return;
    }

    // Осуществляем ввод идентификаторов
    int current_id;
    std::queue<Customer> queue;
    for (int i = 0; i < size; ++i) {
        printf("Enter id: ");
        scanf("%d", &current_id);
        queue.push(Customer(current_id));
    }

    auto second_queue = redistribute_queue(queue);
    // Формируем наши 2 очереди с номерами
    Queue f_queue(queue, 1);
    Queue s_queue(second_queue, 2);

    // Открываем поток для записи действий
    out = fopen("parallel_output.txt", "w");

    // Параллельно обслуживаем наши две очереди
    run_parallel(&f_queue, &s_queue);

    // Закрываем поток
    fclose(out);
}

/**
 * Запускает программу в режиме работы с файлами
 * @param input Название файла, в котором лежит очередь
 * @param output Название файла, в который будет производиться вывод действий
 */
void run_files(const char *input, const char *output) {
    FILE *in = fopen(input, "r");
    if (in == nullptr) {
        printf("Failed to open file - %s\n", input);
        return;
    }

    // Читаем очередь
    auto first_queue = read_queue(in);
    fclose(in);

    // Пустая очередь - завершаем исполнение
    if (first_queue.empty()) {
        puts("Failed to read queue from file");
        return;
    }

    // Кладем первую половину очереди во вторую
    auto second_queue = redistribute_queue(first_queue);

    // Формируем наши 2 очереди с номерами
    Queue f_queue(first_queue, 1);
    Queue s_queue(second_queue, 2);

    // Открываем поток для записи действий
    out = fopen(output, "w");

    // Параллельно обслуживаем наши две очереди
    run_parallel(&f_queue, &s_queue);

    // Закрываем поток
    fclose(out);
}

/**
 * Запускает программу в режиме генерации случайных данных
 * @param minimum Нижняя граница генерируемого размера очереди
 * @param maximum Верхняя граница генерируемого размера очереди
 */
void run_random_generated(int minimum, int maximum) {
    if (minimum < 2 || maximum < 2) {
        puts("Generation bounds can't be less than two.");
        return;
    }

    if (minimum > maximum) {
        puts("Minimum can't be bigger than maximum.");
        return;
    }

    if (minimum > 1000000 || maximum > 1000000) {
        puts("Bounds for generation are too large.");
        return;
    }

    // Генерируем всю очередь и выводим ее в файл
    auto first_queue = generate_queue(minimum, maximum);
    FILE *out_queue = fopen("generated_queue.txt", "w");
    print_queue(out_queue, first_queue);

    // Кладем первую половину очереди во вторую
    auto second_queue = redistribute_queue(first_queue);

    // Формируем наши 2 очереди с номерами
    Queue f_queue(first_queue, 1);
    Queue s_queue(second_queue, 2);

    // Открываем поток для записи действий
    out = fopen("parallel_output.txt", "w");

    // Параллельно обслуживаем наши две очереди
    run_parallel(&f_queue, &s_queue);

    // Закрываем поток
    fclose(out);
}

/**
 * Входная точка в программу
 * @param argc Количество переданных аргументов командной строки
 * @param argv Указатель на массив из строковых представлений аргументов командной строки
 * @return 0, если программа завершилась успешно, иначе другой код
 */
int main(int argc, const char **argv) {
    if (argc == 2) {
        run_random_generated(0, 0);
    } else if (argc == 3) {
        int maximum;
        sscanf(argv[2], "%d", &maximum);
        run_random_generated(2, maximum);
    } else if (argc == 4) {
        if (strcmp(argv[1], "-f") != 0) {
            int minimum, maximum;
            sscanf(argv[2], "%d", &minimum);
            sscanf(argv[3], "%d", &maximum);
            run_random_generated(minimum, maximum);
        } else {
            run_files(argv[2], argv[3]);
        }
    } else {
        run_console();
    }
}
