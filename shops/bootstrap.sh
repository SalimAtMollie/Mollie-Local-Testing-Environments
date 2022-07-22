#!/bin/bash
#set -x

startup () {
    cd ./$1
    docker-compose up --build
    #When containers are closed by user, re-read this shell script
    cd ../
    ./bootstrap.sh $1
    exit
}

echo '##### Welcome to the Mollie' $1 'Local Environment tool. ##### '

if [ ! -d ./$1/data ]; #Check if webshop is installed
then
    echo '[!]' $1 'is not yet to be installed. Would you like to install and run it? (y/n): '
    read -n1 -r -p "[?] Press y to confirm, or n to go back: " response
    echo \

    if [ "$response" = "y" ]; then
        echo "[!] Installing and running' $1 '..."
        startup $1
    fi

    echo "[!] Going back..."
    cd ../
    ./startup.sh
fi

echo '[!]' $1 'is installed.'
echo '[0]: Startup webshop'
echo '[1]: Re-install'
echo '[2]: Delete'
echo '[3]: Back'

read -n1 -r -p "[?] Press a number: " num
echo \

if [ "$num" = "0" ]; then #Startup Webshop
    startup $1
fi

if [ "$num" = "2" ] || [ "$num" = "1" ]; then #Delete files
    #Shut down container
    cd ./$1
    docker-compose down -v
    cd ../

    echo '[!] For this to work. Please answer y for each override.'
    rm -rf ./$1
fi

if [ "$num" = "1" ]; then #Reinstall
    git clone https://github.com/SalimAtMollie/$1xMollie $1 #Download repo from github
    startup $1
fi

if [ "$num" = "3" ] || [ "$num" = "2" ]; then
    echo "[!] Going back..."
    cd ../
    ./startup.sh
fi