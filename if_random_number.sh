#!/bin/bash

#Prosta gra w zgadywanie liczb.

randomnum=$(( ( RANDOM % 10) +1 )) #szukana liczba

#instrukcja warunkowa.

if [ "$1" -eq "$randomnum" ] ; then
    echo "Zgadles szukana liczba to $randomnum"
fi

echo "Twoja liczba to: $1 a szukana to: $randomnum"
echo "--------------------------------------------"