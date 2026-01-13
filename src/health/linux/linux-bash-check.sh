#!/usr/bin/env bash

# Linux health check script

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly EXPECTED_OUTPUT="pong"

main() {
    if [[ "${BASH_VERSION:-}" == "" ]]; then
        printf "Error: %s: Invalid Bash environment\n" "${SCRIPT_NAME}" >&2
        return 1
    fi

    if [[ "$(uname -s)" != "Linux" ]]; then
        printf "Error: %s: Not running on Linux\n" "${SCRIPT_NAME}" >&2
        return 1
    fi

    printf "%s\n" "${EXPECTED_OUTPUT}"
    return 0
}

main "$@"