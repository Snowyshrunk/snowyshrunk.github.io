# Exchange Online Mailbox Permissions Script Analysis

## Overview
This document analyzes a PowerShell script designed to grant FullAccess and SendAs permissions to users on Exchange Online mailboxes.

**Total Issues Identified: 10** (5 Critical, 3 Medium, 2 Minor)

## Issues Identified

### 🔴 Critical Issues

#### 1. Missing `-Confirm:$false` Parameter
**Location:** `Add-RecipientPermission` command (line 37 in original script)

**Problem:** The command will prompt for interactive confirmation for each SendAs permission, which blocks automation and makes the script unusable in unattended scenarios.

**Impact:** High - Script will hang waiting for user input

**Fix:**
```powershell
# Before (WRONG):
Add-RecipientPermission -Identity $mbx.Mailbox -Trustee $usr.User `
    -AccessRights SendAs -ErrorAction SilentlyContinue

# After (CORRECT):
Add-RecipientPermission -Identity $mbx.Mailbox -Trustee $usr.User `
    -AccessRights SendAs -Confirm:$false -ErrorAction Stop
```

#### 2. Insufficient Error Handling
**Location:** Throughout script

**Problem:** Using `-ErrorAction SilentlyContinue` silences all errors, meaning:
- Failed permission grants go unnoticed
- Invalid mailboxes/users produce no alerts
- No tracking of success/failure rates

**Impact:** High - Silent failures lead to incomplete permission assignments

**Fix:**
```powershell
# Use proper try-catch blocks
try {
    Add-RecipientPermission -Identity $mbx.Mailbox -Trustee $usr.User `
        -AccessRights SendAs -Confirm:$false -ErrorAction Stop
    $successCount++
}
catch {
    Write-Warning "Failed: $_"
    $errorCount++
}
```

#### 3. No Input Validation
**Location:** Lines 3-4

**Problem:** The script doesn't verify:
- CSV files exist before attempting to import
- Required columns (Mailbox, User) are present
- Data is valid (non-empty, correct format)

**Impact:** High - Script crashes with unclear error messages

**Fix:**
```powershell
# Validate file existence
if (-not (Test-Path $mailboxesFile)) {
    Write-Error "Mailboxes CSV file not found: $mailboxesFile"
    exit 1
}

# Validate required columns
if (-not $mailboxes[0].PSObject.Properties.Name -contains "Mailbox") {
    Write-Error "Missing required column 'Mailbox'"
    exit 1
}
```

#### 4. No Connection Error Handling
**Location:** Line 1

**Problem:** If `Connect-ExchangeOnline` fails, the script continues attempting operations that will all fail.

**Impact:** High - Cascading failures with confusing error messages

**Fix:**
```powershell
try {
    Connect-ExchangeOnline -ShowBanner:$false
    Write-Host "Connected successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Failed to connect: $_"
    exit 1
}
```

#### 5. Trustee/User Format Mismatch in Permission Checks
**Location:** Lines 30-31 (SendAs check) and 15-16 (FullAccess check) in original script

**Problem:** Exchange Online returns Trustee/User values in different formats depending on how identities are stored:
- Full UPN: `john@contoso.com`
- Domain\Username: `CONTOSO\john`
- Just username: `john`
- Display name: `John Smith`
- SID format: `S-1-5-21-...`

Using strict equality (`$_.Trustee -eq $usr.User`) causes:
- False negatives: Script thinks permission doesn't exist when it does
- Duplicate attempts: Script tries to add permission that already exists
- Silent failures: Permission grant fails because it already exists

**Impact:** High - SendAs permissions fail to apply because existing permissions aren't detected

**Fix:**
```powershell
# Get all SendAs permissions
$allPermissions = Get-RecipientPermission -Identity $mbx.Mailbox -ErrorAction Stop |
                  Where-Object { $_.AccessRights -contains "SendAs" }

# Filter out system accounts upfront
$allPermissions = $allPermissions | Where-Object { 
    $_.Trustee -ne "NT AUTHORITY\SELF" -and 
    $_.Trustee -notlike "S-1-5-*" 
}

# Extract username from email if present for safer comparison
$userToMatch = if ($usr.User -like "*@*") { $usr.User.Split('@')[0] } else { $usr.User }

# Check multiple format variations with precise matching
$existingSA = $allPermissions | Where-Object { 
    ($_.Trustee -eq $usr.User) -or                              # Exact match
    ($_.Trustee -eq "NT AUTHORITY\$($usr.User)") -or           # NT AUTHORITY\User
    ($_.Trustee -match "\\$([regex]::Escape($usr.User))$") -or # DOMAIN\User (exact end)
    ($_.Trustee -eq $userToMatch)                               # Username only
}

