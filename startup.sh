#!/bin/bash

#Welcome the User
echo '##### Welcome to the Mollie Webshop Local Environment tool. ##### '

#Check traefik, mysql and mailhog container status.
result=$(docker-compose ps --services --filter "status=running")

if [[ "$result" == *"traefik"* ]] \
&& [[ "$result" == *"mysql"* ]] \
&& [[ "$result" == *"mailhog"* ]] \
&& [[ "$result" == *"phpmyadmin"* ]]; then #Are the containers running?
    echo '[!] Traefik, mysql and mailhog are ready to be used.'
else
    echo '[!] Starting up traefik, mysql and mailhog.'
    docker-compose up --build -d #Run traefik, mysql and mailhog containers
fi

#Retrieve available webshops
echo '############### Here are the available webshops: ###############'
cd shops
webshops=(Oxid6 Magento2)
i=0

#Show options to pick
for OUTPUT in "${webshops[@]}"
do
    echo '['$i']' ${webshops[$i]}
    i=$((i+1))
done
echo '['$i'] EXIT PROGRAM.'

#Has the user picked a webite to run?
read -n1 -r -p "[?] Press a number to continue: " num
echo \

if [ "$i" = "$num" ]; #No webshop picked - END
then
    echo '[!] Program shutting down...'
    docker-compose down
    echo '[!] Program closed down.'
    exit 0
fi

#Is the webshop downloaded
if [ ! -f ./${webshops[$num]}/docker-compose.yml ]
then
    echo '[!]' ${webshops[$num]} 'is not downloaded.'
    read -n1 -r -p "[?] Would you like to download it? (y/n): " dwnld
    echo $dwnld
    if [ "$dwnld" = "y" ]; then #Download
        echo "[!] Downloading ${webshops[$num]}..."
        git clone https://github.com/SalimAtMollie/${webshops[$num]}xMollie ${webshops[$num]} #Download repo from github
    else
        echo "[!] Going back..."
        cd ../../
        ./startup.sh
    fi
fi

echo '[!]' ${webshops[$num]} 'is downloaded.'
chmod u+x ./bootstrap.sh
./bootstrap.sh ${webshops[$num]} #Go into the webshops bootstrap shell script