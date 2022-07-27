#!/bin/bash

YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr0)

#Welcome the User
echo "##### Welcome to the Mollie Webshop Local Environment tool. ##### "

#Check traefik, mysql and mailhog container status.
result=$(docker-compose ps --services --filter "status=running")

if [[ "$result" == *"traefik"* ]] \
&& [[ "$result" == *"mysql"* ]] \
&& [[ "$result" == *"mailhog"* ]] \
&& [[ "$result" == *"phpmyadmin"* ]]; then #Are the containers running?
    echo "${GREEN}[!] Traefik, mysql and mailhog are ready to be used.${NC}"
else
    echo "${YELLOW}[!] Starting up traefik, mysql and mailhog.${NC}"
    docker-compose up --build -d #Run traefik, mysql and mailhog containers
    echo "${GREEN}[!] Containers started up!${NC}"
fi

#Retrieve available webshops
echo '############### Here are the available webshops: ###############'
cd shops
webshops=(Oxid6)
i=0

#Show options to pick
for OUTPUT in "${webshops[@]}"
do
    echo '['$i']' ${webshops[$i]}
    i=$((i+1))
done
echo '['$i'] EXIT PROGRAM.'

#Has the user picked a webite to run?
read -n1 -r -p "${YELLOW}[?] Press a number to continue: ${NC}" num
echo \

if [ "$i" = "$num" ]; #No webshop picked - END
then
    echo "${RED}[!] Program shutting down..."
    docker-compose down
    echo "[!] Program closed down."
    exit 0
fi

#Is the webshop downloaded
if [ ! -f ./${webshops[$num]}/docker-compose.yml ]
then
    echo "${RED}[!]" ${webshops[$num]} "is not downloaded.${NC}"
    read -n1 -r -p "${YELLOW}[?] Would you like to download it?${NC} (${GREEN}y${NC}/${RED}n${NC}): " dwnld
    if [ "$dwnld" = "y" ] || [ "$dwnld" = "Y" ]; then #Download
        echo "${GREEN}[!] Downloading ${webshops[$num]}...${NC}"
        git clone https://github.com/SalimAtMollie/${webshops[$num]}xMollie ${webshops[$num]} #Download repo from github
    else
        echo "${RED}[!] Going back...${NC}"
        cd ../../
        ./startup.sh
    fi
fi

echo "${GREEN}[!]" ${webshops[$num]} "is downloaded.${NC}"
chmod u+x ./bootstrap.sh
./bootstrap.sh ${webshops[$num]} #Go into the webshops bootstrap shell script