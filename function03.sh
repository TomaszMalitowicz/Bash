#!/bin/bash

#zmienna
zm="10"

#function
function dodawanie () {
    # zmienna
    local zm1="5"
    zm2="10"
    zm3="30"
    zm4="45"
    echo "Wynik dodawania: $(( $zm1 + $zm2 ))"
}
echo "$zm4"
dodawanie
echo "$zm1"
echo "$zm3"
