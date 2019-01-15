#!/usr/bin/env bash

#
# Test Current Deployment
#
#

# Import common functions
source ./common.sh

# Print header
clear
echo "====================================="
echo "           Testing Deployment"
echo

# Test that nginx is serving the website
echo "Requesting site..."
curl -I 172.16.0.5 2>&1 | egrep "HTTP.+200 OK"
check_errs $? "Bad HTTP response when requesting the site"

echo
echo "Deployment passed all tests"
echo "Project is running"
echo
