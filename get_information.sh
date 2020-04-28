#!/bin/bash

echo "No siema ziomeczku: "
echo -n "Jakie jest twoje imie?:"
read imie
echo ""
echo -n "jakie jest twoje nazwisko?:"
read nazwisko
echo "A wiec Twoje imie to: ${imie} a nazwisko to: ${nazwisko} mozemy przejsc dalej..."


echo -ne "Co bys chcial zrobic? Mozliwe opcje to: \n1.Start serwera, \n2.Stop serwera, \n3.Restart serwera, \n4.Detonacja maszyny na ktorej jest serwer z uprzednim wyslaniem loginu uzytkonika, ktory sie tego dopuscil do kadry kierowniczej. \nWybierz madrze, pozdrawiam."