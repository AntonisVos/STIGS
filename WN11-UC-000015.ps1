<#
.SYNOPSIS

This PowerShell script remediates STIG ID WN11-UC-000015  by disabling toast notifications on the lock screen, 
preventing sensitive information from being displayed to unauthorized personnel before a user logs in.
This is a User Configuration policy that writes to HKEY_CURRENT_USER, meaning it applies to the currently logged in 
user account rather than system-wide. The script creates the required registry key under 
HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications and sets the 
NoToastApplicationNotificationOnLockScreen value to 1.

The script includes a built-in verification block that confirms the value was written correctly before exiting, 
and intentionally omits gpupdate /force to prevent any conflicting Group Policy Object from overwriting the 
registry value before the Nessus scan executes.

.NOTES
    Author          : Antonis Vosmandros
    LinkedIn        : linkedin.com/in/antonisvos
    GitHub          : github.com/antonisvos
    Date Created    : 2026-03-21
    Last Modified   : 2026-03-21
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-UC-000015

.TESTED ON
    Date(s) Tested  : 2026-03-21
    Tested By       : Antonis Vosmandros
    Systems Tested  : Windows 11
    PowerShell Ver. : 

.USAGE

#> 

# Set execution policy to allow script to run for this session only
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

# Define the registry path, value name, required value, and pass/fail tracker
# Note: This policy targets HKEY_CURRENT_USER, not HKEY_LOCAL_MACHINE
$regPath   = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
$valueName = "NoToastApplicationNotificationOnLockScreen"
$valueData = 1
$allPassed = $true

Write-Host "`n=== REMEDIATION ===" -ForegroundColor Yellow

# Create the registry key if it does not exist
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Write the required registry value
New-ItemProperty -Path $regPath -Name $valueName -Value $valueData -PropertyType DWord -Force | Out-Null
Write-Host "[PushNotifications] NoToastApplicationNotificationOnLockScreen set to $valueData" -ForegroundColor Cyan

Write-Host "`n=== VERIFICATION ===" -ForegroundColor Yellow

# Read the registry value back and confirm it matches the requirement
$regVal = (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue).$valueName

if ($null -eq $regVal) {
    Write-Host "  [FAIL] NoToastApplicationNotificationOnLockScreen value not found" -ForegroundColor Red
    $allPassed = $false
} elseif ($regVal -ne $valueData) {
    Write-Host "  [FAIL] NoToastApplicationNotificationOnLockScreen is $regVal (expected $valueData)" -ForegroundColor Red
    $allPassed = $false
} else {
    Write-Host "  [PASS] NoToastApplicationNotificationOnLockScreen is $regVal (expected $valueData)" -ForegroundColor Green
}

# Report overall pass or fail status
Write-Host "`n=== SUMMARY ===" -ForegroundColor Yellow

if ($allPassed) {
    Write-Host "  STATUS: PASS - Toast notification lock screen policy meets the requirement." -ForegroundColor Green
    Write-Host "  Run Nessus scan to confirm." -ForegroundColor Green
} else {
    Write-Host "  STATUS: FAIL - Toast notification lock screen policy did not meet the requirement." -ForegroundColor Red
    Write-Host "  Review the details above before rescanning." -ForegroundColor Red
}
