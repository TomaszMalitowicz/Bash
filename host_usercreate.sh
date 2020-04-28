#!/usr/bin/env bash

#title           : host_usercreate.sh
#description     : Materiał z Strefy Kursów - Kurs Bash - tworzy uzytkownika przystosowanego do skryptu start.sh
#author		     : Piotr "TheRealMamuth" Kośka
#copyright       : Strefa Kursów
#date            : 25.05.2018
#version         : v1.0   
#usage		 : sudo ./host_usercreate.sh
#notes           :
#bash_version    : 4.4.12(1)-release
#editor          : visual studio code
#==============================================================================

#- Przywitanie użytkownika „welcome message” i wyświetla info 
#- ostatnie logowanie
#- ip z jakiego się logowalo
#- dzisiejsza date
logowales_z=$(last -i | grep "$SUER" | grep -v "still" | grep -m1 "" | awk '{print $2}')
z_ip=$(last -i | grep "$SUER" | grep -v "still" | grep -m1 "" | awk '{print $3}')
data_ostatniego=$(last -i | grep "$SUER" | grep -v "still" | grep -m1 "" | awk '{print $4" "$5" "$6" "$7" "$8" "$9" "$10" "$11" "$12" "$13}')
bierzaca_data=$(date +"%F")
bierzacy_czas=$(date +"%T")

# Zmienne SQL 
sqluser="root" 
sqlpass="User12345"

# Inkrementacja
ii=1

# Witaj uzytkowniku.
echo "Witaj uzytkowniku $USER!"
echo "Ostatnie logowałeś się z: $logowales_z"
echo "Z adresu IP: $z_ip"
echo "Data ostatniego logowania: $data_ostatniego"
echo "Bierząca data: $bierzaca_data $bierzacy_czas"

