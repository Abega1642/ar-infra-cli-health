@echo off
setlocal enabledelayedexpansion

REM Test for Windows CMD health check script

set TESTS_PASSED=0
set TESTS_FAILED=0
set EXPECTED_OUTPUT=pong

for %%I in ("%~dp0..") do set "TESTS_DIR=%%~fI"
for %%I in ("!TESTS_DIR!\..") do set "PROJECT_ROOT=%%~fI"
set SCRIPT_PATH=!PROJECT_ROOT!\src\health\windows\windows-cmd-check.bat

echo.
echo ++++++++++++++++++++++++++++++++++++++++++
echo CMD Health Check Test Suite
echo ++++++++++++++++++++++++++++++++++++++++++
echo.

call :test_script_exists
call :test_script_execution
call :test_script_output

echo.
echo ++++++++++++++++++++++++++++++++++++++++++
echo Test Results
echo ++++++++++++++++++++++++++++++++++++++++++
echo Passed: !TESTS_PASSED!
echo Failed: !TESTS_FAILED!
echo ++++++++++++++++++++++++++++++++++++++++++
echo.

if !TESTS_FAILED! gtr 0 (
    exit /b 1
)

exit /b 0

:test_script_exists
set TEST_NAME=CMD health check script exists

if not exist "!SCRIPT_PATH!" (
    call :write_test_result "!TEST_NAME!" "FAIL" "Script not found at: !SCRIPT_PATH!"
    goto :eof
)

call :write_test_result "!TEST_NAME!" "PASS" ""
goto :eof

:test_script_execution
set TEST_NAME=CMD health check script executes without errors

call "!SCRIPT_PATH!" >nul 2>&1
set EXIT_CODE=!ERRORLEVEL!

if !EXIT_CODE! neq 0 (
    call :write_test_result "!TEST_NAME!" "FAIL" "Exit code: !EXIT_CODE!"
    goto :eof
)

call :write_test_result "!TEST_NAME!" "PASS" ""
goto :eof

:test_script_output
set TEST_NAME=CMD health check script returns 'pong'

for /f "delims=" %%i in ('call "!SCRIPT_PATH!" 2^>nul') do set ACTUAL_OUTPUT=%%i

if "!ACTUAL_OUTPUT!" neq "!EXPECTED_OUTPUT!" (
    call :write_test_result "!TEST_NAME!" "FAIL" "Expected '!EXPECTED_OUTPUT!', got: '!ACTUAL_OUTPUT!'"
    goto :eof
)

call :write_test_result "!TEST_NAME!" "PASS" ""
goto :eof

:write_test_result
set TEST_NAME=%~1
set RESULT=%~2
set ERROR_MSG=%~3

if "!RESULT!"=="PASS" (
    echo [PASS] !TEST_NAME!
    set /a TESTS_PASSED+=1
) else (
    echo [FAIL] !TEST_NAME!
    if not "!ERROR_MSG!"=="" (
        echo        !ERROR_MSG!
    )
    set /a TESTS_FAILED+=1
)
goto :eof