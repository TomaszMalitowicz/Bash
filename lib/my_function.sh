#!/bin/bash

#title           : 
#description     : Materiał z Strefy Kursów - Kurs Bash
#author		     : Piotr "TheRealMamuth" Kośka
#copyright       : Strefa Kursów
#date            : 25.05.2018
#version         : v1.0   
#usage		     :
#notes           :
#bash_version    : 4.4.12(1)-release
#editor          : visual studio code
#==============================================================================

# zmienne globalne

#zdefiniowane kolory
RED="\e[0;31m"
GREEN="\e[0;32m"
BLUE="\e[0;34m"
NC="\e[0m"

shopt -s expand_aliases

alias MYDATE="date +\"%F\""
currentDate=`MYDATE`
currentTime=$(date +"%T") # Czas
apachePath=/etc/apache2


# funkcje lokalne

function log_dir()
{
    if [ -d "./log" ]; then
        echo "Katalog "$(pwd)"/log instnieje. " | tee -a ./log/log_${currentDate}.log 
    else
        mkdir ./log/
        echo "Katalog "$(pwd)"/log nie instnieje. " | tee -a ./log/log_${currentDate}.log 
        
        echo "Katalog "$(pwd)"/log utworzony " | tee -a ./log/log_${currentDate}.log 
    fi
}

function show_message () {
    if [ $# -lt 2 ]; then
        # echo z opcją -e pozwala na wyśietlanie kolorów
        echo -e "${BLUE}WARNING: ${GREEN}$0 ${BLUE}wymagane są argumenty 3:$NC ${RED}typ_błedu$NC, ${RED}wiadomość$NC"
        exit 1
    fi

    case "$1" in
        [eE] | [eE][rR][rR][oO][rR] )
            echo -e "${RED}${1}$NC: $2"
            ;;
        [wW] | [wW][aA][rR][nN][iI][nN][gG] )
            echo -e "${BLUE}${1}$NC: $2"
            ;;
        [oO] | [oO][kK] )
            echo -e "${GREEN}${1}$NC: $2"
            ;;
        [iI] | [iI][nN][fF][oO] )
            echo "INFO: ${2}"
            ;;
        *)
            echo -e "${RED}Zła składnia ${BLUE}$0$NC ${RED}dozwolone tylko ${RED}ERROR${NC}, ${BLUE}WARRNING${NC}, ${GREEN}OK${NC}, INFO"
            ;;
    esac
}

