#!/bin/bash
#set -x

echo '##### Welcome to the Mollie Webshop Local Environment tool. ##### '
echo '[!] Starting up traefik, mysql and mailhog.'
docker-compose up --build -d
echo '############### Here are the available webshops: ###############'


cd shops
array=($(ls -d *))
i=0

# SHOW OPTIONS
for OUTPUT in "${array[@]}"
do
    echo '['$i']' ${array[$i]}
    i=$((i+1))
done
echo '['$i'] EXIT PROGRAM.'

read -n1 -r -p "[?] Press a number to continue: " num

echo \

if [ "$i" = "$num" ];
then
    echo '[!] Program shutting down...'
    docker-compose down
    echo '[!] Program closed down.'
    exit 0
fi

cd ./${array[$num]}
if [ -f ./files/docker-compose.yml ] #Check if shop is Downloaded
then
    echo '[!]' ${array[$num]} 'is already downloaded.'
    chmod u+x ./${array[$num]}.sh
    ./${array[$num]}.sh
else
    echo '[!]' ${array[$num]} 'is not downloaded.'
    read -n1 -r -p "[?] Would you like to download it? (y/n): " dwnld
    echo $dwnld
    if [ "$dwnld" = "y" ]; then #Download and run
        echo "[!] Downloading ${array[$num]}..."
        git clone https://github.com/SalimAtMollie/docker-${array[$num]}xMollie files #Download repo from github
        echo "[!] Downloaded ${array[$num]}"
        chmod u+x ./${array[$num]}.sh
        ./${array[$num]}.sh #Go into the webshops bootstrap shell script
    else
        echo "[!] Going back..."
        cd ../../
        ./startup.sh
    fi
fi