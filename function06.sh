#!/bin/bash

function argu () {
    if [ "$#" -ge 2 ]; then
        return 0
    else
        return 1
    fi
}

function operacje () {

    liczba1=$1
    liczba2=$2
    echo "Nasze liczby to $liczba1 i $liczba2"
    function dodawanie () {
        echo "Wynik dodawania liczby $liczba1 + $liczba2 = $(( $liczba1 + $liczba2 ))"
    }
    function odejmowanie () {
        echo "Wynik odejmowania liczby $liczba1 - $liczba2 = $(( $liczba1 - $liczba2 ))"
    }

}
function main () {

    argu $1 $2
    RETURN_VAL=$?
    
        if [ $RETURN_VAL -eq 0 ]; then
    

            operacje $1 $2
            echo -n "Co chcesz z tymi liczbami zrobic ( + dodaj, - odejmij): "; read akcja
            if [ "$akcja" = "+" ]; then
                dodawanie
            fi

            if [ "$akcja" = "-" ]; then
                   odejmowanie
            fi
            exit 0
        else
            echo "Podales za malo argumnetow. Nalezy podac 2 argumenty ./function06.sh [arg1] [arg2]"
            exit 1
        fi
}


main $1 $2