<#
.SYNOPSIS

The script begins by setting the PowerShell execution policy to RemoteSigned for the current session 
and defining the target registry path, value name, and required value. It then creates the registry 
key if it does not exist and writes AlwaysInstallElevated as a DWORD value of 0 using New-ItemProperty 
with the -Force flag to ensure it is written correctly. The verification block reads the value back and 
confirms it matches the requirement, outputting a PASS or FAIL with a reason. Finally, the summary block 
reports the overall STATUS and advises whether it is safe to proceed with the Nessus scan.


.NOTES
    Author          : Antonis Vosmandros
    LinkedIn        : linkedin.com/in/antonisvos
    GitHub          : github.com/antonisvos
    Date Created    : 2026-03-18
    Last Modified   : 2026-03-18
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000315

.TESTED ON
    Date(s) Tested  : 2026-03-18
    Tested By       : Antonis Vosmandros
    Systems Tested  : Windows 11
    PowerShell Ver. : 

.USAGE

#>

Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$regPath   = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"
$valueName = "AlwaysInstallElevated"
$valueData = 0
$allPassed = $true

Write-Host "`n=== REMEDIATION ===" -ForegroundColor Yellow

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

New-ItemProperty -Path $regPath -Name $valueName -Value $valueData -PropertyType DWord -Force | Out-Null
Write-Host "[Windows Installer] AlwaysInstallElevated set to $valueData" -ForegroundColor Cyan

Write-Host "`n=== VERIFICATION ===" -ForegroundColor Yellow

$regVal = (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue).$valueName

if ($null -eq $regVal) {
    Write-Host "  [FAIL] AlwaysInstallElevated value not found" -ForegroundColor Red
    $allPassed = $false
} elseif ($regVal -ne $valueData) {
    Write-Host "  [FAIL] AlwaysInstallElevated is $regVal (expected $valueData)" -ForegroundColor Red
    $allPassed = $false
} else {
    Write-Host "  [PASS] AlwaysInstallElevated is $regVal (expected $valueData)" -ForegroundColor Green
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Yellow

if ($allPassed) {
    Write-Host "  STATUS: PASS - Windows Installer elevated privileges policy meets the requirement." -ForegroundColor Green
    Write-Host "  Run Nessus scan to confirm." -ForegroundColor Green
} else {
    Write-Host "  STATUS: FAIL - Windows Installer elevated privileges policy did not meet the requirement." -ForegroundColor Red
    Write-Host "  Review the details above before rescanning." -ForegroundColor Red
}
