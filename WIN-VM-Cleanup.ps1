# Clear command/terminal shell history
function Clear-TerminalHistory {
    Remove-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt" -ErrorAction SilentlyContinue
    Write-Output "Cleared PowerShell command history."
}

# Clear recently used apps/documents
function Clear-RecentItems {
    $recentFolder = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Recent')
    Remove-Item "$recentFolder\*" -Force -ErrorAction SilentlyContinue
    Write-Output "Cleared recent documents and apps history."
}

# Remove unused desktop shortcuts
function Remove-UnusedDesktopShortcuts {
    $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'))
    $shortcuts = Get-ChildItem -Path $desktopPath -Filter "*.lnk"
    foreach ($shortcut in $shortcuts) {
        $lastAccess = (Get-Item $shortcut.FullName).LastAccessTime
        # Customize this threshold as needed (e.g., files not accessed in the last 30 days)
        if ((Get-Date) - $lastAccess).Days -gt 30) {
            Remove-Item $shortcut.FullName -Force
            Write-Output "Removed unused desktop shortcut: $($shortcut.Name)"
        }
    }
}

# Remove unused browser bookmarks (Example for Chrome)
function Remove-UnusedChromeBookmarks {
    $chromeBookmarks = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks"
    if (Test-Path $chromeBookmarks) {
        $json = Get-Content -Path $chromeBookmarks -Raw | ConvertFrom-Json
        # This is a complex task and may require custom logic to parse and update
        # Implement custom code to filter old bookmarks, if possible.
        Write-Output "This requires custom implementation per user preference."
    } else {
        Write-Output "Chrome bookmarks file not found."
    }
}

# Clear browser history and cache (Example for Chrome)
function Clear-ChromeHistoryAndCache {
    $chromeCache = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
    $chromeHistory = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
    if (Test-Path $chromeCache) {
        Remove-Item "$chromeCache\*" -Force -Recurse
        Write-Output "Cleared Chrome cache."
    }
    if (Test-Path $chromeHistory) {
        Remove-Item $chromeHistory -Force
        Write-Output "Cleared Chrome browsing history."
    }
}

# Close Web Browser (Example for Chrome)
function Close-ChromeBrowser {
    Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue
    Write-Output "Closed Chrome browser."
}

# Execute each task
Clear-TerminalHistory
Clear-RecentItems
Remove-UnusedDesktopShortcuts
Remove-UnusedChromeBookmarks
Clear-ChromeHistoryAndCache
Close-ChromeBrowser

Write-Output "System cleanup tasks completed."
