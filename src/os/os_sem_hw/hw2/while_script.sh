#!/bin/bash
echo "Enter the upper bound for summation"
read upper_bound
sum=0
counter=1

# Производим суммирование от 0 до upperbound
# пока counter <= upper_bound
while [ $counter -le $upper_bound ]; do
  # Увеличиваем сумму
  sum=$(($sum + $counter))
  # Увеличиваем переменную цикла
  counter=$(($counter + 1))
done

# Выводим результат
echo "Your sum: $sum"
