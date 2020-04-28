#!/bin/bash

#Prosta gra w zgadywanie liczb.

randomnum=$(( ( RANDOM % 10) +1 )) #szukana liczba

#instrukcja warunkowa.

if [ "$1" -eq "$randomnum" ] ; then
    echo "Zgadles szukana liczba to $randomnum"
else
    echo -n "Nie zgadles liczby, masz dodatkowa probe. Podaj swoja liczbe: "
    read newnumber
    if [ "$newnumber" -eq "$randomnum" ] ; then
        echo "Zgadles szukana liczbe $randomnum"
    elif [ "$newnumber" -lt "$randomnum" ] ; then
        echo -n "Otrzymales trzecia probe. Twoja liczba jest mniejsza od szukanej. Podaj swoja liczbe: "
        read newnumber
        if [ "$newnumber" -eq "$randomnum" ] ; then
            echo "Zgadles szukana liczbe $randomnum"
        fi
    fi
fi



echo "Twoja liczba to: $1, $newnumber a szukana to: $randomnum"
echo "-------------------------------------------------------"