#!/bin/bash

username=$1
password=$2

echo "Nazwa uzytkownika $username"
echo "Haslo uzytkownika $username to: $password"
echo "Nastapi polaczenie do serwera po ssh ${username}@10.10.10.10 --password $password"
echo "Trwa laczenie..."
echo "Polaczenie nawiazane. Witaj $username"