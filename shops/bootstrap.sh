#!/bin/bash
#set -x

YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr0)

startup () {
    cd ./$1
    docker-compose up --build
    #When containers are closed by user, re-read this shell script
    cd ../
    ./bootstrap.sh $1
    exit
}

back () {
    echo "${RED}[!] Going back...${NC}"
    cd ../
    ./startup.sh
}


echo '##### Welcome to the Mollie' $1 'Local Environment tool. ##### '

if [ ! -d ./$1/data ]; #Check if webshop is installed
then
    echo "${RED}[!]" $1 "is not yet to be installed. Would you like to install and run it?"
    read -n1 -r -p "${YELLOW}[?] Press y to ${GREEN}confirm,${YELLOW} or n to go ${RED}back${YELLOW}:" response
    echo \

    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        echo "${GREEN}[!] Installing and running" $1 "...${NC}"
        startup $1
    fi
    back
fi

echo "${GREEN}[!]" $1 "is installed.${NC}"

#Show Menu

cd ./$1
running=$(docker-compose ps --services --filter "status=running")
if [ "$running" != "" ]; then
    echo "${GREEN}[!]" $1 "is already running${NC}"
    echo '[0]: Stop webshop'
else
    echo '[0]: Startup webshop'
fi
cd ../

echo '[1]: Re-install'
echo '[2]: Delete'
echo '[3]: Back'

read -n1 -r -p "[?] Press a number: " num
echo \

#Read option and act

if [ "$num" = "2" ] || [ "$num" = "1" ]; then #Delete files
    #Shut down container
    cd ./$1
    docker-compose down -v
    cd ../

    rm -rf ./$1
fi

if [ "$num" = "1" ]; then #Reinstall
    git clone https://github.com/SalimAtMollie/$1xMollie $1 #Download repo from github
fi

if [ "$num" = "0" ] || [ "$num" = "1" ]; then #Startup/stop Webshop
    if [ "$running" != "" ]; then
        cd ./$1
        docker-compose down
        cd ../
        ./bootstrap.sh $1
    else
        startup $1
    fi
fi

if [ "$num" = "3" ] || [ "$num" = "2" ]; then
    back
fi