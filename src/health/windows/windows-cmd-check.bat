@echo off
setlocal enabledelayedexpansion

REM CMD health check script

if not defined ERRORLEVEL set ERRORLEVEL=0

if "%CMDCMDLINE%"=="" (
    echo Error: Invalid execution environment >&2
    exit /b 1
)

echo pong

if !ERRORLEVEL! neq 0 (
    echo Error: Health check failed >&2
    exit /b 1
)

exit /b 0