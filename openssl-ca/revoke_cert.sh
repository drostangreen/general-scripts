#!/bin/bash

set -e

Help(){
    echo "This script revokes certs"
    echo
    echo "-c    Cert to be revoked *REQUIRED*"
    echo "-h    Show help. *OPTIONAL*"
}

while getopts hc: flag
do
    case $flag in
        h)
        Help
        exit 0
        ;;
        
        c)
        cert_name=${OPTARG##*/}
        ;;


        \?)
        echo "Invalid Option"
        Help
        exit 1
        ;;

    esac
done

############### Error Checking ##########################
[[ ! -v cert_name ]] && echo "Cert Name (option -c) must be defined. Exiting..." && exit 1
[[ ! -f "$ca_root_path/certs/$cert_name" ]] && echo "Incorrect Cert Name. Exiting..." && exit 1

################ Start Of Script ##########################
openssl ca -revoke certs/$cert_name -config root-ca.conf

