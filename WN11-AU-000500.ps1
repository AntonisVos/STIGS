<#
.SYNOPSIS
    This PowerShell script configures the system to comply with STIG control WN11-AU-000050 for Windows 11. 
    The script uses the built-in auditpol utility to enable Success auditing for the Process Creation 
    subcategory within Advanced Audit Policy (Detailed Tracking).

.NOTES
    Author          : Antonis Vosmandros
    LinkedIn        : linkedin.com/in/antonisvos
    GitHub          : github.com/antonisvos
    Date Created    : 2026-03-05
    Last Modified   : 2026-03-05
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000050

.TESTED ON
    Date(s) Tested  : 2026-03-05
    Tested By       : Antonis Vosmandros
    Systems Tested  : Windows 11
    PowerShell Ver. : 

.USAGE

#>

# Enable auditing for Process Creation success events

Write-Host "Configuring Audit Policy for Process Creation..."

auditpol /set /subcategory:"Process Creation" /success:enable

Write-Host "Audit policy configured."

# Verify configuration
Write-Host "Verifying configuration..."
auditpol /get /subcategory:"Process Creation"
