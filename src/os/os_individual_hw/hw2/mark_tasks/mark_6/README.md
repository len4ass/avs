# ИДЗ №2, программа на оценку 6

### Критерии
**Выполнены все критерии для получения оценки 6:**
1) Используются семафоры в стандарте UNIX SYSTEM V, а также разделяемая память в стандарте UNIX SYSTEM V.
2) Для задания количества процессов используется аргумент командной строки `./main proc_count`
3) Тестовые наборы предоставлены в этой [папке](tests) в виде файлов `input.txt`, там же и лежат корректные ответы в виде файлов `output.txt`

### Схема работы
Массив для декодирования равномерно распределяется между дочерними процессами. Минимальное количество дочерних процессов - 1, максимальное - 32.
Если размер массива для декодирования меньше количества процессов, то вся работа выполнится последовательно последним дочерним процессом.

### Как пользоваться
Если вы желаете скомпилировать бинарный файл самостоятельно, то следует прописать следующие команды в терминале, находясь в папке [source_code](source_code):
1) `gcc main.c -o main`

Запустите бинарный файл `main` в папке `binaries` с аргументами командной строки. Учтите, что файл ввода должен существовать, иначе вы получите ошибку.\
Пример: `./main proc_count`. `proc_count` - количество дочерних процессов (от 1 до 32).

Ввод осуществляется из файла `input.txt`, убедитесь что он существует в той же папке, что бинарный файл. Вывод ответа осуществляется в файл `output.txt`.

#### Формат ввода
`size arg_1 .. arg_k`, где `size` количество символов для декодирования, `arg_i` - i-ый символ для декодирования. `arg_i` должно быть целым числом и берется по модулю 26. `size` должно быть больше 0. 

### Пример работы
![Пример](Пример%20работы.png)