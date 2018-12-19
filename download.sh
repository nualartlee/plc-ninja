#!/usr/bin/env bash

# Git repository download

# Import common functions
source ./common.sh

# Make sure repo is on master branch
git checkout master
check_errs $? "Must be on master branch"

# Pull from origin
git pull
check_errs $? "Unable to pull from remote repository"

