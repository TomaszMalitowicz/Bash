#!/bin/bash

#zmienna


x=10
y=5

echo "x=${x}, y=$y"
read -n 1 -s -r -p "Nacisnij dowolny przycisk aby kontynuowac..."

#dodawanie

echo "dodawanie"
wynik=$(( x + y ))
echo "1. $x + $y = $wynik"
expr $x + $y
read -n 1 -s -r -p "Nacisnij dowolny przycisk aby konynuowac..."

#Odejmowanie.
echo "Odejmowanie"
wynik=$(( x - y ))
echo "2. $x - $y = $wynik"
expr $x - $y
read -n 1 -s -r -p "Nacisnij dowolny przycisk aby kontynowac..."

#Dzielenie
echo "Dzielenie"
wynik=$(( x / y ))
echo "3. $x / $y = $wynik"
expr $x / $y
read -n 1 -s -r -p "Nacisnij dowolny przycik aby kontynowac..."

#Mnozenie
echo "Mnozenie"
wynik=$(( x * y ))
echo "4. $x * $y = $wynik"
expr $x \* $y
read -n 1 -s -r -p "nacisnij dowolny klawisz aby kontynuowac..."

#Modulo
echo "Modulo"
wynik=$(( x % y ))
echo "5. $x % $y = $wynik"
expr $x % $y
read -n 1 -s -r -p "Nacisnij downolny klawisz aby kontynowac..."

#Potegowanie
echo "Potegowanie"
wynik=$(( x ** y ))
echo "6. $x ** $y = $wynik"
expr $x ** $y
read -n 1 -s -r -p "nacisnij dowolny klawisz aby kontynuowac..."
