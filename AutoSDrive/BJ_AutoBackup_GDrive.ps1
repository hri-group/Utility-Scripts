# Written by:	Brandon Johns
# Last edited:	2021-09-18
# Purpose:	Backup Google Drive to S: Drive

### Notes ###
#   See main notes file

################################################################
# Script input
################################
# Output of "whoami" and "hostname", as run on computer to backup (Prevent running on wrong machine)
$whoamiOutput = "monash\bdjoh3"
$hostnameOutPut = "MU00196772"

# Backup destination: root of mapping and path from mapped root to backup dir
$ShareRoot = "\\ad.monash.edu\shared"
$destination = "S:\RoMI-Lab\Construction-Robots\Backups\GDrive"

# Locations to backup
$sourceList = @(
    "G:\Shared drives\PhD Brandon Johns"
)

# Locations of Git repos to push
$gitList = @(

)

################################################################
# Automated
################################
# Only run on intended computer
if (((whoami) -ne $whoamiOutput) -or ((hostname) -ne $hostnameOutPut))
{
    echo ("Error: Should only be run on " + $hostnameOutPut + " as " + $whoamiOutput)
    pause
    throw "wrong computer"
}

# Connect network drive (if not already)
$SDrive_IsAlreadyConnected = $true
if (-not Test-Path $ShareRoot)
{
    $SDrive_IsAlreadyConnected = $false

    # Connect network drive
    $cred = Get-Credential -Credential monash\bdjoh3
    New-PSDrive -Name "S" -PSProvider "FileSystem" -Root $ShareRoot -Credential $cred -Persist
}

# Test destination exists
if (-not Test-Path $destination)
{
    echo ("Error: Destination does not exist")
    pause
    throw "Destination does not exist"
}

# Create subdir for this backup instance
#   Name by date-time of backup
$date = get-date -format "yyyy-MM-dd_hh_mm"
$destination1 = Join-Path $destination $date

# Backup this script
New-Item -Path $destination1 -Type Directory
Copy-Item -LiteralPath $PSCommandPath -Destination $destination1

# Log file
$logFile = Join-Path $destination1 "BackupLog.txt"
$logText_ExitCodeRobocopy = "VALUE NOT SET"
$logText_ExitCodeGitPush = "VALUE NOT SET"

# Backup each source
for ($idx = 0; $idx -lt $sourceList.count; $idx++)
{
    $source = $sourceList[$idx]
    
    # Create subdir for source
    #   Name by <idx of source>_<leaf of source dir>
    $destination2 = Join-Path $destination1 ($idx.ToString() + "_" + (Split-Path $source -Leaf))
    
    # Backup (not sure if good choice of logging switches - change as needed if errors not logging enough info)
    robocopy $source $destination2 /mir /unilog+:$logFile /v /ns /np /nfl /ndl
    $EC = $LastExitCode

    # Log the exit code of robocopy
    echo ("BJ: Robocopy Exit Code (success=1) = " + $EC) | Out-File -FilePath $logFile -Append -Encoding utf8
    if ($EC -ne 1)
    {
        $logText_ExitCodeRobocopy = "error"
    }
}

# Push git repos
for ($idx = 0; $idx -lt $gitList.count; $idx++)
{
    # Option "-C <path>" = Run as if git was started in <path> instead of the current working directory
    git -C $gitList[$idx] push | Out-File -FilePath $logFile -Append -Encoding utf8
    $EC = $LastExitCode

    # Log the exit code of git
    echo ("BJ: Git Exit Code (success=0) = " + $EC) | Out-File -FilePath $logFile -Append -Encoding utf8
    if ($EC -ne 0)
    {
        $logText_ExitCodeGitPush = "error"
    }

}

# Restore state of S Drive being connected or not
if(-not $SDrive_IsAlreadyConnected)
{
    # Disconnect network drive
    Remove-PSDrive S
}

# Tell user about any errors
if ($logText_ExitCodeRobocopy -eq "error")
{
    echo "BJ: Robocopy completed with errors: See log file"
    pause
}
if ($logText_ExitCodeGitPush -eq "error")
{
    echo "BJ: Git Push exited with errors: See log file"
    pause
}

echo "BJ: Finished" | Out-File -FilePath $logFile -Append -Encoding utf8
