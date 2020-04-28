#!/bin/bash

file=./users_info.txt

IFS="|"

while read -r name surname address city; do
    echo "Pan $name"
    echo "Nazwisko $surname"
    echo "Zamieszkaly przy $address"
    echo "Zaprasza do odwiedzenia miasta ${city}" 
    echo "Z wyrazami szacunku $name ${surname}."
    echo ""
done < "$file"