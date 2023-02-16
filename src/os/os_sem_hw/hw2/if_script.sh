#!/bin/bash
echo "Enter your age: "
read age

# Проверяем, чтобы возраст нашего пользователя был больше или равен 18
if [[ $age -ge 18 ]]; then
  echo "You are allowed here."
else 
  echo "Nah dude, you're a minor."
fi

