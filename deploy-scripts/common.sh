#!/usr/bin/env bash

# Common functions

# Error check function
# Param 1: return code, pass the last one with $?
# Param 2: error text to display
check_errs()
{
  if [ "${1}" -ne "0" ]; then
    echo "ERROR # ${1} : ${2}"
    exit ${1}
  fi
}

# Package exists check function
# Param 1: name of the package to check
check_package () {

    install_status=$( dpkg-query -W -f='${Status}' $1)
    if [ "$install_status" == "install ok installed" ]
    then
        echo "$1 installed"
    else
        echo "Please install $1 and run this script again"
        echo
        exit 1
    fi
}

# Password generator function
# Param 1: file to store the password in
# Param 2: number of characters to generate
create_password () {
    if [ -e $1 ]
    then
        echo "$1 already exists"
    else
        check_package pwgen
        printf $(pwgen -s $2 1) >> $1
        check_errs $? "Falied creating password"
        echo "$1 created"
    fi
    chmod 664 $1
    check_errs $? "Failed setting password permissions"
}
