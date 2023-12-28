#
# OneLaunch Removal Script
# By: Richard Im (@richeeta)
# Last Updated: December 28, 2023
# 
# DESCRIPTION:
# This PowerShell script kills all OneLaunch processes, disables scheduled tasks associated with OneLaunch, and removes files and registry keys associated with OneLaunch.
#
# HOW TO USE: 
# (1) On the host machine, start PowerShell as an Administrator. 
# (2) curl http://github.com/ -O C:\Windows\Temp\ORS.ps1
# (3) cd C:\Windows\Temp
# (4) .\ORS.ps1
#

# Function to write progress
function Write-ProgressMessage {
    param (
        [string]$activity,
        [string]$status
    )
    Write-Progress -Activity $activity -Status $status
}

try {
    # Kill processes with "OneLaunch" in the name
    Write-ProgressMessage -activity "Killing Processes" -status "In Progress"
    $failedProcesses = @()
    Get-Process | Where-Object { $_.Name -like "*OneLaunch*" } | ForEach-Object {
        try {
            $_ | Stop-Process -Force
        } catch {
            $failedProcesses += $_.Name
        }
    }
    Start-Sleep -Seconds 2

    # Confirm no running process with "OneLaunch"
    if ($failedProcesses.Count -eq 0) {
        Write-Host "SUCCESS: All processes with 'OneLaunch' killed"
    } else {
        Write-Host "FAILED: Could not kill processes: $($failedProcesses -join ', ')"
    }

    # Remove scheduled tasks with "OneLaunch"
    Write-ProgressMessage -activity "Removing Scheduled Tasks" -status "In Progress"
    $failedTasks = @()
    Get-ScheduledTask | Where-Object { $_.TaskName -like "*OneLaunch*" } | ForEach-Object {
        try {
            Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false
        } catch {
            $failedTasks += $_.TaskName
        }
    }
    Start-Sleep -Seconds 2

    # Confirm no scheduled task with "OneLaunch"
    if ($failedTasks.Count -eq 0) {
        Write-Host "SUCCESS: All scheduled tasks with 'OneLaunch' removed"
    } else {
        Write-Host "FAILED: Could not remove scheduled tasks: $($failedTasks -join ', ')"
    }

    # Search and remove files and registry keys with "OneLaunch"
    Write-ProgressMessage -activity "Removing Files and Registry Keys" -status "In Progress"
    $failedFilesAndKeys = @()
    Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*OneLaunch*" } | ForEach-Object {
        try {
            Remove-Item $_.FullName -Force -Recurse
        } catch {
            $failedFilesAndKeys += $_.FullName
        }
    }
    Get-ChildItem -Path HKLM:\, HKCU:\ -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*OneLaunch*" } | ForEach-Object {
        try {
            Remove-Item $_.Name -Force -Recurse
        } catch {
            $failedFilesAndKeys += $_.Name
        }
    }
    Start-Sleep -Seconds 2

    # Confirm no file or registry key with "OneLaunch"
    if ($failedFilesAndKeys.Count -eq 0) {
        Write-Host "SUCCESS: All files and registry keys with 'OneLaunch' removed"
    } else {
        Write-Host "FAILED: Could not remove files/keys: $($failedFilesAndKeys -join ', ')"
    }

    # Final summary
    if ($failedProcesses.Count -eq 0 -and $failedTasks.Count -eq 0 -and $failedFilesAndKeys.Count -eq 0) {
        Write-Host "OneLaunch has been removed from this system!"
    } else {
        Write-Host "OneLaunch removal was not fully successful. Review the errors above."
    }
} catch {
    Write-Host "An error occurred: $_"
}
