#!/bin/sh

# Duck DNS Update Script
# Automatically updates your Duck DNS domain with current IP address
# Configuration file: /config/duckdns.ini

set -e

# Default values
CONFIG_FILE="${CONFIG_FILE:-/config/duckdns.ini}"
LOG_FILE="${LOG_FILE:-/var/log/duck.log}"
API_URL="https://www.duckdns.org/update"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" >> "${LOG_FILE}"
    if [ "${level}" = "ERROR" ]; then
        echo -e "${RED}[${level}] ${message}${NC}" >&2
    elif [ "${level}" = "WARN" ]; then
        echo -e "${YELLOW}[${level}] ${message}${NC}" >&2
    else
        echo -e "${GREEN}[${level}] ${message}${NC}"
    fi
}

# Cleanup function
cleanup() {
    rm -f "${TEMP_FILE}" 2>/dev/null || true
}
trap cleanup EXIT

# Validate configuration file exists
if [ ! -f "${CONFIG_FILE}" ]; then
    log "ERROR" "Configuration file not found: ${CONFIG_FILE}"
    exit 1
fi

# Source configuration
if ! . "${CONFIG_FILE}"; then
    log "ERROR" "Failed to source configuration file: ${CONFIG_FILE}"
    exit 1
fi

# Validate required variables
if [ -z "${TOKEN}" ]; then
    log "ERROR" "TOKEN not configured in ${CONFIG_FILE}"
    exit 1
fi

if [ -z "${DOMAIN}" ]; then
    log "ERROR" "DOMAIN not configured in ${CONFIG_FILE}"
    exit 1
fi

log "INFO" "Starting Duck DNS update for domain: ${DOMAIN}"

# Get current IP address(es)
# Try to get IPv4 first
IPV4=$(curl -s -m 5 "https://ipv4.icanhazip.com" 2>/dev/null | tr -d '\n') || IPV4=""

# Try to get IPv6
IPV6=$(curl -s -m 5 "https://ipv6.icanhazip.com" 2>/dev/null | tr -d '\n') || IPV6=""

if [ -z "${IPV4}" ] && [ -z "${IPV6}" ]; then
    log "WARN" "Could not determine IP address"
fi

if [ -n "${IPV4}" ]; then
    log "INFO" "Detected IPv4: ${IPV4}"
fi

if [ -n "${IPV6}" ]; then
    log "INFO" "Detected IPv6: ${IPV6}"
fi

# Prepare temporary file for curl
TEMP_FILE=$(mktemp) || {
    log "ERROR" "Failed to create temporary file"
    exit 1
}

# Construct URL with parameters
UPDATE_URL="${API_URL}?domains=${DOMAIN}&token=${TOKEN}"

if [ -n "${IPV4}" ]; then
    UPDATE_URL="${UPDATE_URL}&ip=${IPV4}"
fi

if [ -n "${IPV6}" ]; then
    UPDATE_URL="${UPDATE_URL}&ipv6=${IPV6}"
fi

# Execute update
log "INFO" "Sending update request to Duck DNS API"

HTTP_CODE=$(curl -s -w "%{http_code}" -k -o "${TEMP_FILE}" "${UPDATE_URL}") || {
    log "ERROR" "Failed to execute curl request"
    exit 1
}

# Parse response
RESPONSE=$(cat "${TEMP_FILE}")

# Check HTTP status code
if [ "${HTTP_CODE}" != "200" ]; then
    log "ERROR" "HTTP error: ${HTTP_CODE}"
    log "ERROR" "Response: ${RESPONSE}"
    exit 1
fi

# Check Duck DNS response status
case "${RESPONSE}" in
    "OK")
        if [ -n "${IPV4}" ]; then
            log "INFO" "Successfully updated IPv4: ${IPV4}"
        fi
        if [ -n "${IPV6}" ]; then
            log "INFO" "Successfully updated IPv6: ${IPV6}"
        fi
        ;;
    "BADAUTH")
        log "ERROR" "Authentication failed - invalid token or domain"
        exit 1
        ;;
    "BADIP")
        log "ERROR" "Invalid IP address format"
        exit 1
        ;;
    "BADDOMAIN")
        log "ERROR" "Invalid domain"
        exit 1
        ;;
    *)
        log "ERROR" "Unexpected response: ${RESPONSE}"
        exit 1
        ;;
esac

log "INFO" "Duck DNS update completed successfully"
exit 0