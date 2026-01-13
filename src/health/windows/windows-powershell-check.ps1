#!/usr/bin/env pwsh

# PowerShell health check script

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

try {
    Write-Output 'pong'
    exit 0
}
catch {
    Write-Error "Health check failed: $_"
    exit 1
}