#!/bin/bash

function dodawanie () {
    if [ "$#" -lt 2 ]; then
        echo "podales za malo argumentow! Dodawanie [arg1] [arg2]"
    else
        echo "Witaj Uzytkowniku. Wykonamy dodawanie: "
        echo "Dodawanie: $1 + $2 = $(( $1 + $2 ))"
        echo "liczba argumentow: $#"
        echo "Nasze agrumenty: $@"
    fi
}


dodawanie 50 4