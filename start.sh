#!/bin/bash

#title           : start.sh
#description     : Materiał z Strefy Kursów - Kurs Bash:
#                   Skryp ten instaluje i konfiguruje oprogramowanie takie jak apache, php mysql, proftp, wordpress, phpmyadmin.
#author		     : Piotr "TheRealMamuth" Kośka
#copyright       : Strefa Kursów
#date            : 25.05.2018
#version         : v1.0   
#usage		     : sudo ./start.sh
#notes           : none
#bash_version    : 4.4.12(1)-release
#editor          : visual studio code
#==============================================================================

# Skrypt ten pozwoli nam zainstalować co tylko bedziemy chcieli.

# zmienne globalne

# FUNKCJE START
# funckje zdalne

. ./lib/my_function.sh
# funkcje lokalne 

function main () {
    # instalacj apakietów i usług.
    install_package unzip apache2 php7.0 libapache2-mod-php7.0 php7.0-mysql proftpd openssl perl libcups2 samba samba-common cups
    install_package mysql-server
    # sudo mysql_secure_installationr - nie potrzebne (w ubuntu 18.04 odkomentuj).
    # instalacja phpmyadmin.
    install_package phpmyadmin

    # konfiguracja apache2 php mysql proftp.
    configure_www_ftp_server

    # konfiguracja katalogów pod www.
    www_set

    # instalacja wordpres automatyczna.
    wp_install root User12345 user User12345
}

# FUNKCJE END

# main - głowny skrypt ---------------------------------------------------------------------------------------------
main $1 $2