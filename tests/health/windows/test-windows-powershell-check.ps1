#!/usr/bin/env pwsh

# Test for Windows PowerShell health check script

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$script:TestsPassed = 0
$script:TestsFailed = 0

$ProjectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$ScriptPath = Join-Path $ProjectRoot "src\health\windows\windows-powershell-check.ps1"

function Write-TestResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TestName,

        [Parameter(Mandatory = $true)]
        [bool]$Passed,

        [Parameter(Mandatory = $false)]
        [string]$ErrorMessage = ''
    )

    if ($Passed) {
        Write-Host "[PASS] $TestName" -ForegroundColor Green
        $script:TestsPassed++
    }
    else {
        Write-Host "[FAIL] $TestName" -ForegroundColor Red
        if ($ErrorMessage) {
            Write-Host "       $ErrorMessage" -ForegroundColor Red
        }
        $script:TestsFailed++
    }
}

function Test-ScriptExists {
    $testName = "PowerShell health check script exists"

    try {
        $exists = Test-Path -Path $ScriptPath -PathType Leaf
        Write-TestResult -TestName $testName -Passed $exists -ErrorMessage "Script not found at: $ScriptPath"
        return $exists
    }
    catch {
        Write-TestResult -TestName $testName -Passed $false -ErrorMessage $_.Exception.Message
        return $false
    }
}

function Test-ScriptExecution {
    $testName = "PowerShell health check script executes without errors"

    try {
        $output = & $ScriptPath 2>&1
        $exitCode = $LASTEXITCODE

        $passed = ($exitCode -eq 0)
        Write-TestResult -TestName $testName -Passed $passed -ErrorMessage "Exit code: $exitCode"
        return $passed
    }
    catch {
        Write-TestResult -TestName $testName -Passed $false -ErrorMessage $_.Exception.Message
        return $false
    }
}

function Test-ScriptOutput {
    $testName = "PowerShell health check script returns 'pong'"

    try {
        $output = & $ScriptPath 2>&1 | Out-String
        $output = $output.Trim()

        $passed = ($output -eq 'pong')
        Write-TestResult -TestName $testName -Passed $passed -ErrorMessage "Expected 'pong', got: '$output'"
        return $passed
    }
    catch {
        Write-TestResult -TestName $testName -Passed $false -ErrorMessage $_.Exception.Message
        return $false
    }
}

function Test-NoStderr {
    $testName = "PowerShell health check script produces no stderr output"

    try {
        $stderr = $null
        $stdout = & $ScriptPath 2>&1 | ForEach-Object {
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                $stderr = $_
            }
        }

        $passed = ($null -eq $stderr)
        Write-TestResult -TestName $testName -Passed $passed -ErrorMessage "Stderr content: $stderr"
        return $passed
    }
    catch {
        Write-TestResult -TestName $testName -Passed $false -ErrorMessage $_.Exception.Message
        return $false
    }
}

function Invoke-AllTests {
    Write-Host "`n++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor Cyan
    Write-Host "PowerShell Health Check Test Suite" -ForegroundColor Cyan
    Write-Host "++++++++++++++++++++++++++++++++++++++++++`n" -ForegroundColor Cyan

    $scriptExists = Test-ScriptExists

    if ($scriptExists) {
        Test-ScriptExecution
        Test-ScriptOutput
        Test-NoStderr
    }

    Write-Host "`n++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor Cyan
    Write-Host "Test Results" -ForegroundColor Cyan
    Write-Host "++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor Cyan
    Write-Host "Passed: $script:TestsPassed" -ForegroundColor Green
    Write-Host "Failed: $script:TestsFailed" -ForegroundColor $(if ($script:TestsFailed -eq 0) { 'Green' } else { 'Red' })
    Write-Host "++++++++++++++++++++++++++++++++++++++++++`n" -ForegroundColor Cyan

    if ($script:TestsFailed -gt 0) {
        exit 1
    }

    exit 0
}

Invoke-AllTests