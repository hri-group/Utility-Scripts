# Written by:	Brandon Johns
# Last edited:	2021-09-22
# Purpose:	Backup Vicon Computer folders to S: Drive (on campus computers)

### Notes ###
#   See main notes file

################################################################
# Script input
################################
# Output of "whoami" and "hostname", as run on computer to backup (Prevent running on wrong machine)
$whoamiOutput = "mu00221990\hriadmin"
$hostnameOutPut = "MU00221990"

# Backup destination: root of mapping and path from mapped root to backup dir (mapped root = 'S')
$shareUser = "monash\bdjoh3"
$shareRoot = "\\ad.monash.edu\shared\RoMI-Lab\Construction-Robots"
$destination = "S:\Backups\Vicon"

# Locations to backup
$sourceList = @(
    "C:\Users\Public\Documents\Vicon\Tracker3.9"
    "C:\Users\Public\Documents\Vicon\Tracker3.x"
    "C:\Users\HRIadmin\Documents\Brandon"
)

# Exclude git dir from backup
$sourceExcludeDir = "C:\Users\HRIadmin\Documents\Brandon\git"

# Locations of Git repos to push
$gitList = @(
#    "C:\Users\HRIadmin\Documents\Brandon\git\CraneExp"
#    "C:\Users\HRIadmin\Documents\Brandon\git\Matlab-CraneSim"
    "C:\Users\HRIadmin\Documents\Brandon\git\HRI-GettingStartedNotes"
    "C:\Users\HRIadmin\Documents\Brandon\git\Utility-Scripts"
    "C:\Users\HRIadmin\Documents\Brandon\git\ViconDataStreamSDKExamples"
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
$Flag_SDriveConnectedAtStart = $true
if (-not (Test-Path $shareRoot))
{
    $Flag_SDriveConnectedAtStart = $false

    # Connect network drive
    $cred = Get-Credential -Credential $shareUser
    New-PSDrive -Name "S" -PSProvider "FileSystem" -Root $shareRoot -Credential $cred -Persist
}

# Test destination exists
if (-not (Test-Path $destination))
{
    # Disconnect network drive if it was not originally connected
    if(-not $Flag_SDriveConnectedAtStart) { Remove-PSDrive S }

    echo ("Error: Destination does not exist")
    pause
    throw "Destination does not exist"
}

# Create subdir for this backup instance
#   Name by date-time of backup
$date = get-date -format "yyyy-MM-dd_hh_mm"
$destination1 = Join-Path $destination $date
New-Item -Path $destination1 -Type Directory

# Backup this script
Copy-Item -LiteralPath $PSCommandPath -Destination $destination1

# Log file
$logFile = Join-Path $destination1 "BackupLog.txt"
$Flag_Error_Robocopy = $false
$Flag_Error_GitPush = $false

# Backup each source
for ($idx = 0; $idx -lt $sourceList.count; $idx++)
{
    $source = $sourceList[$idx]
    
    # Create subdir for source
    #   Name by <idx of source>_<leaf of source dir>
    $destination2 = Join-Path $destination1 ($idx.ToString() + "_" + (Split-Path $source -Leaf))
    
    # Backup (not sure if good choice of logging switches - change as needed if errors not logging enough info)
    #   /xd = exclude directory
    robocopy $source $destination2 /mir /unilog+:$logFile /v /ns /np /nfl /ndl /xd $sourceExcludeDir
    $EC = $LastExitCode

    # Log the exit code of robocopy
    echo ("BJ: Robocopy Exit Code (success=1) = " + $EC + "`n`n") | Out-File -FilePath $logFile -Append -Encoding utf8
    if ($EC -ne 1) { $Flag_Error_Robocopy = "error" }
}

# Push each git repo
for ($idx = 0; $idx -lt $gitList.count; $idx++)
{
    # Option "-C <path>" = Run as if git was started in <path> instead of the current working directory
    # Command "*>$1" = append all output streams to standard out (because git sends mensages to stderr for some reason)
    git -C $gitList[$idx] push --porcelain *>&1 | Out-File -FilePath $logFile -Append -Encoding utf8
    $EC = $LastExitCode

    # Log the exit code of git
    echo ("BJ: Git Exit Code (success=0) = " + $EC + "`n`n") | Out-File -FilePath $logFile -Append -Encoding utf8
    if ($EC -ne 0) { $Flag_Error_GitPush = $true }
}

# Tell user about any errors
if ($Flag_Error_Robocopy)
{
    echo "BJ: Robocopy completed with errors: See log file"
    pause
}
if ($Flag_Error_GitPush)
{
    echo "BJ: Git Push exited with errors: See log file"
    pause
}

echo "BJ: Finished" | Out-File -FilePath $logFile -Append -Encoding utf8

# Disconnect network drive if it was not originally connected
if(-not $Flag_SDriveConnectedAtStart) { Remove-PSDrive S }

echo "BJ: Finished"

