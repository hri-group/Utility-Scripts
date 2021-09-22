# Written by:	Brandon Johns
# Last edited:	2021-09-22
# Purpose:	Clone git repo from S Drive

##################
# NOT FULLY TESTED
##################

### Notes ###
#   See main notes file

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

echo "BJ: Finished"

