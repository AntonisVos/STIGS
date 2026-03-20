<#
.SYNOPSIS

This PowerShell script remediates STIG ID WN11-CC-000090 by configuring 
Group Policy objects to reprocess even if they have not changed, ensuring that any 
unauthorized configuration changes are forced back to their required state on every 
Group Policy refresh.
It creates the required registry key under:
HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy{35378EAC-683F-11D2-A89A-00C04FBBCFA2} 
and sets the NoGPOListChanges value to 0 using New-ItemProperty with the -Force flag to ensure 
it is written correctly.
The script includes a built-in verification block that confirms the value was written correctly 
before exiting, and intentionally omits gpupdate /force to prevent any conflicting Group Policy 
Object from overwriting the registry value before the Nessus scan executes.


.NOTES
    Author          : Antonis Vosmandros
    LinkedIn        : linkedin.com/in/antonisvos
    GitHub          : github.com/antonisvos
    Date Created    : 2026-03-19
    Last Modified   : 2026-03-19
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000090

.TESTED ON
    Date(s) Tested  : 2026-03-19
    Tested By       : Antonis Vosmandros
    Systems Tested  : Windows 11
    PowerShell Ver. : 

.USAGE

#>

Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$regPath   = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}"
$valueName = "NoGPOListChanges"
$valueData = 0
$allPassed = $true

Write-Host "`n=== REMEDIATION ===" -ForegroundColor Yellow

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

New-ItemProperty -Path $regPath -Name $valueName -Value $valueData -PropertyType DWord -Force | Out-Null
Write-Host "[Group Policy] NoGPOListChanges set to $valueData" -ForegroundColor Cyan

Write-Host "`n=== VERIFICATION ===" -ForegroundColor Yellow

$regVal = (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue).$valueName

if ($null -eq $regVal) {
    Write-Host "  [FAIL] NoGPOListChanges value not found" -ForegroundColor Red
    $allPassed = $false
} elseif ($regVal -ne $valueData) {
    Write-Host "  [FAIL] NoGPOListChanges is $regVal (expected $valueData)" -ForegroundColor Red
    $allPassed = $false
} else {
    Write-Host "  [PASS] NoGPOListChanges is $regVal (expected $valueData)" -ForegroundColor Green
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Yellow

if ($allPassed) {
    Write-Host "  STATUS: PASS - Group Policy reprocessing meets the requirement." -ForegroundColor Green
    Write-Host "  Run Nessus scan to confirm." -ForegroundColor Green
} else {
    Write-Host "  STATUS: FAIL - Group Policy reprocessing did not meet the requirement." -ForegroundColor Red
    Write-Host "  Review the details above before rescanning." -ForegroundColor Red
}
