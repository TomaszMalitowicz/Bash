#!/bin/bash

echo "Wybierz opcje: "
select i in X Y Z Exit; do
    case $i in
        "X" ) echo "Wybrales X" ;;
        "Y" ) echo "Wybrales Y" ;;
        "Z" ) echo "Wybrales Z" ;;
        "Exit" ) echo; exit;;
        *) echo "Wybierz opcje z listy" ;;
    esac
done