function install_package () {

    local pacman="apt-get"
    local counterror=0

    log_dir
    if [ $# -eq 0 ]; then
        echo "Nie podałeś żadnego pakietu do instalacji" | tee -a ./log/log_${currentDate}.log
        show_message WARNING "Nie podałeś zadnego pakietu do instalacji"

        exit 1

    else
        sudo $pacman update && sudo $pacman upgrade -y | tee -a ./log/log_${currentDate}.log
        for install in "$@"
        do
            dpkg -s $install &> /dev/null
            if [ $? -eq 0 ]; then
                echo "Pakiet $install jest już zainstalowany. Nie będę go instalował!" | tee -a ./log/log_${currentDate}.log 
                show_message INFO "Pakiet $install jest już zainstalowany"
            else
                echo "Pakiet $install nie jest zainstalowany. Nastapi jego instalacja" | tee -a ./log/log_${currentDate}.log 
                show_message INFO "Nastapi instalacja pakietu $install"
                sudo $pacman install -y $install | tee -a ./log/log_${currentDate}.log 
                    if [ $? -eq 0 ]; then
                        echo "Pakiet $install zosatła poprawnie zainstalowany" | tee -a ./log/log_${currentDate}.log 
                        show_message OK "Pakiet $install został zainstalowany poprawnie"
                    else
                        echo "Problem z instalacją pakietu sprawdz wyżej." | tee -a ./log/log_${currentDate}.log 
                        show_message WARNING "Coś przy instalacji $install poszło nie tak, sprawdz log"
                        ((counterror++))
                    fi
                sudo $pacman install -f -y | tee -a ./log/log_${currentDate}.log 
            fi
        done
        sudo $pacman autoremove | tee -a ./log/log_${currentDate}.log
        if [ "$counterror" -ne 0 ]; then
            exit $counterror
        fi
    fi
}

function configure_www_ftp_server () {
    log_dir
    # Aktywacja html dla każdego użytkownika - to jest moduł apacha2
    sudo a2enmod userdir |& tee -a ./log/log$currentDate.log
    # Plik konfiguracyjny znajduje się /etc/apache2/mods-available/userdir.conf nie ma potrzeby go zmieniać.

    touch httpd.conf
    cat > httpd.conf << EOF
    <Directory /var/www/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
EOF

    sudo mv httpd.conf /etc/apache2/conf-available/

    # By działało hasło na folder www.
    sudo a2enconf httpd |& tee -a ./log/log$currentDate.log

    # Aktywacja PHP dla /home/*/public_html
    sudo sed '/php_admin_flag engine Off/ c\        php_admin_flag engine On' $apachePath/mods-available/php7.0.conf | sudo tee $apachePath/mods-available/php7.0.conf.new
    sudo mv $apachePath/mods-available/php7.0.conf $apachePath/mods-available/php7.0.conf.bak
    sudo mv $apachePath/mods-available/php7.0.conf.new $apachePath/mods-available/php7.0.conf

    # Restart usługi apache2.
    #	sudo systemctl restart apache2
    sudo /etc/init.d/apache2 restart |& tee -a ./log/log$currentDate.log

    # Generacja certyfikatów
    # Dla FTP
    #	sudo openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/private/proftpd.key -out /etc/ssl/certs/proftpd.crt -nodes -days 365
    sudo mkdir /etc/proftpd/ssl
    sudo openssl req -new -x509 -days 365 -nodes -out /etc/proftpd/ssl/proftpd.cert.pem -keyout /etc/proftpd/ssl/proftpd.key.pem
    sudo chmod 600 /etc/proftpd/ssl/proftpd.*

    # Dla Apache
    mkdir $PWD/apachecert |& tee -a ./log/log$currentDate.log
    # W pierwszej kolejności generujemy 4096-bit długi klucz RSA dla naszego centrum (root CA) i zapisujemy go w pliku ca.key:
    sudo openssl genrsa -out $PWD/apachecert/ca.key 4096
    # Następnie tworzymy własny samodzielnie podpisany przez root CA certyfikat o nazwie ca.crt
    sudo openssl req -new -x509 -days 3650 -key $PWD/apachecert/ca.key -out apachecert/ca.crt
    # Tworzymy klucz dla usługi (w tym przypadku q.pem):
    sudo openssl genrsa -out $PWD/apachecert/q.pem 1024
    # Kolejnym etapem jest generowanie żądania podpisu.
    sudo openssl req -new -key $PWD/apachecert/q.pem -out $PWD/apachecert/q.csr
    # Jako CA podpisujemy przygotowane żądanie i tworzymy q-cert.pem (podpis) z podpisem na 10 lat oraz generowanie numeru seryjnego dla wykonanego podpisu.
    sudo openssl -x509 -req -in $PWD/apachecert/q.csr -out $PWD/apachecert/q-cert.pem -sha1 -CA $PWD/apachecert/ca.crt -CAkey $PWD/apachecert/ca.key -CAcreateserial –days 3650
    # Otrzymany podpis sklejamy z generowanym kluczem w jeden plik zawierajacy certyfikat usługi i podpis CA tego certyfikatu.
    sudo cat $PWD/apachecert/q-cert.pem >> apachecert/q.pem

    if [ -e "$apachePath/sites-available" ]; then
        sudo cp $apachePath/sites-available/default-ssl.conf $apachePath/sites-available/default-ssl.conf.bak |& tee -a ./log/log$currentDate.log
        sudo sed '/                SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem/ c\                SSLCertificateFile      /etc/apache2/q.pem' $apachePath/sites-available/default-ssl.conf | sudo tee $apachePath/sites-available/default-ssl.conf.1
        sudo mv $apachePath/sites-available/default-ssl.conf $apachePath/sites-available/default-ssl.old |& tee -a ./log/log$currentDate.log
        sudo mv $apachePath/sites-available/default-ssl.conf.1 $apachePath/sites-available/default-ssl.conf |& tee -a ./log/log$currentDate.log
        sudo sed '/                SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key/ c\                #SSLCertificateKeyFile      /etc/ssl/private/ssl-cert-snakeoil.key' $apachePath/sites-available/default-ssl.conf | sudo tee $apachePath/sites-available/default-ssl.conf.1
        sudo mv $apachePath/sites-available/default-ssl.conf $apachePath/sites-available/default-ssl.old |& tee -a ./log/log$currentDate.log
        sudo mv $apachePath/sites-available/default-ssl.conf.1 $apachePath/sites-available/default-ssl.conf |& tee -a ./log/log$currentDate.log
    else
        echo "Brak pliku - default-ssl.conf, nie kompletne." |& tee -a ./log/log$currentDate.log
    fi

    sudo cp $PWD/apachecert/q.pem $apachePath/q.pem |& tee -a ./log/log$currentDate.log
    sudo a2enmod ssl |& tee -a ./log/log$currentDate.log 
    sudo a2ensite default-ssl |& tee -a ./log/log$currentDate.log
    sudo /etc/init.d/apache2 restart |& tee -a ./log/log$currentDate.log

    # Konfiguracja folderu w celu prawidłowego funkcjonowania.
    www_set

    # Welcome message - wiadomość powitalna.
    sudo cat > /etc/proftpd/welcome.msg << EOF

    WITAJ UŻYTKOWNIKU NA SERWERZE FTP by Strefa Kursow.

EOF

    # uniemożliwić logowanie anonimowe - jest domyślnie wyłaczone.
    # uniemożliwić logowanie na roota - jest domyslnie wyłaczone.

    # Konfiguracja proftpd jest w pliku: /etc/proftpd/proftpd.conf
    # Kopia pliku konfiguracyjnego.
    sudo cp /etc/proftpd/proftpd.conf /etc/proftpd/proftpd_backup.conf

    # Dostęp do FTPS w katalogu domowym.
    sudo sed '/# DefaultRoot/ c\ DefaultRoot ~' /etc/proftpd/proftpd.conf | sudo tee /etc/proftpd/proftpd_new.conf
    sudo mv /etc/proftpd/proftpd_new.conf /etc/proftpd/proftpd.conf

    # Wyłaczenie IPv6 dla bezpieczeństwa.
    sudo sed '/UseIPv6/ c\ UseIPv6 off' /etc/proftpd/proftpd.conf | sudo tee /etc/proftpd/proftpd_new.conf
    sudo mv /etc/proftpd/proftpd_new.conf /etc/proftpd/proftpd.conf

    # Zmiana portu z 21 na 50021.
    sudo sed '/Port				21/ c\ Port 21' /etc/proftpd/proftpd.conf | sudo tee /etc/proftpd/proftpd_new.conf
    sudo mv /etc/proftpd/proftpd_new.conf /etc/proftpd/proftpd.conf

    # Właczenie dodatkowego loga.
    sudo sed '/#UseLastlog on/ c\ UseLastlog on' /etc/proftpd/proftpd.conf | sudo tee /etc/proftpd/proftpd_new.conf
    sudo mv /etc/proftpd/proftpd_new.conf /etc/proftpd/proftpd.conf

    # Blokowanie logowania na root.
    sudo echo '# Zablokowanie logowania jako root' | sudo tee -a /etc/proftpd/proftpd.conf
    sudo echo 'RootLogin off' | sudo tee -a /etc/proftpd/proftpd.conf
    # Połaczenie szyfrowane.
    sudo echo '# Aktywowanie FTPS SSL/TLS' | sudo tee -a /etc/proftpd/proftpd.conf
    sudo echo 'Include /etc/proftpd/tls.conf' | sudo tee -a /etc/proftpd/proftpd.conf

    # Kopia ustawień.
    sudo mv /etc/proftpd/tls.conf /etc/proftpd/tls_backup.conf

    # Plik konfiguracyjny tls.conf
    cat > ./tls.conf << EOF
    # by Strefa Kursów
    #
    # Proftpd sample configuration for FTPS connections.
    #
    # Note that FTPS impose some limitations in NAT traversing.
    # See http://www.castaglia.org/proftpd/doc/contrib/ProFTPD-mini-HOWTO-TLS.html
    # for more information.
    #

    <IfModule mod_tls.c>
    TLSEngine                               on
    TLSLog                                  /var/log/proftpd/tls.log
    TLSProtocol                             SSLv23
    #
    # Server SSL certificate. You can generate a self-signed certificate using 
    # a command like:
    #
    # openssl req -x509 -newkey rsa:1024 \
    #          -keyout /etc/ssl/private/proftpd.key -out /etc/ssl/certs/proftpd.crt \
    #          -nodes -days 365
    #
    # The proftpd.key file must be readable by root only. The other file can be
    # readable by anyone.
    #
    # chmod 0600 /etc/ssl/private/proftpd.key 
    # chmod 0640 /etc/ssl/private/proftpd.key
    # 
    TLSRSACertificateFile                   /etc/proftpd/ssl/proftpd.cert.pem
    TLSRSACertificateKeyFile                /etc/proftpd/ssl/proftpd.key.pem
    #
    # CA the server trusts...
    #TLSCACertificateFile 			 /etc/ssl/certs/CA.pem
    # ...or avoid CA cert and be verbose
    TLSOptions                      NoCertRequest EnableDiags 
    # ... or the same with relaxed session use for some clients (e.g. FireFtp)
    #TLSOptions                      NoCertRequest EnableDiags NoSessionReuseRequired
    #
    #
    # Per default drop connection if client tries to start a renegotiate
    # This is a fix for CVE-2009-3555 but could break some clients.
    #
    TLSOptions 							AllowClientRenegotiations
    #
    # Authenticate clients that want to use FTP over TLS?
    #
    TLSVerifyClient                         off
    #
    # Are clients required to use FTP over TLS when talking to this server?
    #
    TLSRequired                             on
    #
    # Allow SSL/TLS renegotiations when the client requests them, but
    # do not force the renegotations.  Some clients do not support
    # SSL/TLS renegotiations; when mod_tls forces a renegotiation, these
    # clients will close the data connection, or there will be a timeout
    # on an idle data connection.
    #
    #TLSRenegotiate                          required off
    </IfModule>
EOF

    sudo cp ./tls.conf /etc/proftpd/tls.conf

    # Restart usługi FTP
    # 	sudo systemctl restart proftpd
    sudo /etc/init.d/proftpd restart

    mv /etc/samba/smb.conf /etc/samba/smb.conf.bak

    mkdir -p /home/shares/allusers
    chown -R root:users /home/shares/allusers/
    chmod -R ug+rwx,o+rx-w /home/shares/allusers/

    mkdir -p /home/shares/anonymous
    chown -R root:users /home/shares/anonymous/
    chmod -R ug+rwx,o+rx-w /home/shares/anonymous/

    mkdir /var/samba
    chmod 777 /var/samba/

    cat >> /etc/samba/smb.conf <<EOF
    [global]
    workgroup = WORKGROUP
    server string = Strefa Kursów Samba Server %v
    netbios name = ubuntu
    security = user
    map to guest = bad user
    dns proxy = no

    [homes]
    comment = Home Directories
    browseable = no
    valid users = %S
    writable = yes
    create mask = 0700
    directory mask = 0700

    [allusers]
    comment = All Users
    path = /home/shares/allusers
    valid users = @users
    force group = users
    create mask = 0660
    directory mask = 0771
    writable = yes

    [anonymous]
    path = /home/shares/anonymous
    force group = users
    create mask = 0660
    directory mask = 0771
    browsable =yes
    writable = yes
    guest ok = yes

    [public]
    comment = public anonymous access
    path = /var/samba/
    browsable =yes
    create mask = 0660
    directory mask = 0771
    writable = yes
    guest ok = yes

EOF

    systemctl restart smbd.service
    /etc/init.d/samba restart
}

function create_user_now()
{
    # Sprawdzanie ile argumentów zostało przekazanych do sunkcji.
    if [ $# -eq 2 ]; then
        # Imię małymi literami.
        user_name=$(echo $1 | tr [:upper:] [:lower:])
        # Nazwisko małymi.
        user_surname=$(echo $2 | tr [:upper:] [:lower:])
        # Wydobywamy pierwszą literę z imienia.
        oneletter=$(echo $user_name | cut -c 1)
        # Tworzymy konto
        account=$oneletter$user_surname
    else
        # Jeden argument, dane z pliku już sformatowane.
        account=$1
    fi

    # Dwóch użytkowników o takiej samej nazwie nie stworzę więc trzeba to sprawdzić.
    egrep "^$account" /etc/passwd >/dev/null

    if [ $? -eq 0 ]; then
        # Użytkownik taki już istnieje. Nie możemy utworzyć otakiej samej nazwie. Musimy utworzyć troche inne konto dodając liczbę na koncu.
        echo "Użytkownik: $account istnieje."
        echo "Nie można dodać konta. Generacja nowej nazwy!"
        # Definiowanie auto numeracji.
        addnumber=1
        # Sprawdzamy by wejści do pętli while.
        egrep "^$account" /etc/passwd >/dev/null
        while [ $? -eq 0 ]; do
            # Inkrementacja.
            addnumber=$((addnumber+1))
            # Konto tymczasowe też trzeba zweryfikować czy nie powtórzy się z już istniejącym nowo utworzonym
            tmp_account=$account$addnumber
            egrep "^$tmp_account" /etc/passwd >/dev/null
        done
        account=$tmp_account
    fi

    # Tworzymu konto i ustawiamy hasło oraz wymuszamy jego zmiane podczas pierwszego logowania.
    path_account=/home/$account
    adduser $account --home $path_account --gecos "$name $surname,,,," --disabled-password
    echo "$account:$account" | sudo chpasswd >/dev/null
    chage -d 0 $account

    egrep "^$account" /etc/passwd >/dev/null
    if [ $? -eq 0 ]; then
        echo "Użytkownik został poprawnie założony."
    fi

    # Zapis danych do pliku w celach sprawozdawczych. Swoisty log.
    echo "${account}:${account}" | tee -a list_of_user.txt>/dev/null 

}

function create_special_user()
{
if [ $# -ge 2 ]; then
    # Imię i Nazwisko jako parametr.
    create_user_now $1 $2
elif [ $# -eq 1 ]; then
    # Jedna opcja zatem traktuj jako plik
    if [ -e "$1" ]; then
        # Plik istnieje.
        if file "$1" | grep -q text$; then
            # Jest to tekst.
            filename="$1"
            while IFS='' read -r line || [[ -n "$line" ]]; do
                # Przejdź do działania na każdej lini $line
                username="$line"
                create_user_now $username
            done < $filename
        else
            # File nie uznaje tego za tekst.
            echo "Nie jest to typowy plik tekstowy!"
            exit 1
        fi
    else
        # Plik nie istnieje.
        echo "Plik o podanej nazwie ${1} nie instanieje!"
        exit 2
    fi
else
    # Jak nie większe lub równe od dwóch i nie równe jeden czyli zero - wyswietlamy opcje.
    show_menu
fi
}

function show_menu()
{
# Opcje dla pętli select.
options="\"Dodaj użytkownika\" \"Pokaż użytkowników\" \"Wyjście\""
# Nadajmy troche wyrazu naszemu select.
PS3='Wybierz opcję: '

# By uniknąć łamania spacji i tworzenia innych zmiennych.
eval set $options

# Nasz select.
select option in "$@"
do
    # case
    case "$option" in
        # Opcja dla wartości "Dodaj użytkownika".
        "Dodaj użytkownika")
            # Pobierz imie od użytkownika
            read -p "Podaj swoje imię: " name
            # Pobierz nazwisko od użytkownika
            read -p "Podaj swoje nazwisko: " surname
            # Odwołanie do funkcji
            create_user_now $name $surname
            ;;
        # Opcja dla wartości "Pokaż użytkowników".
        "Pokaż użytkowników")
            echo "Lista aktualnych użytkowników:"
            awk -F: '($3 >= 1000) {printf "%s:\n",$1}' /etc/passwd
            read -n 1 -s -r -p "Naciśnij dowolny klawisz by kontynuować..."
            ;;
        # Po Prostu wyjście.
        "Wyjście")
            exit 0
            ;;
    esac
done
# Komunikat końcowy.
echo "Wyjście ze skryptu."
}

function wp_install () {
    if [ "$#" -eq 4 ]; then
        # Zmienne SQL 
        local sqluser=$1 
        local sqlpass=$2
        local konto=$3
        local haslo=$4

        # Baza danych dla użytkownika.
        mysql -u$sqluser -p$sqlpass <<MYSQL
        CREATE USER '$konto'@'localhost' IDENTIFIED BY '$haslo';
        GRANT USAGE ON *.* TO '$konto'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
        CREATE DATABASE IF NOT EXISTS $konto;
        GRANT ALL PRIVILEGES ON $konto.* TO '$konto'@'localhost';
        FLUSH PRIVILEGES;
MYSQL

        # Pobieram Wordpress
        wget -O latest.tar.gz https://wordpress.org/latest.tar.gz >/dev/null
        #unzip wordpress
        tar -zxvf latest.tar.gz >/dev/null
        #Do katalogu usera
        mv wordpress /var/www/html/wordpress
        # config
        cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
        # config
        perl -pi -e "s/database_name_here/$konto/g" /var/www/html/wordpress/wp-config.php
        perl -pi -e "s/username_here/$konto/g" /var/www/html/wordpress/wp-config.php
        perl -pi -e "s/password_here/$haslo/g" /var/www/html/wordpress/wp-config.php

        # sól
        perl -i -pe'
        BEGIN {
            @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
            push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
            sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
        }
        s/put your unique phrase here/salt()/ge
        ' /var/www/html/wordpress/wp-config.php

        # uprawnienia do pliku / katalogu
        mkdir /var/www/html/wordpress/wp-content/uploads
        chmod 775 /var/www/html/wordpress/wp-content/uploads

        #usuwamy spakowanego word pressa
        rm latest.tar.gz
    else
        show_message ERROR "Funkcje powinna zawierać [sqluser] [sqlpass] [konto] [haslo]"
    fi
}

function www_set () {
    log_dir
    # Konfiguracja folderu w celu prawidłowego funkcjonowania.
    sudo usermod -aG www-data $USER |& tee -a ./log/log$currentDate.log
    sudo chgrp -R www-data /var/www/html |& tee -a ./log/log$currentDate.log
    sudo find /var/www/html -type d -exec chmod g+rx {} + |& tee -a ./log/log$currentDate.log
    sudo find /var/www/html -type f -exec chmod g+r {} + |& tee -a ./log/log$currentDate.log
    sudo chown -R $USER /var/www/html/ |& tee -a ./log/log$currentDate.log
    sudo find /var/www/html -type d -exec chmod u+rwx {} + |& tee -a ./log/log$currentDate.log
    sudo find /var/www/html -type f -exec chmod u+rw {} + |& tee -a ./log/log$currentDate.log
    sudo find /var/www/html -type d -exec chmod g+s {} + |& tee -a ./log/log$currentDate.log
}