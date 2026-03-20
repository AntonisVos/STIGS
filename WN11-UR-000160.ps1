<#
.SYNOPSIS

This  script remediates STIG ID WN11-UR-000160 by restricting the Restore files and directories 
user right to the Administrators group only, preventing unauthorized accounts from circumventing 
file and directory permissions or accessing sensitive data.

Unlike registry-based STIGs, this control is managed through Local Security Policy. The script uses secedit 
to export the current security policy, updates the SeRestorePrivilege assignment, and reimports the updated policy. 
Rather than referencing the Administrators group by name, the script uses the well-known Security Identifier (SID) S-1-5-32-544. 
SIDs are assigned to security principals in Windows and do not change regardless of system language, regional settings, 
or group renaming. Using the SID instead of the group name ensures the assignment is applied correctly and 
consistently across any Windows 11 system. 

The script then re-exports the policy to verify the change was applied correctly before 
reporting a PASS or FAIL.

.NOTES
    Author          : Antonis Vosmandros
    LinkedIn        : linkedin.com/in/antonisvos
    GitHub          : github.com/antonisvos
    Date Created    : 2026-03-20
    Last Modified   : 2026-03-20
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-UR-000160

.TESTED ON
    Date(s) Tested  : 2026-03-20
    Tested By       : Antonis Vosmandros
    Systems Tested  : Windows 11
    PowerShell Ver. : 

.USAGE

#>

# Set execution policy to allow script to run for this session only
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

# Define the temporary file paths for secedit export and import
$tempCfg    = "$env:TEMP\secedit_export.cfg"
$tempDb     = "$env:TEMP\secedit.sdb"
$allPassed  = $true

Write-Host "`n=== REMEDIATION ===" -ForegroundColor Yellow

# Export the current local security policy to a temporary file
secedit /export /cfg $tempCfg /quiet

# Read the exported policy file
$policy = Get-Content $tempCfg

# Update SeRestorePrivilege to restrict it to Administrators only
$policy = $policy -replace "SeRestorePrivilege\s*=.*", "SeRestorePrivilege = *S-1-5-32-544"

# If SeRestorePrivilege does not exist in the file, add it
if ($policy -notmatch "SeRestorePrivilege") {
    $policy += "`nSeRestorePrivilege = *S-1-5-32-544"
}

# Write the updated policy back to the temporary file
$policy | Set-Content $tempCfg

# Apply the updated security policy using secedit
secedit /configure /db $tempDb /cfg $tempCfg /quiet
Write-Host "[User Rights] SeRestorePrivilege restricted to Administrators only" -ForegroundColor Cyan

# Clean up temporary files
Remove-Item $tempCfg -ErrorAction SilentlyContinue
Remove-Item $tempDb -ErrorAction SilentlyContinue

Write-Host "`n=== VERIFICATION ===" -ForegroundColor Yellow

# Export the policy again to verify the change was applied
$verifyPath = "$env:TEMP\secedit_verify.cfg"
secedit /export /cfg $verifyPath /quiet
$verifyPolicy = Get-Content $verifyPath

# Check that SeRestorePrivilege is set to Administrators only
$line = $verifyPolicy | Where-Object { $_ -match "SeRestorePrivilege" }

if ($null -eq $line) {
    Write-Host "  [FAIL] SeRestorePrivilege entry not found in policy" -ForegroundColor Red
    $allPassed = $false
} elseif ($line -match "SeRestorePrivilege\s*=\s*\*S-1-5-32-544$") {
    Write-Host "  [PASS] SeRestorePrivilege is restricted to Administrators only" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] SeRestorePrivilege is set to: $line" -ForegroundColor Red
    $allPassed = $false
}

# Clean up verification file
Remove-Item $verifyPath -ErrorAction SilentlyContinue

# Report overall pass or fail status
Write-Host "`n=== SUMMARY ===" -ForegroundColor Yellow

if ($allPassed) {
    Write-Host "  STATUS: PASS - Restore files and directories user right meets the requirement." -ForegroundColor Green
    Write-Host "  Run Nessus scan to confirm." -ForegroundColor Green
} else {
    Write-Host "  STATUS: FAIL - Restore files and directories user right did not meet the requirement." -ForegroundColor Red
    Write-Host "  Review the details above before rescanning." -ForegroundColor Red
}
