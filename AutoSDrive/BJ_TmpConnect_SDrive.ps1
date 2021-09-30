# Written by:	Brandon Johns
# Last edited:	2021-09-22
# Purpose: Connect to share, then disconnect on finish

### Notes ###
#   This script is computer independent

################################################################
# Script input
################################
# Root of mapping and path from mapped root dir to open (mapped root = 'S')
$shareUser = "monash\bdjoh3"
$shareRoot = "\\ad.monash.edu\shared\RoMI-Lab\Construction-Robots"
$OpenToPath = "S:\windows\AutoBackup\Vicon"

################################################################
# Automated
################################
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
if (-not (Test-Path $OpenToPath))
{
    echo ("Error: Destination does not exist")

    # Fallback to mount root
    $OpenToPath = $shareRoot
}

# Open windows explorer to folder
start $OpenToPath

# Only need to wait if terminating the connection at end
if(-not $Flag_SDriveConnectedAtStart) {
    # Wait for user input
    echo ("Press enter to terminate connection")
    pause

    # Disconnect network drive if it was not originally connected
    Remove-PSDrive S
}
else
{
    echo ("Connection left open")
}


echo "BJ_Finished"


