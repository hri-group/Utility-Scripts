# Written by:	Brandon Johns
# Last edited:	2021-09-30
# Purpose:	Clone git repo from S Drive

### Notes ###
#   See main notes file

# If setting fail to change, manually run from the orign repo (tested - works through powershell)
#   git config receive.denyCurrentBranch updateInstead
#   git --global mergetool.keepBackup false

# Sample use:
#   ShareRoot="/run/user/1000/gvfs/smb-share:server=ad.monash.edu,share=shared/RoMI-Lab/Construction-Robots"
#   ./bj_GitCloneLocal.sh "$ShareRoot/Git/CraneExp" "$HOME/brandon_ws"
#   ./bj_GitCloneLocal.sh "$ShareRoot/Git/HRI-GettingStartedNotes" "$HOME/brandon_ws/git"
#   ./bj_GitCloneLocal.sh "$ShareRoot/Git/Matlab-CraneSim" "$HOME/brandon_ws/git"
#   ./bj_GitCloneLocal.sh "$ShareRoot/Git/Utility-Scripts" "$HOME/brandon_ws/git"

################################################################
# Script input
################################
originGitRepo=$1

# Path to git repo to create, not including the repo itself
destination=$2

################################################################
# Automated
################################
# Configure origin repo to accept pushes (safe - should reject if pending changes on branch being pushed to)
git -C $originGitRepo config receive.denyCurrentBranch updateInstead

# Configure origin repo to not keep old merge tool data
git -C $originGitRepo config --global mergetool.keepBackup false

# Give same name to new repo
originLeaf=$(basename $originGitRepo)
newGitRepo="$destination/$originLeaf"

# Create a local git repo from another local git repo
git clone --no-local --no-hardlinks $originGitRepo $newGitRepo

# Set user and email in new repo
git -C $newGitRepo config user.name "brandon"
git -C $newGitRepo config user.email "test@test"

echo "BJ: Finished"

