# Written by:	Brandon Johns
# Last edited:	2021-09-21
# Purpose:	Backup UR5 Computer to S: Drive

##################
# NOT FULLY TESTED
##################

### Notes ###
#   See main notes file

################################################################
# Script input
################################
# Output of "whoami" and "hostname", as run on computer to backup (Prevent running on wrong machine)
whoamiOutput="acrv"
hostnameOutPut="acrv-All-Series"

# Backup destination: root of mapping and path from mapped root to backup dir
shareRoot="//ad.monash.edu/shared"
destination="/run/user/1000/gvfs/smb-share:server=ad.monash.edu,share=shared/RoMI-Lab/Construction-Robots/Backups/UR5"

# Locations to backup
declare -a sourceList=(
    "$HOME/brandon_ws/scripts"
    "$HOME/brandon_ws/catkin/src/bj_ur5_gripper"
    "$HOME/brandon_ws/pure/craneVer1/src"
)

# Locations of Git repos to push
declare -a gitList=(

)

################################################################
# Automated
################################
# Only run on intended computer
if [[ ! $(whoami) = "$whoamiOutput" ]] || [[ ! $(hostname) = "$hostnameOutPut" ]]
then
    echo "Error: Should only be run on $hostnameOutPut as $whoamiOutput"
    exit 1
fi

# Connect network drive (if not already)
Flag_SDriveConnectedAtStart="true"
if [[ ! -d $destination ]]
then
    Flag_SDriveConnectedAtStart="false"
    gio mount "smb:$shareRoot"
fi

# Test destination exists
if [[ ! -d $destination ]]
then
    echo "Error: Destination does not exist"
    exit 1
fi

# Create subdir for this backup instance
#   Name by date-time of backup
date1=$(date +"%Y-%m-%d_%H_%M")
destination1="$destination/$date1"
mkdir $destination1

# Backup this script
#PathThisScript=$BASH_SOURCE
PathThisScript=$(realpath $0)
cp $PathThisScript $destination1

# Log file
logFile="$destination1/BackupLog.txt"
logText_ExitCodeRobocopy="VALUE NOT SET"
logText_ExitCodeGitPush="VALUE NOT SET"

# Backup each source
for (( idx=0; idx<${#sourceList[@]}; idx++ ))
{
    source=${sourceList[$idx]}
    sourceLeaf=$(basename $source)

    # Create subdir for source
    #   Name by <idx of source>_<leaf of source dir>
    destination2="$destination1/$idx""_$sourceLeaf"
    
    # Backup
    echo "$source/"
    echo $destination2
    rsync -r "$source/" $destination2
}

# Push git repos
for (( idx=0; idx<${#gitList[@]}; idx++ ))
{
    gitRepo=${gitList[$idx]}

    # Option "-C <path>" = Run as if git was started in <path> instead of the current working directory
    git -C $gitRepo push
}

# Disconnect network drive if it was not originally connected
if [[ "$Flag_SDriveConnectedAtStart" = "false" ]]
then
    gio mount -u "smb:$shareRoot"
fi

echo "BJ: Finished"

