<#
.SYNOPSIS
Remediates STIG control WN11-AU-000050 by enabling auditing for Process Creation (Success) on Windows 11. 
It first enforces advanced audit policies to override legacy audit settings, then configures the system 
to log successful process creation events. The script forces a Group Policy update to apply the changes 
immediately and verifies the setting using auditpol.exe.

.NOTES
    Author          : Antonis Vosmandros
    LinkedIn        : linkedin.com/in/antonisvos
    GitHub          : github.com/antonisvos
    Date Created    : 2026-03-07
    Last Modified   : 2026-03-07
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000050

.TESTED ON
    Date(s) Tested  : 2026-03-07
    Tested By       : Antonis Vosmandros
    Systems Tested  : Windows 11
    PowerShell Ver. : 

.USAGE

#>

# STIG Remediation Script
# Control: WN11-AU-000050
# Requirement: Audit Process Creation (Success)

Write-Host "Starting remediation for WN11-AU-000050..."

# Ensure advanced audit policy overrides legacy audit policy
Write-Host "Enforcing Advanced Audit Policy override..."
Set-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "SCENoApplyLegacyAuditPolicy" `
    -Value 1 `
    -Type DWord

# Force Group Policy update to apply the override
Write-Host "Applying Group Policy..."
gpupdate /force | Out-Null

# Enable auditing for Process Creation (Success)
Write-Host "Configuring Process Creation auditing..."
auditpol /set /subcategory:"Process Creation" /success:enable /failure:disable

# Verify configuration
Write-Host "Verifying configuration..."
$result = auditpol /get /subcategory:"Process Creation"

Write-Host $result

if ($result -match "Success") {
    Write-Host "PASS: Process Creation auditing is enabled."
}
else {
    Write-Host "FAIL: Process Creation auditing is not configured correctly."
}

Write-Host "Remediation complete."
Category/Subcategory                      Setting
Detailed Tracking
  Process Creation          
