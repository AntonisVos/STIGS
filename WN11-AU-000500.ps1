<#
.SYNOPSIS

<#
This script remediates STIG ID WN11-AU-000500 by configuring the Application, 
System, and Security event logs to meet the DISA requirement of 32768 KB (32 MB) or greater.

It writes the required MaxSize registry values under HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog 
for each log and updates the live log sizes via WMI to ensure the active configuration matches the 
policy requirement.

The script includes a built-in verification block that confirms each log passes before exiting, and 
intentionally omits gpupdate /force to prevent a conflicting Group Policy Object from overwriting 
the Application log registry key during a Group Policy refresh.
#>
#>


.NOTES
    Author          : Antonis Vosmandros
    LinkedIn        : linkedin.com/in/antonisvos
    GitHub          : github.com/antonisvos
    Date Created    : 2026-03-15
    Last Modified   : 2026-03-15
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000500

.TESTED ON
    Date(s) Tested  : 2026-03-15
    Tested By       : Antonis Vosmandros
    Systems Tested  : Windows 11
    PowerShell Ver. : 

.USAGE

#>

Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$logNames  = @("Application", "System", "Security")
$regBase   = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog"
$sizeKB    = 32768
$sizeBytes = 33554432
$allPassed = $true

Write-Host "`n=== REMEDIATION ===" -ForegroundColor Yellow

foreach ($log in $logNames) {
    $regPath = "$regBase\$log"

    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    New-ItemProperty -Path $regPath -Name "MaxSize" -Value $sizeKB -PropertyType DWord -Force | Out-Null
    Write-Host "[$log] Registry policy set to $sizeKB KB" -ForegroundColor Cyan

    $wmiLog = Get-WmiObject -Class Win32_NTEventlogFile | Where-Object { $_.LogfileName -eq $log }
    if ($wmiLog) {
        $wmiLog.MaxFileSize = $sizeBytes
        $wmiLog.Put() | Out-Null
        Write-Host "[$log] Live log size set to $sizeBytes bytes" -ForegroundColor Cyan
    }
}

Write-Host "`n=== VERIFICATION ===" -ForegroundColor Yellow

foreach ($log in $logNames) {
    $regPath = "$regBase\$log"
    $pass    = $true
    $notes   = @()

    if (-not (Test-Path $regPath)) {
        $pass  = $false
        $notes += "Registry key missing"
    } else {
        $regVal = (Get-ItemProperty -Path $regPath -Name "MaxSize" -ErrorAction SilentlyContinue).MaxSize
        if ($null -eq $regVal) {
            $pass  = $false
            $notes += "MaxSize value not found"
        } elseif ($regVal -lt $sizeKB) {
            $pass  = $false
            $notes += "MaxSize is $regVal KB (expected >= $sizeKB KB)"
        } else {
            $notes += "Registry OK ($regVal KB)"
        }

        $wmiLog = Get-WmiObject -Class Win32_NTEventlogFile | Where-Object { $_.LogfileName -eq $log }
        if ($wmiLog) {
            $liveMB = [math]::Round($wmiLog.MaxFileSize / 1MB, 1)
            if ($wmiLog.MaxFileSize -lt $sizeBytes) {
                $pass  = $false
                $notes += "Live log size is $liveMB MB (expected >= 32 MB)"
            } else {
                $notes += "Live log OK ($liveMB MB)"
            }
        } else {
            $notes += "Could not read live log size"
        }
    }

    if ($pass) {
        Write-Host "  [PASS] $log - $($notes -join ' | ')" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $log - $($notes -join ' | ')" -ForegroundColor Red
        $allPassed = $false
    }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Yellow

if ($allPassed) {
    Write-Host "  STATUS: PASS - All logs meet the 32 MB requirement." -ForegroundColor Green
    Write-Host "  Restart the VM, then rescan with Nessus to confirm." -ForegroundColor Green
} else {
    Write-Host "  STATUS: FAIL - One or more logs did not meet the requirement." -ForegroundColor Red
    Write-Host "  Review the details above before rescanning." -ForegroundColor Red
}
