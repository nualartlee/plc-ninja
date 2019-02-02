#!/usr/bin/env bash

# Work from projects's directory
cd "${0%/*}/.."

# Import common functions
source deploy-scripts/common.sh

# Test that nginx is responding on port 80
echo "Requesting site..."
curl -I 172.16.0.5:80 2>&1 | egrep "HTTP"
check_errs $? "Bad HTTP response when requesting the site"
