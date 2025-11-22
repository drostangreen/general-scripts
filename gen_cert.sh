#!/bin/bash

set -e

. ./cert_defaults

read -p "URL Cert will point to: " common_name
read -p "IP Address: " ip_address
read -p "Cert Name: " cert_name

cd /home/$(whoami)/ca

cat << EOF > csr/$cert_name-csr.conf
[ req ]
# 'man req'
# Used by the req command
default_bits		    = 2048
distinguished_name	    = req_distinguished_name
req_extensions		    = req_ext
prompt			        = no

[ req_distinguished_name ]
# Certificate signing request
countryName		        = $countryName
stateOrProvinceName	    = $stateOrProvinceName
organizationName	    = $organizationName
commonName		        = $common_name

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $common_name
IP.1 = $ip_address
EOF

openssl genrsa -out private/$cert_name.key

openssl req -new -key private/$cert_name.key -sha256 -out csr/$cert_name.csr -config csr/$cert_name-csr.conf

openssl ca -config root-ca.conf -notext -in csr/$cert_name.csr -out certs/$cert_name.crt -extensions req_ext -extfile csr/$cert_name-csr.conf