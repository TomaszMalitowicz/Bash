#!/bin/bash


#Raport wydajnosci systemu
raport_creator="Tomasz" #informacja kto stworzyl raport.
raport_name="wydajnosc systemu" #nazwa raportu

DATABASENAME="raporty"
DATABASEUSER="tomasz"
DATABASEPASS="password123"
STARTBASH=`date`

echo "*********************************************************************************"
echo "Raport tutul: $raport_name - utworzony $STARTBASH"
echo "Wygenerowal raport: $raport_cerator"
echo "Raport zostal zapisany w: $PWD"
echo ""
echo "Raport zostanie zapisany do $DATABASENAME"
echo "Logowanie uzytkownika $DATABASEUSER"

sleep 1
ENDBASH=`date`

echo "operacja zakonczona $ENDBASH"
echo "*********************************************************************************"