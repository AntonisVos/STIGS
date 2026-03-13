<#
.SYNOPSIS
This script enforces the required Group Policy configuration by creating the
necessary registry policy path and setting the DisableHTTPPrinting value to 1.
This disables HTTP-based printing on the system.

The script then triggers a Group Policy update to immediately apply the
configuration and ensure the system complies with the STIG requirement.
#>




.NOTES
    Author          : Antonis Vosmandros
    LinkedIn        : linkedin.com/in/antonisvos
    GitHub          : github.com/antonisvos
    Date Created    : 2026-03-07
    Last Modified   : 2026-03-07
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000110

.TESTED ON
    Date(s) Tested  : 2026-03-13
    Tested By       : Antonis Vosmandros
    Systems Tested  : Windows 11
    PowerShell Ver. : 

.USAGE

#>

Write-Host "Starting remediation for WN11-CC-000110..."

$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"
$ValueName = "DisableHTTPPrinting"

# Create registry path if it does not exist
if (!(Test-Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}

# Set the STIG-required value
Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value 1 -Type DWord

# Refresh Group Policy
gpupdate /force

Write-Host "Remediation complete. HTTP printing has been disabled."
