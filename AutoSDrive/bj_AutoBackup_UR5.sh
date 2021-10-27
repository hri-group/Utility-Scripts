# Written by:	Brandon Johns
# Last edited:	2021-09-21
# Purpose:	Backup UR5 Computer to S: Drive

### Notes ###
#   See main notes file

################################################################
# CLI Input
################################
# DEFALUT (no flags): Push git repos, copy dirs, copy individual files
# git: Only push git repos
# full: Push git repos, copy dirs, zip and copy dirs copy individual files

Flag_GitOnly="false"
Flag_Full="false"
if [ "$1" = "git" ]
then
    echo "BJ: Git Push only"
    Flag_GitOnly="true"
elif [ "$1" = "full" ]
then
    echo "BJ: Full backup"
    Flag_Full="true"
fi

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
    "$HOME/brandon_ws/CraneExp/scripts"
    "$HOME/brandon_ws/CraneExp/pure/src"
    "$HOME/brandon_ws/CraneExp/pure/bin"
    "$HOME/brandon_ws/CraneExp/catkin/src/bj_ur5_gripper"
)

# Locations to zip and backup
zipTmpDir="$HOME/brandon_ws"
declare -a sourceListZip=(
    "$HOME/brandon_ws/CraneExp"
)

# Individual files to backup
declare -a sourceListFiles=(
    "$HOME/.bashrc"
)

# Locations of Git repos to push
declare -a gitList=(
    "$HOME/brandon_ws/CraneExp"
    "$HOME/brandon_ws/git/Matlab-CraneSim"
    "$HOME/brandon_ws/git/HRI-GettingStartedNotes"
    "$HOME/brandon_ws/git/Utility-Scripts"
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
# Wait a little for the drive to connect
waitTime=0
while [[ ! -d $destination ]]
do
    echo "(Waiting to connect)"
    sleep 1
    waitTime=$(( $waitTime + 1 ))

    if [[ $waitTime -gt 5 ]]
    then
        echo "Error: Destination does not exist"
        exit 1
    fi
done

# Don't backup if doing git push only
if [ ! "$Flag_GitOnly" = "true" ]
then
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
        echo "BJ: Copying $source/"
        rsync -r --info=progress2 "$source/" $destination2
    }

    if [ "$Flag_Full" = "true" ]
    then
        # Backup each source (with zipping)
        for (( idx=0; idx<${#sourceListZip[@]}; idx++ ))
        {
            source=${sourceListZip[$idx]}
            sourceLeaf=$(basename $source)

            # Create name for zip
            #   Name by <idx of source>_<leaf of source dir>
            zipName="$idx""_$sourceLeaf"".zip"

            tmpZipDir="$HOME/brandon_ws"
            tmpZipPath="$tmpZipDir/$zipName"

            # Zip locally
            #   Zip can copy a remote location, but super slow => send local and then use rsync to move
            echo "BJ: Ziping and Copying $source/"
            zip -0 -r --quiet $tmpZipPath "$source/"

            # $? returns the exit code of the previous command on standard out
            EC=$?
            if [ $EC != 0 ]
            then
                echo "BJ: ERROR in execution of zip command"
            fi

            # Move zip to backup location
            rsync --remove-source-files --info=progress2 $tmpZipPath "$destination1/"
        }
    fi

    # Backup individually specified files
    destinationFiles="$destination1/IndividualFiles"
    mkdir $destinationFiles
    for (( idx=0; idx<${#sourceListFiles[@]}; idx++ ))
    {
        source=${sourceListFiles[$idx]}

        # Backup
        echo "BJ: Copying $source/"
        cp "$source" "$destinationFiles"
    }
fi

# Push git repos
for (( idx=0; idx<${#gitList[@]}; idx++ ))
{
    gitRepo=${gitList[$idx]}

    echo "BJ: Git Pushing $gitRepo"

    # Option "-C <path>" = Run as if git was started in <path> instead of the current working directory
    git -C $gitRepo push
}

# Disconnect network drive if it was not originally connected
if [[ "$Flag_SDriveConnectedAtStart" = "false" ]]
then
    gio mount -u "smb:$shareRoot"
fi

echo "BJ: Finished"

