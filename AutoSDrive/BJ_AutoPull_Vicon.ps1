# Written by:	Brandon Johns
# Last edited:	2021-09-22
# Purpose:	Pull new data from S Drive to Amarantha

### Notes ###
#   See main notes file

################################################################
# Script input
################################
# Output of "whoami" and "hostname", as run on computer to backup (Prevent running on wrong machine)
$whoamiOutput = "mu00042824\hri"
$hostnameOutPut = "mu00042824"

# Network drive
$shareUser = "monash\bdjoh3"
$shareRoot = "\\ad.monash.edu\shared\RoMI-Lab\Construction-Robots"

# Locations of Git repos to update
$gitList = @(
    "C:\Users\hri\Documents\Brandon\CraneExp"
    "C:\Users\hri\Documents\Brandon\Matlab-CraneSim"
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

# Pull each git repo
for ($idx = 0; $idx -lt $gitList.count; $idx++)
{
    # Test that the directory is a git repo
    if (git -C $gitList[$idx] rev-parse --is-inside-work-tree)
    {
        # Option "-C <path>" = Run as if git was started in <path> instead of the current working directory
        git -C $gitList[$idx] pull
        $EC = $LastExitCode

        # Run merge if git exits in failure
        if ($EC -ne 0)
        {
            # Commit pending changes
            git -C $gitList[$idx] add .
            git -C $gitList[$idx] commit .

            # Merge
            git -C $gitList[$idx] pull
            git -C $gitList[$idx] mergetool
            git -C $gitList[$idx] commit
            git -C $gitList[$idx] push
        }
    }
    else
    {
        echo ("Error: Dir is not a git repo" + $gitList[$idx])
        pause
    }
    echo ("BJ: Next`n`n")
}

# Disconnect network drive if it was not originally connected
if(-not $Flag_SDriveConnectedAtStart) { Remove-PSDrive S }

echo "BJ: Finished"
pause


