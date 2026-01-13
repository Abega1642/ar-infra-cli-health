#!/usr/bin/env bash

# Windows Bash health check script

set -euo pipefail

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_NAME
readonly EXPECTED_OUTPUT="pong"

main() {
    if [[ "${BASH_VERSION:-}" == "" ]]; then
        printf "Error: %s: Invalid Bash environment\n" "${SCRIPT_NAME}" >&2
        return 1
    fi

    printf "%s\n" "${EXPECTED_OUTPUT}"
    return 0
}

main "$@"