# Also handle case where permission exists but check didn't detect it
if (-not $existingSA) {
    try {
        Add-RecipientPermission -Identity $mbx.Mailbox -Trustee $usr.User `
            -AccessRights SendAs -Confirm:$false -ErrorAction Stop
    }
    catch {
        if ($_.Exception.Message -like "*already has permission*") {
            Write-Host "Permission already exists (not detected in check)"
        }
        else {
            throw
        }
    }
}
```

### 🟡 Medium Issues

#### 6. Inherited Permissions Not Filtered
**Location:** Lines 13-14

**Problem:** The check for existing FullAccess doesn't exclude inherited permissions, potentially causing false positives.

**Impact:** Medium - May skip granting necessary direct permissions

**Fix:**
```powershell
$existingFA = Get-MailboxPermission -Identity $mbx.Mailbox |
    Where-Object { 
        $_.User -eq $usr.User -and 
        $_.AccessRights -contains "FullAccess" -and 
        $_.IsInherited -eq $false 
    }
```

#### 7. Missing Script Requirements
**Location:** Top of script

**Problem:** No `#Requires` statement to ensure ExchangeOnlineManagement module is available.

**Impact:** Medium - Script fails with unclear error if module isn't installed

**Fix:**
```powershell
#Requires -Modules ExchangeOnlineManagement
```

#### 8. No Progress Tracking
**Location:** Throughout script

**Problem:** No summary of:
- How many operations succeeded
- How many were skipped
- How many failed

**Impact:** Medium - Difficult to audit script execution

**Fix:**
```powershell
# Add counters and display summary at end
Write-Host "`n========== SUMMARY =========="
Write-Host "Permissions granted: $successCount"
Write-Host "Permissions skipped: $skipCount"
Write-Host "Errors encountered: $errorCount"
```

### 🟢 Minor Issues

#### 9. Disconnect on Error
**Location:** End of script

**Problem:** If script errors out early, Exchange Online session may remain connected.

**Impact:** Low - Session cleanup issue

**Fix:**
```powershell
# Add try-finally or ensure disconnect in error paths
try {
    # Main script logic
}
finally {
    Disconnect-ExchangeOnline -Confirm:$false
}
```

#### 10. No InheritanceType Specified
**Location:** Line 19

**Problem:** `Add-MailboxPermission` doesn't specify `-InheritanceType`, relying on default behavior.

**Impact:** Low - May not work as expected in all scenarios

**Fix:**
```powershell
Add-MailboxPermission -Identity $mbx.Mailbox -User $usr.User `
    -AccessRights FullAccess -AutoMapping $true `
    -InheritanceType All
```

## Performance Considerations

### Nested Loop Complexity
The script uses nested loops: O(n × m) where n = mailboxes, m = users.

**Example:** 50 mailboxes × 10 users = 500 iterations × 2 operations = 1,000 API calls

This is acceptable for small datasets but consider batching or parallel processing for large operations.

## Security Considerations

1. **Least Privilege:** Ensure the account running the script has only necessary permissions
2. **Audit Logging:** Consider logging all permission changes to a file for compliance
3. **CSV Security:** Validate CSV files aren't tampered with
4. **Credential Storage:** Never hardcode credentials; use Connect-ExchangeOnline with modern auth

## Testing Recommendations

1. Test with a single mailbox and user first
2. Use `-WhatIf` parameter where available (note: not all Exchange cmdlets support it)
3. Test error scenarios:
   - Non-existent mailbox
   - Non-existent user
   - User already has permissions
   - Network disconnection during execution

## Usage

### CSV File Format

**mailboxes.csv:**
```csv
Mailbox
shared1@contoso.com
shared2@contoso.com
```

**users.csv:**
```csv
User
john@contoso.com
jane@contoso.com
```

### Running the Script

```powershell
# Use the corrected version
.\corrected-script.ps1
```

## Files in This Repository

- `original-script.ps1` - The original script with issues
- `corrected-script.ps1` - The corrected version with all fixes applied
- `README.md` - This analysis document

## Key Takeaways

✅ **Always use `-Confirm:$false`** with `Add-RecipientPermission` in automated scripts

✅ **Never use `-ErrorAction SilentlyContinue`** - use proper try-catch instead

✅ **Always validate inputs** before processing

✅ **Use flexible Trustee/User matching** - Exchange returns identities in multiple formats (UPN, DOMAIN\User, username)

✅ **Filter inherited permissions** when checking for existing access

✅ **Track and report** success/failure statistics

✅ **Handle connection failures** gracefully

✅ **Catch "already has permission" errors** as a fallback when detection fails

## Troubleshooting SendAs Permissions

If SendAs permissions aren't being applied, check the following:

### 1. Verify Permission Detection
Run this command manually to see how Exchange stores the Trustee:
```powershell
Get-RecipientPermission -Identity "mailbox@contoso.com" | 
    Where-Object { $_.AccessRights -contains "SendAs" } | 
    Select-Object Identity, Trustee, AccessRights
```

Common Trustee format variations:
- `user@contoso.com` - Full UPN
- `CONTOSO\user` - Domain\Username
- `user` - Username only
- `User Display Name` - Display name

### 2. Check for Existing Permissions
The script may report "already exists" if permissions were granted previously:
```powershell
# Check for specific user
Get-RecipientPermission -Identity "mailbox@contoso.com" -Trustee "user@contoso.com"
```

### 3. Verify User Identity Format in CSV
Ensure your users.csv uses the same format Exchange expects:
```csv
User
john.smith@contoso.com
jane.doe@contoso.com
```

### 4. Check for Permission Propagation Delays
Exchange Online permissions can take 15-60 minutes to propagate. Wait and verify:
```powershell
# Wait 30 minutes, then check again
Get-RecipientPermission -Identity "mailbox@contoso.com" | 
    Where-Object { $_.Trustee -like "*john*" }
```

### 5. Review Error Messages
If you see errors like:
- **"Object not found"** - Mailbox or user doesn't exist or is incorrect format
- **"already has permission"** - Permission exists but wasn't detected by the check
- **"Access denied"** - Your account lacks permissions to grant SendAs rights

### 6. Verify Required Permissions
Your admin account needs:
- Exchange Administrator role OR
- Mailbox Import Export role AND Recipient Permissions role

### 7. Enable Debug Output
Add verbose output to see what's happening:
```powershell
$VerbosePreference = "Continue"
# Run the script
$VerbosePreference = "SilentlyContinue"
```

## Additional Resources

- [Exchange Online PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell)
- [About Try Catch Finally](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally)
- [PowerShell Error Handling Best Practices](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-exceptions)
