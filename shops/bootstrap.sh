#!/bin/bash
#set -x

YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr0)

startup () {
    if [ "$2" != "-d" ]; then 
        echo "${YELLOW}[!] TO STOP WEBSHOP, PRESS [CONTROL] + [C] ONCE AT ANY TIME!${NC}"
        sleep 2 
    fi
    cd ./$1
    docker-compose up --build $2
    #When containers are closed by user, re-read this shell script
    echo "${RED}[!] Going back...${NC}"
    cd ../
    ./bootstrap.sh $1
    exit
}

shutdown () {
    echo "${RED}[!] Shutting down containers...${NC}"
    cd ./$1
    docker-compose down
    cd ../
}

back () {
    echo "${RED}[!] Going back...${NC}"
    cd ../
    ./startup.sh
    exit
}

info() {
    set -o allexport
    source .env
    
    echo "${YELLOW}[!] Webshop URL     : " $DOMAIN
    echo "${YELLOW}[!] Admin URL       : " $ADMIN_DOMAIN
    echo "${YELLOW}[!] Admin Username  : " $ADMIN_NAME
    echo "${YELLOW}[!] Admin Password  : " $ADMIN_PASS ${NC}
}

run() {
    echo "${YELLOW}[?] Would you like to run the webshop in the background?: ${NC}"
    read -n1 -r -p "${YELLOW}[?] Press y to ${GREEN}confirm,${YELLOW} or n to ${RED}decline${YELLOW}:${NC}" detached
    echo \
        
    echo "${GREEN}[!] Starting up containers...${NC}"

    if [ "$detached" = "y" ] || [ "$detached" = "Y" ]; then
        startup $1 -d
        echo "${YELLOW}[!] IF WEBSITE IS NOT LIVE, PLEASE WAIT A FEW MINUTES AND TRY AGAIN!${NC}"
    else
        startup $1
    fi
}


echo '##### Welcome to the Mollie' $1 'Local Environment tool. ##### '

if [ ! -d ./$1/data ]; #Check if webshop is installed
then
    echo "${RED}[!]" $1 "is not yet to be installed. Would you like to install and run it?"
    read -n1 -r -p "${YELLOW}[?] Press y to ${GREEN}confirm,${YELLOW} or n to go ${RED}back${YELLOW}:${NC}" response
    echo \

    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        run $1
    fi
    back
fi

echo "${GREEN}[!]" $1 "is installed.${NC}"

#Show Menu

cd ./$1
running=$(docker-compose ps --services --filter "status=running")
if [ "$running" != "" ]; then
    echo "${GREEN}[!]" $1 "is already running${NC}"
    info
    echo '[0]: Stop webshop'
else
    echo '[0]: Startup webshop'
fi
cd ../

echo '[1]: Re-install'
echo '[2]: Delete'
echo '[3]: Back'

read -n1 -r -p "${YELLOW}[?] Press a number: ${NC}" num
echo \

#Read option and act

if [ "$num" = "2" ] || [ "$num" = "1" ]; then #Delete files
    #Shut down container
    shutdown $1

    echo "${RED}[!] Deleting files...${NC}"
    rm -rf ./$1
fi

if [ "$num" = "1" ]; then #Reinstall
    echo "${GREEN}[!] Downloading files...${NC}"
    git clone https://github.com/SalimAtMollie/$1xMollie $1 #Download repo from github
fi

if [ "$num" = "0" ] || [ "$num" = "1" ]; then #Startup/stop Webshop
    if [ "$running" != "" ]; then
        shutdown $1
        ./bootstrap.sh $1
    else
        run $1
    fi
fi

if [ "$num" = "3" ] || [ "$num" = "2" ]; then
    back
fi