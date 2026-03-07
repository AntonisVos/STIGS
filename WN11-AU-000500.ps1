<#
.SYNOPSIS
    This PowerShell script configures the system to comply with STIG control WN11-AU-000050 for Windows 11. 
    It enables Advanced Audit Policy to audit successful process creation events.
    It overrides legacy audit settings to ensure the new policy is enforced.
    Finally, it verifies that Process Creation auditing is active and reports pass or fail.

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
Write-Host "Enforcing Advanced Audit Policy..."
Set-ItemProperty `
 -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
 -Name "SCENoApplyLegacyAuditPolicy" `
 -Value 1 `
 -Type DWord

# Enable auditing for Process Creation (Success)
Write-Host "Configuring Process Creation auditing..."
auditpol /set /subcategory:"Process Creation" /success:enable

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
Starting remediation for WN11-AU-000050...
Enforcing Advanced Audit Policy...
Configuring Process Creation auditing...
The command was successfully executed.

Verifying configuration...
System audit policy  Category/Subcategory                      Setting Detailed Tracking
   Process Creation                        Success 
PASS: Process Creation auditing is enabled.
Remediation complete.

PS C:\Users\antonislab> auditpol /get /subcategory:"Process Creation"
System audit policy

Category/Subcategory                      Setting
Detailed Tracking
  Process Creation          
