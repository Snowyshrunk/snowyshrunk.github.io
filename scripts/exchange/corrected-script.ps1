# Exchange Online Mailbox Permissions Script - Corrected Version
# This script grants FullAccess and SendAs permissions to users on mailboxes

# Requires the ExchangeOnlineManagement module
#Requires -Modules ExchangeOnlineManagement

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

try {
    # Connect to Exchange Online
    Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
    Connect-ExchangeOnline -ShowBanner:$false
    Write-Host "Connected successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Failed to connect to Exchange Online: $_"
    exit 1
}

# Validate CSV files exist
$mailboxesFile = ".\mailboxes.csv"
$usersFile = ".\users.csv"

if (-not (Test-Path $mailboxesFile)) {
    Write-Error "Mailboxes CSV file not found: $mailboxesFile"
    Disconnect-ExchangeOnline -Confirm:$false
    exit 1
}

if (-not (Test-Path $usersFile)) {
    Write-Error "Users CSV file not found: $usersFile"
    Disconnect-ExchangeOnline -Confirm:$false
    exit 1
}

# Import CSV files
try {
    $mailboxes = Import-Csv $mailboxesFile
    $users = Import-Csv $usersFile
}
catch {
    Write-Error "Failed to import CSV files: $_"
    Disconnect-ExchangeOnline -Confirm:$false
    exit 1
}

# Validate required columns exist
if (-not $mailboxes[0].PSObject.Properties.Name -contains "Mailbox") {
    Write-Error "CSV file $mailboxesFile is missing required column 'Mailbox'"
    Disconnect-ExchangeOnline -Confirm:$false
    exit 1
}

if (-not $users[0].PSObject.Properties.Name -contains "User") {
    Write-Error "CSV file $usersFile is missing required column 'User'"
    Disconnect-ExchangeOnline -Confirm:$false
    exit 1
}

Write-Host "`nProcessing $($mailboxes.Count) mailboxes and $($users.Count) users..." -ForegroundColor Cyan
Write-Host "Total operations: $($mailboxes.Count * $users.Count * 2)`n" -ForegroundColor Yellow

$successCount = 0
$skipCount = 0
$errorCount = 0

foreach ($mbx in $mailboxes) {

    foreach ($usr in $users) {

        Write-Host "Processing $($usr.User) on $($mbx.Mailbox)..." -ForegroundColor Cyan

        # --------------------------
        # 1. FULL ACCESS PERMISSION
        # --------------------------
        try {
            $existingFA = Get-MailboxPermission -Identity $mbx.Mailbox -ErrorAction Stop |
                          Where-Object { $_.User -eq $usr.User -and $_.AccessRights -contains "FullAccess" -and $_.IsInherited -eq $false }

            if (-not $existingFA) {
                Write-Host "  Adding FullAccess..." -ForegroundColor Yellow
                Add-MailboxPermission -Identity $mbx.Mailbox -User $usr.User `
                    -AccessRights FullAccess -AutoMapping $true `
                    -InheritanceType All -ErrorAction Stop | Out-Null
                Write-Host "  FullAccess granted successfully!" -ForegroundColor Green
                $successCount++
            }
            else {
                Write-Host "  FullAccess already exists — skipping." -ForegroundColor Green
                $skipCount++
            }
        }
        catch {
            Write-Warning "  Failed to process FullAccess for $($usr.User) on $($mbx.Mailbox): $_"
            $errorCount++
        }

        # --------------------------
        # 2. SEND AS PERMISSION
        # --------------------------
        try {
            $existingSA = Get-RecipientPermission -Identity $mbx.Mailbox -ErrorAction Stop |
                          Where-Object { $_.Trustee -eq $usr.User -and $_.AccessRights -contains "SendAs" }

            if (-not $existingSA) {
                Write-Host "  Adding SendAs..." -ForegroundColor Yellow
                Add-RecipientPermission -Identity $mbx.Mailbox -Trustee $usr.User `
                    -AccessRights SendAs -Confirm:$false -ErrorAction Stop | Out-Null
                Write-Host "  SendAs granted successfully!" -ForegroundColor Green
                $successCount++
            }
            else {
                Write-Host "  SendAs already exists — skipping." -ForegroundColor Green
                $skipCount++
            }
        }
        catch {
            Write-Warning "  Failed to process SendAs for $($usr.User) on $($mbx.Mailbox): $_"
            $errorCount++
        }

        Write-Host "---------------------------------------------"
    }
}

# Summary
Write-Host "`n========== SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Permissions granted: $successCount" -ForegroundColor Green
Write-Host "Permissions skipped: $skipCount" -ForegroundColor Yellow
Write-Host "Errors encountered: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
Write-Host "============================`n" -ForegroundColor Cyan

# Disconnect from Exchange Online
try {
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction Stop
    Write-Host "Disconnected from Exchange Online." -ForegroundColor Green
}
catch {
    Write-Warning "Failed to disconnect cleanly: $_"
}
