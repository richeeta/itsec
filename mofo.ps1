param (
    [string]$f
)

# Check for arguments and display usage information if none are provided
if ([string]::IsNullOrEmpty($f)) {
    Write-Output "Usage: .\mofo.ps1 -f <DirectoryPath>"
    Write-Output "Search recursively in <DirectoryPath> for 'LessonPlan' or 'Solutions' or 'Solved', and then delete matches based on user input."
    Write-Output "Note: Matches containing 'Unsolved' are excluded."
    Write-Output ""
    Write-Output "Examples:"
    Write-Output "    .\mofo.ps1 -f C:\Your\Directory\Path"
    exit
}

# Check if the directory exists
if (-Not (Test-Path -Path $f -PathType Container)) {
    Write-Error "The specified directory path does not exist."
    exit
}

# Search for the files and folders
$matches = Get-ChildItem -Path $f -Recurse |
    Where-Object {
        ($_.Name -match "LessonPlan" -or $_.Name -match "Solutions" -or $_.Name -match "Solved") -and
        $_.FullName -notmatch "Unsolved"
    } |
    Select-Object -Property FullName

# Output the numbered list of matches
for ($i=0; $i -lt $matches.Count; $i++) {
    Write-Output ("{0}. {1}" -f ($i + 1), $matches[$i].FullName)
}

# Prompt for user action
$action = Read-Host -Prompt "Enter (1) to delete all matches, (2) to specify matches to delete by number (comma-separated), or (3) to delete only 'LessonPlan' matches"

switch ($action) {
    "1" {
        # Delete all matches
        $matches | ForEach-Object {
            Remove-Item $_.FullName -Recurse -Force
            Write-Output ("Deleted: {0}" -f $_.FullName)
        }
    }
    "2" {
        # Prompt for specific matches to delete
        $specificMatches = Read-Host -Prompt "Enter the numbers of the matches you want to delete (comma-separated)"
        $specificMatches.Split(',') | ForEach-Object {
            $index = [int]($_.Trim()) - 1
            if ($index -ge 0 -and $index -lt $matches.Count) {
                Remove-Item $matches[$index].FullName -Recurse -Force
                Write-Output ("Deleted: {0}" -f $matches[$index].FullName)
            }
            else {
                Write-Warning ("Invalid number: {0}" -f ($_))
            }
        }
    }
    "3" {
        # Delete only "LessonPlan" matches
        $lessonPlanMatches = $matches | Where-Object {
            $_.FullName -match "LessonPlan"
        }

        $lessonPlanMatches | ForEach-Object {
            Remove-Item $_.FullName -Recurse -Force
            Write-Output ("Deleted: {0}" -f $_.FullName)
        }
    }
    default {
        Write-Warning "Invalid action. Exiting..."
    }
}
