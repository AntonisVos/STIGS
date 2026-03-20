<#
.SYNOPSIS

# This PowerShell script remediates STIG ID WN11-CC-000100 by preventing the system 
# from downloading print driver packages over HTTP, which could allow sensitive 
# information to be sent outside the enterprise or permit uncontrolled updates to the system.
# It creates the required registry key under HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers 
# and sets the DisableWebPnPDownload value to 1, corresponding to the Group Policy setting under 
# Computer Configuration -> Administrative Templates -> System -> Internet Communication Management -> Internet Communication settings.
# The script includes a built-in verification block that confirms the value was written correctly 
# before exiting, and intentionally omits gpupdate /force to prevent any conflicting Group Policy Object 
# from overwriting the registry value before the Nessus scan executes.


.NOTES
    Author          : Antonis Vosmandros
    LinkedIn        : linkedin.com/in/antonisvos
    GitHub          : github.com/antonisvos
    Date Created    : 2026-03-20
    Last Modified   : 2026-03-20
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000010

.TESTED ON
    Date(s) Tested  : 2026-03-20
    Tested By       : Antonis Vosmandros
    Systems Tested  : Windows 11
    PowerShell Ver. : 

.USAGE

#>

# Set execution policy to allow script to run for this session only
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

# Define the registry path, value name, required value, and pass/fail tracker
$regPath   = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"
$valueName = "DisableWebPnPDownload"
$valueData = 1
$allPassed = $true

# Begin remediation
Write-Host "`n=== REMEDIATION ===" -ForegroundColor Yellow

# Create the registry key if it does not exist
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Write the required registry value
New-ItemProperty -Path $regPath -Name $valueName -Value $valueData -PropertyType DWord -Force | Out-Null
Write-Host "[Printers] DisableWebPnPDownload set to $valueData" -ForegroundColor Cyan

# Begin verification
Write-Host "`n=== VERIFICATION ===" -ForegroundColor Yellow

# Read the registry value back and confirm it matches the requirement
$regVal = (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue).$valueName

if ($null -eq $regVal) {
    Write-Host "  [FAIL] DisableWebPnPDownload value not found" -ForegroundColor Red
    $allPassed = $false
} elseif ($regVal -ne $valueData) {
    Write-Host "  [FAIL] DisableWebPnPDownload is $regVal (expected $valueData)" -ForegroundColor Red
    $allPassed = $false
} else {
    Write-Host "  [PASS] DisableWebPnPDownload is $regVal (expected $valueData)" -ForegroundColor Green
}

# Report overall pass or fail status
Write-Host "`n=== SUMMARY ===" -ForegroundColor Yellow

if ($allPassed) {
    Write-Host "  STATUS: PASS - Print driver HTTP download policy meets the requirement." -ForegroundColor Green
    Write-Host "  Run Nessus scan to confirm." -ForegroundColor Green
} else {
    Write-Host "  STATUS: FAIL - Print driver HTTP download policy did not meet the requirement." -ForegroundColor Red
    Write-Host "  Review the details above before rescanning." -ForegroundColor Red
}
if ($null -eq $regVal) { Write-Host " [FAIL] DisableWebPnPDownload value not found" -ForegroundColor Red $allPassed = $false } elseif ($regVal -ne $valueData) { Write-Host " [FAIL] DisableWebPnPDownload is $regVal (expected $valueData)" -ForegroundColor Red $allPassed = $false } else { Write-Host " [PASS] DisableWebPnPDownload is $regVal (expected $valueData)" -ForegroundColor Green }
Write-Host "`n=== SUMMARY ===" -ForegroundColor Yellow
if ($allPassed) { Write-Host " STATUS: PASS - Print driver HTTP download policy meets the requirement." -ForegroundColor Green Write-Host " Run Nessus scan to confirm." -ForegroundColor Green } else { Write-Host " STATUS: FAIL - Print driver HTTP download policy did not meet the requirement." -ForegroundColor Red Write-Host " Review the details above before rescanning." -ForegroundColor Red }
