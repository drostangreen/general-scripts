#!/bin/bash

set -e

. ./extra/cert_defaults

cd $ca_root_path

Help(){
    echo "This script can be used to generate new certs"
    echo "or renew existing ones. It has the below options:"
    echo
    echo "-u    URL for the cert. *REQUIRED*"
    echo "-i    IP for cert. Keeps the orignal IP if not entered *OPTIONAL*"
    echo "-s    Skips Checks for existing certs *OPTIONAL*"
    echo "-n    New Cert generation. *OPTIONAL*"
    echo "-h    Show help."
}

ERRCleanUp(){
    rm /tmp/csr-names
    rm csr/$cert_name-csr.conf
    rm private/$cert_name.key
    [[ -f csr/$cert_name-csr.conf.bak ]] && mv csr/$cert_name-csr.conf.bak csr/$cert_name-csr.conf
    echo "Error on line $1"
}

trap 'ERRCleanUp $LINENO' ERR
trap "rm -f /tmp/csr-names > /dev/null 2>&1" EXIT

CSR-CONF-GEN(){
cat << EOF > csr/$cert_name-csr.conf
[ req ]
# 'man req'
# Used by the req command
default_bits		    = 2048
distinguished_name	    = req_distinguished_name
req_extensions		    = req_ext
prompt		            = no

[ req_distinguished_name ]
# Certificate signing request
countryName		        = $countryName
stateOrProvinceName    	= $stateOrProvinceName
organizationName	    = $organizationName
commonName		        = $url

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
EOF
}

GEN-PRIVKEY-CSR(){
    CSR-CONF-GEN
    [[ -f /tmp/csr-names ]] && sed -i.bak '/^\[ alt_names \]/r /tmp/csr-names' csr/$cert_name-csr.conf
    openssl genrsa -out private/$cert_name.key 2048
    openssl req -new -key private/$cert_name.key -sha256 -out csr/$cert_name.csr -config csr/$cert_name-csr.conf
}

SKIP_VALIDATION=false
new_cert=false
count=1
counter=1

while getopts hsnu:i: flag
do
    case $flag in
        h)
        Help
        exit 0
        ;;
        
        u)
        url=$OPTARG
        cert_name="${OPTARG%%.*}"
        echo "DNS.$count = $url" >> /tmp/csr-names
        count=$((count + 1))
        ;;

        i)
        ip=$OPTARG
        echo "IP.$counter = $ip" >> /tmp/csr-names
        counter=$((counter + 1))
        ;;

        s)
        SKIP_VALIDATION=true
        ;;

        n)
        new_cert=true
        CSR-CONF-GEN
        ;;


        \?)
        echo "Invalid Option"
        Help
        exit 1
        ;;

    esac
done

############### Error Checking ##########################

[[ ! -v cert_name ]] && echo "A URL (option -u) is Required. Exiting..." && exit 1

if [[ $SKIP_VALIDATION == false ]] && grep -q $cert_name index; then 
    echo "Cert possibly found in Index."
    echo "Cert may need to be revoked to renew an existing cert."
    echo "Or run again with -s option to skip this check"
    exit 1
fi


################ Start Of Script ##########################

[[ $new_cert == true ]] && GEN-PRIVKEY-CSR
[[ $new_cert == false ]] && [[ -f /tmp/csr-names ]] && sed -i.bak '/^\[ alt_names \]/r /tmp/csr-names' csr/$cert_name-csr.conf

openssl ca -config root-ca.conf -notext -in csr/$cert_name.csr -out certs/$cert_name.crt -extensions req_ext -extfile csr/$cert_name-csr.conf

echo "Your Certificate has been created at certs/$cert_name.crt"
   
