#!/bin/bash

# Script to scan TLS/SSL certificates for Subject Alternative Names (SANs)

# Function to display usage message and exit
usage() {
    echo "Usage: $0 <fqdn> <port>" >&2
    echo "Example: $0 www.example.com 443" >&2
    exit 1
}

# Function to display help message and exit
help_message() {
    echo "tlssan_scan  <insert your fqdn> <TLS port>"
    echo "Script to scan TLS/SSL certificates for Subject Alternative Names (SANs)."
    echo ""
    echo "Arguments:"
    echo "  <fqdn>      Fully Qualified Domain Name of the target server."
    echo "  <port>      TLS port of the target server."
    echo ""
    echo "Options:"
    echo "  -h, --help  Show this help message and openssl version."
    echo ""
    openssl version # This will be checked for functionality below too
    exit 0
}

# Initial check if openssl command is even available
if ! command -v openssl &> /dev/null; then
    echo "Error: openssl command not found. Please install openssl and try again." >&2
    exit 1
fi

# Check if openssl is functional by running 'openssl version'
if ! openssl version &>/dev/null; then
    echo "Error: openssl is not installed or not functional. Please ensure openssl is correctly installed and in your PATH." >&2
    exit 1
fi

# Check for help option after ensuring openssl is somewhat functional (for `openssl version` in help)
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    help_message
fi

# Validate number of arguments (after help, so help doesn't require args)
if [ "$#" -ne 2 ]; then
    usage
fi

fqdn="$1"
port="$2"

# Validate that port is a number
if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    echo "Error: Port must be a number." >&2
    usage # Call usage to also print usage info
fi

echo "*************************************************************"
echo "Obtaining X.509 SAN extensions for $fqdn:$port..."
echo "*************************************************************"

# Perform the openssl s_client command and process the output directly
openssl_output=$(echo -e "GET / HTTP/1.1\r\nHost: $fqdn\r\n\r\n" | openssl s_client -servername "$fqdn" -connect "$fqdn:$port" 2>/dev/null)

# Check for connection errors based on openssl s_client exit status or empty output
if [ $? -ne 0 ] || [ -z "$openssl_output" ]; then
    echo "Error: Could not connect to $fqdn:$port. Please check the FQDN and port, and ensure the server is reachable." >&2
    exit 1
fi

# Extract and display SANs
parsed_cert=$(echo "$openssl_output" | openssl x509 -text 2>/dev/null)

if [ -z "$parsed_cert" ]; then
    echo "Error: Could not parse the X.509 certificate from $fqdn:$port. The server might not be sending a valid certificate." >&2
    exit 1
fi

sans_output=$(echo "$parsed_cert" | grep -A1 "X509v3 Subject Alternative Name:")

if [ -n "$sans_output" ]; then
    echo "$sans_output"
else
    echo "No X509v3 Subject Alternative Name extension found in the certificate for $fqdn:$port."
fi

echo "\r\n"
echo "******************************************"
echo "Scan completed for $fqdn:$port"
echo "******************************************"

exit 0