#- Skrypt, który zakłada konta na podstawi imienia i nazwiska 
#       (format: mnowak, kzielinski tj. pierwsza litera imienia i nazwisko)
if [ $(id -u) -eq 0 ]; then
    
    # Skrypt możliwy do wywołania z parametrami ./host_createuser imie nazwisko
    if [ $# -eq 2 ]; then
        imie=$1
        nazwisko=$2
    else
        read -p "Podaj swoje imie: " imie
        read -p "Podaj swoje nazwisko: " nazwisko
    fi

    #- Zapamiętuje numer pokoju
    read -p "Podaj numer pokoju: " numer_pokoj
    
    #Opcje dodatkowe referncyjne
    #read -p "Podaj Telefon Pracowniczy: " telefon_praca
    #read -p "Podaj Telefon Domowy: " telfon_domowy

    # Zmiana wielkich liter na małe.
    imie=$(echo $imie | tr [:upper:] [:lower:])
    nazwisko=$(echo $nazwisko | tr [:upper:] [:lower:])
    litera=$(echo $imie | cut -c 1)
    konto=$litera$nazwisko

    #- Sprawdza czy dany użytkownik istnieje i może wyświetlić jakąś informacje
    # Sprawdzenie czy użytkownik taki jest.
    cp /etc/passwd $bierzaca_data$bierzacy_czas
    egrep "^$konto" /etc/passwd >/dev/null

    if [ $? -eq 0 ]; then
        # Informacja o tym że uzytkownik istnieje.
        echo "Użytkownik: $konto istnieje."
        echo "Nie można dodać uzytkownika!"
        egrep "^$konto" /etc/passwd >/dev/null
        while [ $? -eq 0 ]; do
                ii=$((ii+1))
                konto_tym=$konto$ii
                egrep "^$konto_tym" /etc/passwd >/dev/null
        done
    konto=$konto_tym    
    fi
    
    # Zmienna path do home danego usera
    path_konto=/home/$konto
    # Dodanie uzytkownika na podstawie zebranych danych.
    adduser $konto --gecos "$imie $nazwisko,$numer_pokoj,,," --disabled-password # można dodac zmienne gdy sa odblokowane jak $telefon_praca, $telefon_domowy
    read -s -p "Podaj hasło dla użytkownika $konto: " haslo
    echo "$konto:$haslo" | sudo chpasswd >/dev/null
    # samba
    echo -ne "$haslo\n$haslo\n" | smbpasswd -a -s $konto
    pokoju=$(egrep "$konto" /etc/passwd | awk -F ":" '{print $5}' | awk -F "," '{print $2}')
    #tel1=$(egrep "$konto" /etc/passwd | awk -F ":" '{print $5}' | awk -F "," '{print $3}')
    #tel2=$(egrep "$konto" /etc/passwd | awk -F ":" '{print $5}' | awk -F "," '{print $4}')
    prawdziwy_uzytkownik=$(egrep "$konto" /etc/passwd | awk -F ":" '{print $5}' | awk -F "," '{print $1}')
    
    echo "Został utworzony uzytkownik: $konto ($prawdziwy_uzytkownik)"
    echo "Uzytkownik konta jest w pokoju: $pokoju"
    #echo "Numer do tego pokoju to: $tel1"
    #echo "Po za pracą znajdziesz go: $tel2"
    
    #alias krowa 
    cat >> /home/$konto/.bashrc <<EOF
        
# aliasy
alias krowa='apt-get moo'

#Wadomość powitalna
logowales_z=\$(last -i | grep "\$SUER" | grep -v "still" | grep -m1 "" | awk '{print \$2}')
z_ip=\$(last -i | grep "\$SUER" | grep -v "still" | grep -m1 "" | awk '{print \$3}')
data_ostatniego=\$(last -i | grep "\$SUER" | grep -v "still" | grep -m1 "" | awk '{print \$4" "\$5" "\$6" "\$7" "\$8" "\$9" "\$10" "\$11" "\$12" "\$13}')
bierzaca_data=\$(date +"%F")
bierzacy_czas=\$(date +"%T")

# Witaj uzytkowniku.
echo "Witaj uzytkowniku \$USER!"
echo "Ostatnie logowałeś się z: \$logowales_z"
echo "Z adresu IP: \$z_ip"
echo "Data ostatniego logowania: \$data_ostatniego"
echo "Bierząca data: \$bierzaca_data \$bierzacy_czas"
        
EOF

        #- w jego katalogu zalozyc public.html i public_samba
        #- w public_html zalozyc katalog private.html
        mkdir /home/$konto/public_html
        mkdir /home/$konto/public_samba
        mkdir /home/$konto/public_html/private_html

        chmod 755 $path_konto/public_html
        chmod 777 $path_konto/public_samba
        chmod 755 $path_konto/public_html/private_html

        chown $konto:www-data $path_konto/public_html
        chown $konto:$konto $path_konto/public_samba
        chown $konto:www-data $path_konto/public_html/private_html
        touch $path_konto/public_html/private_html/.htaccess
        cat > $path_konto/public_html/private_html/.htaccess << EOF
AuthName "Podaj haslo do katalogu prywatnego"
AuthType Basic
AuthUserFile /home/$konto/public_html/private_html/.htpasswd
Require valid-user
EOF
        # Katalog na hasło.
        sudo htpasswd -b -c /home/$konto/public_html/private_html/.htpasswd $konto $haslo

        # Welcome message dla kazdego usera.
        touch $path_konto/welcome.msg
        cat > $path_konto/welcome.msg << EOF
WITAJ UŻYTKOWNIKU: $konto NA SERWERZE FTP by Sterfa Kursow.
EOF

        # Baza danych dla użytkownika.
        mysql -u$sqluser -p$sqlpass <<MYSQL
CREATE USER '$konto'@'localhost' IDENTIFIED BY '$haslo';
GRANT USAGE ON *.* TO '$konto'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
CREATE DATABASE IF NOT EXISTS $konto;
GRANT ALL PRIVILEGES ON $konto.* TO '$konto'@'localhost';
FLUSH PRIVILEGES;
MYSQL

        # Ustawienia plików.
        chmod 644 $path_konto/public_html/private_html/.htaccess
        chown $konto:www-data $path_konto/public_html/private_html/.htaccess
        chmod 644 $path_konto/public_html/private_html/.htpasswd
        chown $konto:www-data $path_konto/public_html/private_html/.htpasswd
        mkdir /var/www/html/$konto/
        chmod 755 /var/www/html/$konto
        chown $konto:www-data /var/www/html/$konto
        usermod -aG www-data $konto
        chgrp -R www-data /home/$konto/public_html
        find /home/$konto/public_html -type d -exec chmod g+rx {} +
        find /home/$konto/public_html -type f -exec chmod g+r {} +
        chown -R $konto /home/$konto/public_html/
        find /home/$konto/public_html -type d -exec chmod u+rwx {} +
        find /home/$konto/public_html -type f -exec chmod u+rw {} +
        find /home/$konto/public_html -type d -exec chmod g+s {} +
        ln -s /var/www/html/$konto /home/$konto/www_$konto

        mysql -u$konto -p$haslo $konto << EOF
CREATE TABLE $konto (counter INT(20) NOT NULL);
INSERT INTO $konto VALUES (0); 
EOF
        touch $path_konto/public_html/index.php
        cat > $path_konto/public_html/index.php << EOF
<?php
\$link = mysqli_connect("127.0.0.1", "$konto", "$haslo", "$konto");

if (!\$link) {
    echo "Blad: Brak polaczenia do MySQL." . PHP_EOL . "<br/>";
    echo "Debugging errno: " . mysqli_connect_errno() . PHP_EOL . "<br/>";
    echo "Debugging error: " . mysqli_connect_error() . PHP_EOL . "<br/>";
    exit;
}

echo "Sukces: Udało podłaczyć się do MySQL! Baza $konto jest." . PHP_EOL . "<br/>";
echo "Informacja o hoscie: " . mysqli_get_host_info(\$link) . PHP_EOL . "<br/>";

\$sql = "UPDATE $konto SET counter = counter +1";
if (\$link->query(\$sql) === TRUE) {
        /// echo "Yes";
} else {
        echo "No" . \$link->error;
}

\$sql = "SELECT counter FROM $konto";
\$result = \$link->query(\$sql);

while(\$row = \$result->fetch_assoc()) {
        echo "<br/>"."<h1>Liczba odwiedzin: " . \$row["counter"] . "</h1><br/>";
}

mysqli_close(\$link);
?>
EOF


# Pobieram Wordpress
wget -O latest.tar.gz https://wordpress.org/latest.tar.gz >/dev/null
#unzip wordpress
tar -zxvf latest.tar.gz >/dev/null
#Do katalogu usera
mv wordpress /home/$konto/public_html/wordpress
# config
cp /home/$konto/public_html/wordpress/wp-config-sample.php /home/$konto/public_html/wordpress/wp-config.php
# config
perl -pi -e "s/database_name_here/$konto/g" /home/$konto/public_html/wordpress/wp-config.php
perl -pi -e "s/username_here/$konto/g" /home/$konto/public_html/wordpress/wp-config.php
perl -pi -e "s/password_here/$haslo/g" /home/$konto/public_html/wordpress/wp-config.php

# sól
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' /home/$konto/public_html/wordpress/wp-config.php

# uprawnienia do pliku / katalogu
mkdir /home/$konto/public_html/wordpress/wp-content/uploads
chmod 775 /home/$konto/public_html/wordpress/wp-content/uploads

#usuwamy spakowanego word pressa
rm latest.tar.gz

else 
    echo "Tylko uzytkownik root ma prawo dodac uzytkownika do systemu"
    exit 2
fi