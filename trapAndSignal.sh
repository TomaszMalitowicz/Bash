#!/bin/bash
clear
trap 'echo " - to exit from script click Q"' SIGINT SIGTERM SIGTSTP

while [ "$nexit" != "Q" ] && [ "$nexit" != "q" ]; do
    echo "----------------------"
    echo "Terminal servisowy"
    echo "----------------------"
    echo "1) Polaczenie z serwerem"
    echo "2) Ustawienia i konfiguracja"
    echo "3) Wczytaj ustawienia"
    echo "4) Zapisz ustawienia"
    echo "5) Resetuj ustawienia"
    echo "Q) Wyjscie."
    read nexit
    clear
done