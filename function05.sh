#!/bin/bash

function operacje () {

    liczba1=$l1
    liczba2=$l2
    echo "Nasze liczby to $liczba1 i $liczba2"
    function dodawanie () {
        echo "Wynik dodawania liczby $liczba1 + $liczba2 = $(( $liczba1 + $liczba2 ))"
    }
    function odejmowanie () {
        echo "Wynik odejmowania liczby $liczba1 - $liczba2 = $(( $liczba1 - $liczba2 ))"
    }

}
function main () {
    echo "podaj pierwsza liczbe"
    read cyfra1
    echo "podaj druga liczbe"
    read cyfra2
    l1=$cyfra1
    l2=$cyfra2
    operacje $l1 $l2
    echo -n "Co chcesz z tymi liczbami zrobic ( + dodaj, - odejmij): "; read akcja
    if [ "$akcja" = "+" ]; then
        dodawanie
    fi
    if [ "$akcja" = "-" ]; then
        odejmowanie
    fi
}

main $l1 $l2