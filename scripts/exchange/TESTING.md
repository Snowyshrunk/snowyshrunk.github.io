# Testing the SendAs Permission Fix

## Test Scenario: Verify SendAs Permissions Are Applied

This document provides test scenarios to verify that the SendAs permission fix resolves the issue where permissions weren't being applied.

## Prerequisites

1. Exchange Online admin account with permissions to:
   - Grant SendAs permissions
   - Query mailbox permissions
2. Test mailbox (e.g., `testmailbox@contoso.com`)
3. Test user account (e.g., `testuser@contoso.com`)
4. ExchangeOnlineManagement PowerShell module installed

## Test Case 1: Fresh Permission Grant

**Objective:** Verify script correctly grants SendAs permission when none exists

**Steps:**
1. Connect to Exchange Online:
   ```powershell
   Connect-ExchangeOnline
   ```

2. Verify test user has NO SendAs permission:
   ```powershell
   Get-RecipientPermission -Identity testmailbox@contoso.com | 
       Where-Object { $_.Trustee -like "*testuser*" -and $_.AccessRights -contains "SendAs" }
   ```
   **Expected:** No results

3. Run the corrected script with appropriate CSV files

4. Verify permission was granted:
   ```powershell
   Get-RecipientPermission -Identity testmailbox@contoso.com | 
       Where-Object { $_.Trustee -like "*testuser*" -and $_.AccessRights -contains "SendAs" }
   ```
   **Expected:** One result showing SendAs permission

## Test Case 2: Permission Already Exists (Different Format)

**Objective:** Verify script detects existing permissions regardless of Trustee format

**Steps:**
1. Manually grant SendAs permission using full UPN:
   ```powershell
   Add-RecipientPermission -Identity testmailbox@contoso.com `
       -Trustee testuser@contoso.com -AccessRights SendAs -Confirm:$false
   ```

2. Check how Exchange stored the Trustee:
   ```powershell
   $perm = Get-RecipientPermission -Identity testmailbox@contoso.com | 
       Where-Object { $_.AccessRights -contains "SendAs" -and $_.Trustee -like "*testuser*" }
   $perm.Trustee
   ```
   **Note the format:** Could be `testuser@contoso.com`, `CONTOSO\testuser`, or just `testuser`

3. Create CSV with different format than what Exchange returned:
   - If Exchange shows `CONTOSO\testuser`, use `testuser@contoso.com` in CSV
   - If Exchange shows `testuser@contoso.com`, use just `testuser` in CSV

4. Run the corrected script

5. Verify script SKIPS the permission (doesn't try to add duplicate):
   **Expected output:** "SendAs already exists (Trustee: [format]) — skipping."

## Test Case 3: Original Script vs Corrected Script

**Objective:** Compare behavior between original and corrected scripts

**Setup:**
1. Remove any existing SendAs permissions for test user:
   ```powershell
   Remove-RecipientPermission -Identity testmailbox@contoso.com `
       -Trustee testuser@contoso.com -AccessRights SendAs -Confirm:$false
   ```

2. Manually grant permission in a specific format:
   ```powershell
   Add-RecipientPermission -Identity testmailbox@contoso.com `
       -Trustee "CONTOSO\testuser" -AccessRights SendAs -Confirm:$false
   ```

**Test Original Script:**
1. CSV contains: `testuser@contoso.com`
2. Run original-script.ps1
3. **Expected:** Script says "Adding SendAs..." but fails silently (permission already exists)
4. **Result:** SendAs permission NOT applied (false negative)

**Test Corrected Script:**
1. Same CSV: `testuser@contoso.com`
2. Run corrected-script.ps1
3. **Expected:** Script detects existing permission and says "SendAs already exists (Trustee: CONTOSO\testuser) — skipping."
4. **Result:** Correctly identifies existing permission

## Test Case 4: Error Handling

**Objective:** Verify proper error handling when permission exists but isn't detected

**Steps:**
1. Create a scenario where detection might fail (edge case formats)
2. Run the corrected script
3. If detection fails, script should:
   - Try to add permission
   - Catch "already has permission" error
   - Display: "SendAs permission already exists (not detected in check) — skipping."
   - Count it as skipped, not error

## Validation Commands

### Check Current Permissions
```powershell
# List all SendAs permissions on a mailbox
Get-RecipientPermission -Identity mailbox@contoso.com | 
    Where-Object { $_.AccessRights -contains "SendAs" } | 
    Select-Object Identity, Trustee, AccessRights | 
    Format-Table -AutoSize
```

### Check Trustee Format Variations
```powershell
# See exactly how Exchange stores the Trustee
Get-RecipientPermission -Identity mailbox@contoso.com | 
    Where-Object { $_.AccessRights -contains "SendAs" } | 
    ForEach-Object { 
        [PSCustomObject]@{
            Trustee = $_.Trustee
            TrusteeType = $_.Trustee.GetType().Name
            Length = $_.Trustee.Length
            Contains_Backslash = $_.Trustee -like "*\*"
            Contains_At = $_.Trustee -like "*@*"
        }
    }
```

### Remove Test Permissions
```powershell
# Clean up after testing
Remove-RecipientPermission -Identity testmailbox@contoso.com `
    -Trustee testuser@contoso.com -AccessRights SendAs -Confirm:$false
```

## Expected Results Summary

| Scenario | Original Script | Corrected Script |
|----------|----------------|------------------|
| No existing permission | ❌ Hangs for confirmation OR silent failure | ✅ Successfully grants |
| Permission exists (exact match) | ✅ Detects and skips | ✅ Detects and skips |
| Permission exists (format mismatch) | ❌ False negative, tries to add duplicate | ✅ Detects and skips |
| Detection edge case | ❌ Error or silent failure | ✅ Catches error, logs skip |

## Common Trustee Formats in Exchange Online

Based on testing, Exchange Online may return Trustee in these formats:

1. **Full UPN**: `john.smith@contoso.com`
2. **Domain\Username**: `CONTOSO\john.smith`
3. **Username only**: `john.smith`
4. **Display Name**: `John Smith`
5. **SID format**: `S-1-5-21-...` (for certain system accounts)

The corrected script handles all these formats with flexible matching logic.

## Notes

- Permissions can take 15-60 minutes to propagate in Exchange Online
- Always test in a non-production environment first
- Keep track of script output for troubleshooting
- Use `-Verbose` flag to see detailed Exchange cmdlet output
