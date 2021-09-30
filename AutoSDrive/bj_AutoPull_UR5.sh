# Written by:	Brandon Johns
# Last edited:	2021-09-22
# Purpose:	Pull new data from S Drive to UR5 Computer

### Notes ###
#   See main notes file

################################################################
# Script input
################################
# Output of "whoami" and "hostname", as run on computer to backup (Prevent running on wrong machine)
whoamiOutput="acrv"
hostnameOutPut="acrv-All-Series"

# Network drive
shareRoot="//ad.monash.edu/shared"
destination="/run/user/1000/gvfs/smb-share:server=ad.monash.edu,share=shared"

# Locations of Git repos to pull
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

# Pull each git repo
for (( idx=0; idx<${#gitList[@]}; idx++ ))
{
    gitRepo=${gitList[$idx]}

    # Test that the directory is a git repo
    # Apparently exit code 0 means enter the block
    if git -C $gitRepo rev-parse --is-inside-work-tree &> /dev/null
    then
        # Option "-C <path>" = Run as if git was started in <path> instead of the current working directory
        # $? returns the exit code of the previous command on standard out
        git -C $gitRepo pull
        EC=$?

        # Run merge if git exits in failure
        if [ $EC != 0 ]
        then
            # Commit pending changes
            git -C $gitRepo add .
            git -C $gitRepo commit .

            # Merge
            git -C $gitRepo pull
            git -C $gitRepo mergetool
            git -C $gitRepo commit
            git -C $gitRepo push
        fi
    else
        echo "Error: Dir is not a git repo $gitRepo"
        pause
    fi
    printf "BJ: Next\n\n"
}

# Disconnect network drive if it was not originally connected
if [[ "$Flag_SDriveConnectedAtStart" = "false" ]]
then
    gio mount -u "smb:$shareRoot"
fi

echo "BJ: Finished"

