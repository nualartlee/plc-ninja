#!/usr/bin/env bash

# Initial setup
# Creates databases, passwords and keys

# Print header
clear
echo "====================================="
echo "           Initial Setup"
echo

# Must be run as root, exit otherwise
if [ "$EUID" -ne 0 ]
then
  echo "Please run as root"
  echo
  exit
fi

# Package exists check function
check_package () {

    install_status=$( dpkg-query -W -f='${Status}' $1)
    if [ "$install_status" == "install ok installed" ]
    then
        echo "$1 installed"
    else
        echo "Please install $1 and run this script again"
        echo
        exit
    fi
}

# Password generator function
create_password () {
    if [ -e $1 ]
    then
        echo "$1 already exists"
    else
        printf $(pwgen -s $2 1) >> $1
        echo "$1 created"
    fi
    chmod 664 $1
}

# Check if required packages are installed
echo "Checking required packages"
check_package pwgen
check_package docker
check_package docker-compose
echo

# Create a directory to store passwords
if [ -e secrets ]
then
    echo "secrets directory already exists"
else
    echo "Creating secrets directory"
    mkdir secrets
fi
chmod 660 secrets

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
fi

# Start Docker
service docker start

# Building containers
echo
echo "Building containers"
docker-compose -f docker-compose.yml build

# Run containers in background
echo
echo "Starting containers"
docker-compose up -d &

# Allow for startup
sleep 5

echo
echo "Initial Setup Completed"
echo "Project is running"
echo
