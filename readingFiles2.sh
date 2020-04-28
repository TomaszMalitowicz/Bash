#!/bin/bash

while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Tekst odczytany: $line"
done < ./lista_obecnosci.txt