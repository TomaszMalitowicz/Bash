#!/bin/bash

#title           : comment
#description     : Materiał z Strefy Kursów - Kurs Bash - dodaje uzytkownika do suystemu (nie potzreuje dodatkowych ustawien)
#author		     : Piotr "TheRealMamuth" Kośka
#copyright       : Strefa Kursów
#date            : 25.05.2018
#version         : v1.0   
#usage		     : sudo ./createuser.sh
#notes           :
#bash_version    : 4.4.12(1)-release
#editor          : visual studio code
#==============================================================================

# zmienne globalne

# FUNKCJE START
# funckje zdalne

. ./lib/my_function.sh
# funkcje lokalne 

function main () {
    if [ $(id -u) -eq 0 ]; then
        # Wykonujesz operacje jako super użytkownik.
        create_special_user $1 $2
    else
        # Nie podniosłeś uprawnień. Nie wykonam nic.
        show_message WARRNING "Nie jesteś uprawnionym użytkownikiem. Tylko root może dodać nowego użytkownika."
    fi
}

# FUNKCJE END

# main - głowny skrypt ---------------------------------------------------------------------------------------------
main