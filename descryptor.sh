#!/bin/bash

echo -n "Podaj nzwe plikow: "; read FILENAME

exec 5<>$FILENAME

while read -r person; do
    echo "Ta osoba jest na liscie: $person"
done <&5

echo "Plik odczytany `date`" >&5