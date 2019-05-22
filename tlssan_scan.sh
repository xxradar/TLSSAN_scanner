#!/bin/bash

if [ $1 == "-h" ]; then
    openssl version
    echo "******************************************"
    echo "tlssan_scan  <insert your fqdn> <TLS port>"
    echo "******************************************"
    exit 0
fi

echo "*************************************************************"
echo "obtaining X.509 SAN extensions ... (may take up to 5 seconds)"
echo "*************************************************************"

(echo -e "GET / HTTP/1.1\r\nHost: $1\r\n\r\n"; sleep 5) | openssl s_client -servername $1 -connect $1:$2 </dev/null  | openssl x509 -text | grep -A1 "X509v3 Subject Alternative Name: " >san_log.txt

echo "\r\n"
echo "******************************************"
echo "Displaying the results"
echo "******************************************"

cat san_log.txt

echo "******************************************"
echo "Completed"
echo "******************************************"
