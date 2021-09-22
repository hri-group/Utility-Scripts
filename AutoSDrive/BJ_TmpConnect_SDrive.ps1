# Written by:	Brandon Johns
# Last edited:	2021-08-26
# Purpose: Connect to share, then disconnect on finish

################################################################
# Script input
################################
# Backup settings
$open_dir = "S:\windows\AutoBackup\Vicon"

################################################################
# Automated
################################
# Only run on shared computers
if ((whoami) -eq "monash\bdjoh3")
{
    echo "Error: Don't run on this computer"
    pause
    throw "Should already be connected to S Drive"
}

# Connect network drive
$cred = Get-Credential -Credential monash\bdjoh3
New-PSDrive -Name "S" -PSProvider "FileSystem" -Root "\\ad.monash.edu\shared\RoMI-Lab\Construction-Robots" -Credential $cred -Persist

# Open windows explorer to folder
start $open_dir

# Wait
pause

# Disconnect network drive
Remove-PSDrive S

echo "BJ_Finished"


