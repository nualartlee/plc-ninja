#!/usr/bin/env bash

# Creates passwords, keys, etc

# Work from projects's directory
cd "${0%/*}/.."

# Import common functions
source deploy-scripts/common.sh

# Check if required packages are installed
echo "Checking required packages"
check_package pwgen
echo

# Create a directory to store passwords
if [ -e secrets ]
then
    echo "secrets directory already exists"
else
    echo "Creating secrets directory"
    mkdir secrets
    check_errs $? "Failed creating secrets directory"
fi
chmod 660 secrets
check_errs $? "Failed setting secret directory permissions"

# Create passwords
#create_password secrets/postgres_password.txt 27
#create_password secrets/django_secret_key.txt 47
#create_password secrets/django_admin_pass.txt 27

# Get email address for LetsEncrypt certbot
file=secrets/certbot_email.txt
if [ -e $file ]
then
    echo "LetsEncrypt certbot administrator email already exists"
else
    echo
    echo "Enter administrators email for LetsEncrypt certbot certificate creation"
    read email
    echo $email >> $file
    check_errs $? "Failed storing LetsEncrypt certbot email"
fi

# Ensure docker is running
service docker start
check_errs $? "Failed starting docker"

# Create docker main network if not present
if [ -z "$(docker network ls | grep nginx_main)" ]
then
    echo "creating docker network 'nginx_main'"
    docker network create --subnet 172.16.0.0/16 nginx_main
    check_errs $? "Failed creating docker network"
else
    echo "docker network 'nginx_main' already present"
fi
check_errs $? "Failed creating docker network"
