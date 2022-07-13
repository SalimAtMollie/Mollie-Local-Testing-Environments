#!/bin/bash
#set -x


echo '##### Welcome to the Mollie OXID Local Environment tool. ##### '

if [ -f ./files/data/www/source/config.inc.php ];
then #Oxid Is installed
    echo '[!] Oxid is Installed.'
    echo '[0]: Startup Oxid Webshop'
    echo '[1]: Re-install'
    echo '[2]: Delete'
    echo '[3]: Back'

    read -n1 -r -p "[?] Press a number: " num
    echo \

    if [ "$num" = "0" ]; then #Startup Oxid Webshop
        cd ./files
        docker-compose up

        #This part executes when container is stopped
        cd ../
        ./oxid6.sh
    fi
    if [ "$num" = "2" ] || [ "$num" = "1" ]; then #Delete files
        cd ./files
        docker-compose down -v
        cd ../

        echo '[!] For this to work. Please answer y for each override.'
        rm -r ./files
    fi
    if [ "$num" = "1" ]; then #Reinstall
        git clone https://github.com/SalimAtMollie/docker-Oxid6xMollie files #Download repo from github
        cd ./files
        docker-compose up --build
    fi
    if [ "$num" = "3" ] || [ "$num" = "2" ]; then
        echo "[!] Going back..."
        cd ../../
        ./startup.sh
    fi

else #Oxid is not installed
    echo '[!] Oxid is not yet to be installed. Would you like to install and run it? (y/n): '
    read -n1 -r -p "[?] Press y to confirm, or n to go back: " oxidRes

    if [ "$oxidRes" = "y" ]; then
        echo "[!] Installing and running Oxid..."
        cd ./files
        docker-compose up --build

        #This part executes when container is stopped
        cd ../
        ./oxid6.sh
    else
        echo "[!] Going back..."
        cd ../../
        ./startup.sh
    fi
fi