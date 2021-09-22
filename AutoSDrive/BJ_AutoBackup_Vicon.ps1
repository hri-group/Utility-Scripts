# Written by:	Brandon Johns
# Last edited:	2021-09-17
# Purpose:	Backup Vicon Computer folders to S: Drive (on campus computers)

### Notes ###
#   See main notes file

################################################################
# Script input
################################
# Output of "whoami" and "hostname", as run on computer to backup (Prevent running on wrong machine)
$whoamiOutput = "mu00042824\hri"
$hostnameOutPut = "mu00042824"

# Backup destination (top level dir)
$destination = "S:\Backups\Vicon"

# Locations to backup
$sourceList = @(
    "C:\Users\Public\Documents\Vicon\Tracker3.9",
    "C:\Users\Public\Documents\Vicon\Tracker3.x",
    "C:\Users\hri\Documents\Brandon"
)

# Locations of Git repos to push
$gitList = @(
    "C:\Users\hri\Documents\Brandon\Git\ViconDS-local"
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

# Connect network drive
$cred = Get-Credential -Credential monash\bdjoh3
New-PSDrive -Name "S" -PSProvider "FileSystem" -Root "\\ad.monash.edu\shared\RoMI-Lab\Construction-Robots" -Credential $cred -Persist

# Create subdir for this backup instance
#   Name by date-time of backup
$date = get-date -format "yyyy-MM-dd_hh_mm"
$destination1 = Join-Path $destination $date

# Backup this script
Copy-Item $PSCommandPath -Destination $destination1

# Backup each source
for ($idx = 0; $idx -lt $sourceList.count; $idx++)
{
    $source = $sourceList[$idx]
    
    # Create subdir for source
    #   Name by <idx of source>_<leaf of source dir>
    $destination2 = Join-Path $destination1 ($idx.ToString() + "_" + (Split-Path $source -Leaf))
    
    # Backup
    robocopy $source $destination2 /mir
}

# Push git repos
for ($idx = 0; $idx -lt $gitList.count; $idx++)
{
    # Option "-C <path>" = Run as if git was started in <path> instead of the current working directory
    git -C $gitList[$idx] push
}

# Open windows explorer to folder
#start $destination1

# Wait
#pause

# Disconnect network drive
Remove-PSDrive S

echo "Finished"

# Wait
#pause

