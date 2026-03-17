<#
.SYNOPSIS

This PowerShell script remediates STIG ID WN11-EP-000310 by configuring 
the Kernel DMA Protection enumeration policy to block all external devices 
incompatible with Kernel DMA Protection.

It creates the required registry key under: HKLM:\Software\Policies\Microsoft\Windows\Kernel DMA Protection 
and sets the DeviceEnumerationPolicy value to 0, which corresponds to the Block All setting required by DISA.

The script includes a built-in verification block that confirms the value was written correctly before exiting, 
and intentionally omits gpupdate /force to prevent any conflicting Group Policy Object from overwriting the 
registry value before the Nessus scan executes.

#>



.NOTES
    Author          : Antonis Vosmandros
    LinkedIn        : linkedin.com/in/antonisvos
    GitHub          : github.com/antonisvos
    Date Created    : 2026-03-17
    Last Modified   : 2026-03-17
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-EP-000310

.TESTED ON
    Date(s) Tested  : 2026-03-17
    Tested By       : Antonis Vosmandros
    Systems Tested  : Windows 11
    PowerShell Ver. : 

.USAGE

#>

 Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$regPath   = "HKLM:\Software\Policies\Microsoft\Windows\Kernel DMA Protection"
$valueName = "DeviceEnumerationPolicy"
$valueData = 0
$allPassed = $true

Write-Host "`n=== REMEDIATION ===" -ForegroundColor Yellow

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

New-ItemProperty -Path $regPath -Name $valueName -Value $valueData -PropertyType DWord -Force | Out-Null
Write-Host "[Kernel DMA Protection] DeviceEnumerationPolicy set to $valueData" -ForegroundColor Cyan

Write-Host "`n=== VERIFICATION ===" -ForegroundColor Yellow

$regVal = (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue).$valueName

if ($null -eq $regVal) {
    Write-Host "  [FAIL] DeviceEnumerationPolicy value not found" -ForegroundColor Red
    $allPassed = $false
} elseif ($regVal -ne $valueData) {
    Write-Host "  [FAIL] DeviceEnumerationPolicy is $regVal (expected $valueData)" -ForegroundColor Red
    $allPassed = $false
} else {
    Write-Host "  [PASS] DeviceEnumerationPolicy is $regVal (expected $valueData)" -ForegroundColor Green
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Yellow

if ($allPassed) {
    Write-Host "  STATUS: PASS - Kernel DMA Protection policy meets the requirement." -ForegroundColor Green
    Write-Host "  Run Nessus scan to confirm." -ForegroundColor Green
} else {
    Write-Host "  STATUS: FAIL - Kernel DMA Protection policy did not meet the requirement." -ForegroundColor Red
    Write-Host "  Review the details above before rescanning." -ForegroundColor Red
} 
