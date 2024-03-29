# ИДЗ №1, программа на оценку 8

### Критерии
**Выполнены все критерии для получения оценки 8:**
1) Используются именованные каналы для передачи данных между двумя независимыми процессами
2) Схема взаимодействия процессов изложена в этой [картинке](Схема.png)
3) Для задания имен входного и выходного файлов используются аргументы командной строки `./first_process input.txt output.txt`
4) Ввод и вывод осуществляется через системные вызовы read и write
5) Изначальный размер буфера 5000 байт, в случае со строками большей длины происходит циклическое расширение
6) Тестовые наборы предоставлены в этой [папке](tests) в виде файлов `input.txt`, там же и лежат корректные ответы в виде файлов `output.txt`

### Как пользоваться
Если вы желаете скомпилировать бинарные файлы самостоятельно, то следует прописать следующие команды в терминале, находясь в папке [source_code](source_code):
1) `gcc first_process.c -o first_process`
2) `gcc second_process.c -o second_process`

Запустите бинарный файл `first_process` в папке `binaries` с аргументами командной строки. Учтите, что файл ввода должен существовать, иначе вы получите ошибку.\
Пример: `./first_program input.txt output.txt`. `input.txt` - файл ввода, `output.txt` - файл вывода ответа.\
После этого запустите бинарный файл `second_process` (`./second_process`).\
Дождитесь окончания работы обоих процессов (это должно быть довольно таки быстро, если вводимые строки не слишком велики).

Типы ответов:
1) Ответ '0' в файле вывода означает, что строка не является палиндромом
2) Ответ '1' в файле вывода означает, что строка является палиндромом

### Пример работы
Сначала запускаем `first_process` на подготовленном файле `input.txt` с содержимым 'abba'.
![Пример работы (1)](Пример%20работы%201.png)

После в отдельном терминале запускаем `second_process` и сразу увидим, что оно отработало.
![Пример работы (2)](Пример%20работы%202.png)

Вернемся в основной терминал и увидим, что `first_process` закончил работу. Убедимся, что результат получен применив команду `cat output.txt`.
![Пример работы (3)](Пример%20работы%203.png)
