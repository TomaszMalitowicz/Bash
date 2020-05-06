#!/bin/bash

# Zmienne
sqluzytkownik="root"
sqlhaslo="root"
uzytkownik="$1"
haslo="$1"
host="localhost"

# Baza danych dla użytkownika
mysql -h${host} -u${sqluzytkownik} -p${sqlhaslo} <<MYSQL
CREATE USER '$uzytkownik'@'localhost' IDENTIFIED BY '$haslo';
GRANT USAGE ON *.* TO '$uzytkownik'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
CREATE DATABASE IF NOT EXISTS $uzytkownik;
GRANT ALL PRIVILEGES ON $uzytkownik.* TO '$uzytkownik'@'localhost';
FLUSH PRIVILEGES;
MYSQL

#Pobieramy Wordpressa
wget -O ~/wordpressInstallFile/latest.tar.gz https://wordpress.org/latest.tar.gz > /dev/null

#Wypakowywanie archiwum
tar -zxvf ~/wordpressInstallFile/latest.tar.gz

#Przenosimy katalog
mv ~/wordpressInstallFile/wordpress /var/www/html/wordpress_2

#Config
cp /var/www/html/wordpress_2/wp-config-sample.php /var/www/html/wordpress_2/wp-config.php

#configuracja pliku
perl -pi -e "s/database_name_here/$uzytkownik/g" /var/www/html/wordpress_2/wp-config.php
perl -pi -e "s/username_here/$uzytkownik/g" /var/www/html/wordpress_2/wp-config.php
perl -pi -e "s/password_here/$haslo/g" /var/www/html/wordpress_2/wp-config.php

# gebnaracja naszych haseł
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' /var/www/html/wordpress_2/wp-config.php

# uprawnienia do pliku katalogu
mkdir /var/www/html/wordpress_2/wp-content/uploads
chmod 775 /var/www/html/wordpress_2/wp-content/uploads

# usuwamy archiwum
rm ~/wordpressInstallFile/latest.tar.gz
