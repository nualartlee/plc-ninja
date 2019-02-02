#!/usr/bin/env bash

#
# Test Current Deployment
#
#

# Work from projects's directory
cd "${0%/*}/.."

# Import common functions
source deploy-scripts/common.sh

# Assume the project's name is the same as the containing directory
projectname=${PWD##*/}

# Print header
echo "====================================="
echo "           Testing $projectname"
echo

# Run any custom test script
if [ -e scripts/test.sh ]
then
    echo "Running custom test script"
    scripts/test.sh
    check_errs $? "Custom test script failed"

else
    echo "No custom test scripts"
fi

echo
echo "Deployment passed all tests"
echo
