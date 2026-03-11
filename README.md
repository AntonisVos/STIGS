# DISA STIG Remediation
## WN11-AU-000050 – Audit Process Creation (Success)
## Control Overview

### STIG ID: WN11-AU-000050
### Category: Audit
### Severity: Medium (CAT II)

### Requirement:

The system must be configured to audit Process Creation events under Detailed Tracking for Success. This ensures successful process executions are logged in the Windows Security Event Log and allows administrators to track executed processes for security monitoring and forensic analysis.


### Step 1: Baseline Scan of VM

Windows 11 VM was provisioned in Azure for testing and remediation validation.
Windows Defender Firewall was temporarily disabled to ensure internal vulnerability scanner could connect without network filtering issues.

A compliance scan was performed using Tenable Nessus with the following configuration:

**Scan Configuration** 

**Target:**           	Windows VM Private IP
**Authentication:**   	Windows credentialed scan
**Compliance Policy:**	DISA Microsoft Windows 11 STIG v2r6
**Enabled Checks:**   	Windows Compliance Checks

The initial scan identified a failed compliance check for WN11-AU-000050.


<img width="1509" height="824" alt="Screenshot 2026-03-09 at 8 17 04 PM" src="https://github.com/user-attachments/assets/04a11b9f-1746-41e7-880f-e533d39f5cc2" />


### Step 2: Manual Remediation


The Tenable compliance report provided the following remediation guidance:

Computer Configuration
 → Windows Settings
 → Security Settings
 → Advanced Audit Policy Configuration
 → System Audit Policies
 → Detailed Tracking
 → Audit Process Creation

The policy must be configured with:

Audit Process Creation: Success


<img width="784" height="585" alt="Manual Remediation in Windows" src="https://github.com/user-attachments/assets/3fbc5681-8815-41ee-8f37-470c499077ba" />


### Step 3: Remediation Verification via Rescan


After applying the policy configuration, the VM was restarted to ensure the change took effect.

A new compliance scan was then executed using Tenable Nessus.

The rescan results confirmed that WN11-AU-000050 had changed to a PASS, indicating the required audit policy was successfully applied.


<img width="1090" height="391" alt="Scan after manual remediation - passed" src="https://github.com/user-attachments/assets/528eaed2-f92e-410f-acc5-62552933f074" />


### Step 4: Undoing the Remediation


To validate the control, the remediation was intentionally reversed.

The Audit Process Creation setting was disabled, the VM was restarted, and another compliance scan was executed.

The scan results showed that WN11-AU-000050 returned to a FAILED state. This confirms that the compliance check correctly detects the configuration change.


<img width="1509" height="824" alt="Screenshot 2026-03-09 at 8 17 04 PM" src="https://github.com/user-attachments/assets/8d69b1b7-7062-4abe-a395-1f765796f17c" />


### Step 5: PowerShell Automation


During automation testing, the configuration appeared successful when applied via PowerShell. However, the GUI policy tools still showed:

No auditing in PowerShell output

Not configured in gpedit.msc

Not configured in secpol.msc

This behavior occurs because Windows maintains two audit policy frameworks.

Legacy Audit Policy

Configured under:

Security Settings
 → Local Policies
 → Audit Policy

This framework uses broad categories such as:

Audit Process Tracking
Advanced Audit Policy

Modern security standards, including DISA STIGs, rely on Advanced Audit Policy, which provides granular subcategory auditing.

Configured under:

Advanced Audit Policy Configuration
 → System Audit Policies
 → Detailed Tracking

This includes specific subcategories such as:

Process Creation

If the system is not explicitly configured to prioritize Advanced Audit Policy, legacy audit policies can override advanced settings.

Script Function

The PowerShell remediation script performs the following actions:

Forces Advanced Audit Policy to override legacy audit settings.

Executes an immediate Group Policy update.

Enables Process Creation auditing (Success).

Verifies the configuration using auditpol.

Outputs a PASS/FAIL validation result.

Example verification command:

auditpol /get /subcategory:"Process Creation"

Expected output:

Process Creation    Success


<img width="804" height="878" alt="Powershell Remediation" src="https://github.com/user-attachments/assets/de7decf4-af30-4cf5-93f7-af3fa85e3b82" />


### Step 6: Validation with Rescan


<img width="1509" height="823" alt="Screenshot 2026-03-09 at 11 51 08 AM" src="https://github.com/user-attachments/assets/65a9bbdc-1b81-4b50-99e0-f430669264f4" />


After executing the PowerShell remediation script, the VM was rescanned using Tenable Nessus.

The scan results showed that STIG ID WN11-AU-000050 returned a PASS status.

This confirms the automated remediation successfully enforced the required audit configuration and was detected by the compliance scanner.

Result

The system is now compliant with WN11-AU-000050, and the remediation has been validated through:

Baseline vulnerability scanning

Manual remediation

Compliance verification scans

PowerShell-based automated enforcement

✅ Compliance Status: PASS


