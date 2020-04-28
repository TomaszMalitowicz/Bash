#!/bin/bash

declare -i number
echo -n "Podaj liczbe: "; read number

if [ $number -eq 0 ] || [ $number -eq 10 ]; then
    echo "Podales zabroniona liczbe: $number"
    exit $number
elif [ $number -ge 5 ] && [ $number -le 20 ]; then
    echo "Liczba ktora wybrales: $number jest wieksza lub rowna 5, lecz napewno nie jest rowna 10 oraz jest mniejsza lub rowna 20."
fi