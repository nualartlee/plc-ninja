#!/usr/bin/env bash

#
# Rollback To Previous Version
#
# Pulls and deploys the previous version of the current branch from remote origin.
#

# Work from projects's directory
cd "${0%/*}/.."

# Import common functions
source deploy-scripts/common.sh

# Assume the project's name is the same as the containing directory
projectname=${PWD##*/}

# Print header
echo "====================================="
echo "      Revert $projectname"
echo

# Check user is root
check_errs $EUID "This script must be run as root"

# Get the owner of the project
projectowner=$(ls -ld $PWD | awk '{print $3}')

# Determine previous version sudo -u $projectowner git hash
previous=$(sudo -u $projectowner git log --format=%H | sed -n 2p)
check_errs $? "Unable to determine previous git version hash"

# Rollback previous version
sudo -u $projectowner git reset $previous
check_errs $? "Unable to git-reset previous version from repository"

# Stash current changes
sudo -u $projectowner git stash
check_errs $? "Unable to stash changes in repository"

# Run any custom build script
if [ -e scripts/build.sh ]
then
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
echo "Rollback Completed"
echo

# Run tests
echo "Starting tests..."
deploy-scripts/deployment_test.sh
check_errs $? "Test failed."

# Completed successfully
echo
echo "Project Running"
echo
echo
