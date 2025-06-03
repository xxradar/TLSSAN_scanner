#!/bin/bash

# Test script for tlssan_scan.sh
# This script should be run from the 'scripts' directory.

# Initialize a variable to track overall test status
all_tests_passed=true
test_count=0
passed_count=0

# Function to print test results
# $1: Test description
# $2: Expected exit code
# $3: Actual exit code
# $4: (Optional) Expected stderr message (will be checked with grep -q)
# $5: (Optional) Actual stderr output
# $6: (Optional) Expected stdout message (will be checked with grep -q)
# $7: (Optional) Actual stdout output
print_test_result() {
    local description="$1"
    local expected_code="$2"
    local actual_code="$3"
    local expected_stderr="$4"
    local actual_stderr="$5"
    local expected_stdout="$6"
    local actual_stdout="$7"
    local result="PASSED"

    ((test_count++))
    echo -n "Test: $description ... "

    if [ "$actual_code" -ne "$expected_code" ]; then
        result="FAILED (Expected exit code $expected_code, got $actual_code)"
        all_tests_passed=false
    elif [ -n "$expected_stderr" ] && ! echo "$actual_stderr" | grep -qF "$expected_stderr"; then
        result="FAILED (Expected stderr to contain '$expected_stderr', got: '$actual_stderr')"
        all_tests_passed=false
    elif [ -n "$expected_stdout" ] && ! echo "$actual_stdout" | grep -qF "$expected_stdout"; then
        result="FAILED (Expected stdout to contain '$expected_stdout', got: '$actual_stdout')"
        all_tests_passed=false
    fi

    if [ "$result" == "PASSED" ]; then
        ((passed_count++))
        echo -e "\033[32m$result\033[0m"
    else
        echo -e "\033[31m$result\033[0m"
    fi
}

# Make sure tlssan_scan.sh is executable
if [ ! -x ../tlssan_scan.sh ]; then
    echo "Error: ../tlssan_scan.sh is not executable. Please run chmod +x ../tlssan_scan.sh"
    exit 1
fi

echo "Starting tests for tlssan_scan.sh..."

# 1. Test for help option
echo "--- Testing Help Option ---"
stdout_help=$(../tlssan_scan.sh -h 2>&1)
exit_code_help=$?
print_test_result "Help option (-h)" 0 "$exit_code_help" "" "" "tlssan_scan  <insert your fqdn> <TLS port>" "$stdout_help"
if grep -q "openssl version" <<< "$stdout_help"; then
    print_test_result "Help option (-h) shows openssl version" 0 "$exit_code_help" "" "" "openssl version" "$stdout_help"
else
    print_test_result "Help option (-h) shows openssl version" 0 1 "" "" "openssl version" "$stdout_help" # Force fail
fi


# 2. Test for missing arguments
echo "--- Testing Missing Arguments ---"
stderr_no_args=$(../tlssan_scan.sh 2>&1 >/dev/null)
exit_code_no_args=$?
print_test_result "No arguments" 1 "$exit_code_no_args" "Usage: ../tlssan_scan.sh <fqdn> <port>" "$stderr_no_args"

stderr_missing_port=$(../tlssan_scan.sh google.com 2>&1 >/dev/null)
exit_code_missing_port=$?
print_test_result "Missing port argument" 1 "$exit_code_missing_port" "Usage: ../tlssan_scan.sh <fqdn> <port>" "$stderr_missing_port"

# 3. Test for invalid port
echo "--- Testing Invalid Port ---"
stderr_invalid_port=$(../tlssan_scan.sh google.com notaport 2>&1 >/dev/null)
exit_code_invalid_port=$?
print_test_result "Invalid port (not a number)" 1 "$exit_code_invalid_port" "Error: Port must be a number." "$stderr_invalid_port"

# 4. Test for openssl not found (simulated)
echo "--- Testing OpenSSL Not Found (Simulated) ---"
# Create a temporary directory and a dummy openssl script
temp_dir=$(mktemp -d)
dummy_openssl_path="$temp_dir/openssl"
echo "#!/bin/bash" > "$dummy_openssl_path"
echo "echo 'Mock openssl: command not found or error' >&2" >> "$dummy_openssl_path"
echo "exit 127" >> "$dummy_openssl_path"
chmod +x "$dummy_openssl_path"

# Prepend the temp directory to PATH
original_path=$PATH
export PATH="$temp_dir:$PATH"

stderr_openssl_not_found=$(../tlssan_scan.sh google.com 443 2>&1 >/dev/null)
exit_code_openssl_not_found=$?
print_test_result "OpenSSL not found (simulated)" 1 "$exit_code_openssl_not_found" "Error: openssl is not installed or not functional." "$stderr_openssl_not_found"

# Restore PATH and clean up
export PATH=$original_path
rm -rf "$temp_dir"


# 5. Test successful SAN retrieval
echo "--- Testing Successful SAN Retrieval ---"
# Note: The exact SAN entries for google.com might change.
# This test checks for common patterns.
# Allow a few retries for network reliability
success_san_retrieval=false
for i in {1..3}; do
    stdout_stderr_google=$(../tlssan_scan.sh google.com 443 2>&1)
    exit_code_google=$?
    if [ "$exit_code_google" -eq 0 ] && echo "$stdout_stderr_google" | grep -q "X509v3 Subject Alternative Name:" && echo "$stdout_stderr_google" | grep -q "DNS:"; then
        success_san_retrieval=true
        break
    fi
    echo "Attempt $i for SAN retrieval failed. Retrying in 2 seconds..."
    sleep 2
done

if $success_san_retrieval; then
    print_test_result "Successful SAN retrieval (google.com:443)" 0 "$exit_code_google" "" "" "X509v3 Subject Alternative Name:" "$stdout_stderr_google"
    print_test_result "Successful SAN retrieval (google.com:443) contains DNS entry" 0 "$exit_code_google" "" "" "DNS:" "$stdout_stderr_google"
else
    print_test_result "Successful SAN retrieval (google.com:443)" 0 "$exit_code_google" "" "" "X509v3 Subject Alternative Name:" "$stdout_stderr_google" # This will show as failed
fi


# 6. Test connection failure
echo "--- Testing Connection Failure ---"
# Using a port that is unlikely to be open on a non-existent domain
stderr_conn_failure=$(../tlssan_scan.sh non-existent-domain-$RANDOM.internal 12345 2>&1 >/dev/null)
exit_code_conn_failure=$?
# The error message from s_client can vary, so we check for a broader connection error indication
# For example, it could be "connect: No such file or directory" or "connect: Connection refused" or "getaddrinfo: Name or service not known"
print_test_result "Connection failure (non_existent_domain.internal:12345)" 1 "$exit_code_conn_failure" "Error: Could not connect" "$stderr_conn_failure"


echo "--- Test Summary ---"
echo "Total tests: $test_count"
echo "Passed tests: $passed_count"
if [ "$passed_count" -ne "$test_count" ]; then
    echo -e "\033[31mSome tests FAILED.\033[0m"
    exit 1
else
    echo -e "\033[32mAll tests PASSED.\033[0m"
    exit 0
fi
