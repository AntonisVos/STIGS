<#
.SYNOPSIS

# This script remediates STIG WN11-AU-000010 by enabling auditing for
# Credential Validation (Success) using auditpol. It forces Advanced
# Audit Policy to override legacy audit settings and then verifies
# the configuration, outputting a PASS or FAIL result.


.NOTES
    Author          : Antonis Vosmandros
    LinkedIn        : linkedin.com/in/antonisvos
    GitHub          : github.com/antonisvos
    Date Created    : 2026-03-07
    Last Modified   : 2026-03-07
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000010

.TESTED ON
    Date(s) Tested  : 2026-03-07
    Tested By       : Antonis Vosmandros
    Systems Tested  : Windows 11
    PowerShell Ver. : 

.USAGE

#>

 # STIG Remediation Script
# Control: WN11-AU-000010
# Requirement: Audit Credential Validation (Success)

Write-Host "Starting remediation for WN11-AU-000010..."

# Force Advanced Audit Policy to override legacy audit policy
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v SCENoApplyLegacyAuditPolicy /t REG_DWORD /d 1 /f | Out-Null

# Configure the required audit policy
auditpol /set /subcategory:"Credential Validation" /success:enable /failure:disable

# Verify configuration
$audit = auditpol /get /subcategory:"Credential Validation"

if ($audit | Select-String "Success") {
    Write-Host "PASS: Credential Validation auditing is correctly configured."
} else {
    Write-Host "FAIL: Credential Validation auditing is not configured correctly."
}

PASS: Credential Validation auditing is correctly configured.
