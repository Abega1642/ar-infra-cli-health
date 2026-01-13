#!/usr/bin/env bash

# Test for Windows Bash health check script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
readonly PROJECT_ROOT

readonly SCRIPT_PATH="${PROJECT_ROOT}/src/health/windows/windows-bash-check.sh"
readonly EXPECTED_OUTPUT="pong"

tests_passed=0
tests_failed=0

write_test_result() {
	local test_name="${1}"
	local result="${2}"
	local error_message="${3:-}"

	if [[ "${result}" == "PASS" ]]; then
		printf "[PASS] %s\n" "${test_name}"
		((tests_passed++))
	else
		printf "[FAIL] %s\n" "${test_name}"
		if [[ -n "${error_message}" ]]; then
			printf "       %s\n" "${error_message}"
		fi
		((tests_failed++))
	fi
}

test_script_exists() {
	local test_name="Windows Bash health check script exists"

	if [[ ! -f "${SCRIPT_PATH}" ]]; then
		write_test_result "${test_name}" "FAIL" "Script not found at: ${SCRIPT_PATH}"
		return 1
	fi

	write_test_result "${test_name}" "PASS"
	return 0
}

test_script_executable() {
	local test_name="Windows Bash health check script is executable"

	if [[ ! -x "${SCRIPT_PATH}" ]]; then
		write_test_result "${test_name}" "FAIL" "Script is not executable"
		return 1
	fi

	write_test_result "${test_name}" "PASS"
	return 0
}

test_script_execution() {
	local test_name="Windows Bash health check script executes without errors"
	local exit_code=0

	"${SCRIPT_PATH}" >/dev/null 2>&1 || exit_code=$?

	if [[ ${exit_code} -ne 0 ]]; then
		write_test_result "${test_name}" "FAIL" "Exit code: ${exit_code}"
		return 1
	fi

	write_test_result "${test_name}" "PASS"
	return 0
}

test_script_output() {
	local test_name="Windows Bash health check script returns 'pong'"
	local actual_output

	actual_output="$("${SCRIPT_PATH}" 2>/dev/null)"

	if [[ "${actual_output}" != "${EXPECTED_OUTPUT}" ]]; then
		write_test_result "${test_name}" "FAIL" "Expected '${EXPECTED_OUTPUT}', got: '${actual_output}'"
		return 1
	fi

	write_test_result "${test_name}" "PASS"
	return 0
}

test_no_stderr() {
	local test_name="Windows Bash health check script produces no stderr output"
	local stderr_output

	stderr_output="$("${SCRIPT_PATH}" 2>&1 >/dev/null)"

	if [[ -n "${stderr_output}" ]]; then
		write_test_result "${test_name}" "FAIL" "Stderr content: ${stderr_output}"
		return 1
	fi

	write_test_result "${test_name}" "PASS"
	return 0
}

run_all_tests() {
	printf "\n++++++++++++++++++++++++++++++++++++++++++\n"
	printf "Windows Bash Health Check Test Suite\n"
	printf "++++++++++++++++++++++++++++++++++++++++++\n\n"

	if test_script_exists; then
		test_script_executable
		test_script_execution
		test_script_output
		test_no_stderr
	fi

	printf "\n++++++++++++++++++++++++++++++++++++++++++\n"
	printf "Test Results\n"
	printf "++++++++++++++++++++++++++++++++++++++++++\n"
	printf "Passed: %d\n" "${tests_passed}"
	printf "Failed: %d\n" "${tests_failed}"
	printf "++++++++++++++++++++++++++++++++++++++++++\n\n"

	if [[ ${tests_failed} -gt 0 ]]; then
		return 1
	fi

	return 0
}

main() {
	run_all_tests
}

main "$@"
