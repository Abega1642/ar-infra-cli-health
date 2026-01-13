@echo off
REM CMD health check script

setlocal

echo pong
if errorlevel 1 (
    echo Error: Health check failed >&2
    exit /b 1
)

exit /b 0
