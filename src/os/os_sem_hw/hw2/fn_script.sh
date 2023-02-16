#!/bin/bash
# Объявляем функцию
check_if_even () {
  # Сохраняем в переменную остаток от деления переданного параметра в фукнцию
  local a=$(($1 % 2))
  # Если остаток от деления на два 0, то переданное число четное
  # Иначе нечетное
  if [[ $a == 0 ]]; then
    echo "Your value is even"
  else
    echo "Your value is odd"
  fi
}

# Просим ввести число
echo "Enter the value you want to check for oddness"
read val

# Вызываем функцию, передав в качестве параметра введенное число
check_if_even $val
