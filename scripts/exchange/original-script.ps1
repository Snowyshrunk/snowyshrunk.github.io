Connect-ExchangeOnline

$mailboxes = Import-Csv .\mailboxes.csv
$users = Import-Csv .\users.csv

foreach ($mbx in $mailboxes) {

    foreach ($usr in $users) {

        Write-Host "Processing $($usr.User) on $($mbx.Mailbox)..." -ForegroundColor Cyan

        # --------------------------
        # 1. FULL ACCESS PERMISSION
        # --------------------------
        $existingFA = Get-MailboxPermission -Identity $mbx.Mailbox |
                      Where-Object { $_.User -eq $usr.User -and $_.AccessRights -contains "FullAccess" }

        if (-not $existingFA) {
            Write-Host "Adding FullAccess..." -ForegroundColor Yellow
            Add-MailboxPermission -Identity $mbx.Mailbox -User $usr.User `
                -AccessRights FullAccess -AutoMapping $true -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "FullAccess already exists — skipping." -ForegroundColor Green
        }

        # --------------------------
        # 2. SEND AS PERMISSION
        # --------------------------
        $existingSA = Get-RecipientPermission -Identity $mbx.Mailbox |
                      Where-Object { $_.Trustee -eq $usr.User -and $_.AccessRights -contains "SendAs" }

        if (-not $existingSA) {
            Write-Host "Adding SendAs..." -ForegroundColor Yellow
            Add-RecipientPermission -Identity $mbx.Mailbox -Trustee $usr.User `
                -AccessRights SendAs -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "SendAs already exists — skipping." -ForegroundColor Green
        }

        Write-Host "---------------------------------------------"

    }
}

Disconnect-ExchangeOnline
