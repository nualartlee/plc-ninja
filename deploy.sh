#!/usr/bin/env bash

#
# Project Deployment Script
#
# Pulls the latest version of the current from remote origin.
# Creates docker containers, passwords, keys, etc
#
# The project should already be present under git with remote origin
# set up before running this script

# Work from script's directory
cd "${0%/*}"

# Import common functions
source scripts/common.sh

# Assume the project's name is the same as the containing directory
projectname=${PWD##*/}

# Print header
clear
echo "====================================="
echo "           Deploy $projectname"
echo

# Check user is root
check_errs $EUID "This script must be run as root"

# Get the owner of the project
projectowner=$(ls -ld $PWD | awk '{print $3}')

# Check if required packages are installed
echo "Checking required packages"
check_package docker
check_package docker-compose
echo

# Pull latest version from remote origin
sudo -u $projectowner git pull
check_errs $? "Unable to pull from remote repository"

# Run any custom build script
if [ -e scripts/build.sh ]
then
    echo "secrets directory already exists"
else
    echo "Creating secrets directory"
    mkdir secrets
    check_errs $? "Failed creating secrets directory"
fi
chmod 660 secrets
check_errs $? "Failed setting secret directory permissions"

# Get email address for LetsEncrypt certbot
file=secrets/certbot_email.txt
if [ -e $file ]
then
    echo "LetsEncrypt certbot administrator email already exists"
    echo "Running custom build script"
    scripts/build.sh
    check_errs $? "Custom build script failed"
else
    echo "No custom build scripts"
fi

# Ensure docker is running
service docker start
check_errs $? "Failed starting docker"

# Stop containers
docker-compose down
check_errs $? "Failed stopping containers"

# Rebuild containers
echo
echo "Building containers"
docker-compose build
check_errs $? "Failed building containers"

# Run containers in background
echo
echo "Starting containers"
docker-compose up -d &
check_errs $? "Failed starting containers"

# Allow for startup
sleep 5

# Run any custom post_build script
if [ -e scripts/post_build.sh ]
then
    echo "Running custom post_build script"
    scripts/post_build.sh
    check_errs $? "Custom post_build script failed"

else
    echo "No custom post_build scripts"
fi

echo
echo "Deployment Completed"
echo "Project is running"
echo
