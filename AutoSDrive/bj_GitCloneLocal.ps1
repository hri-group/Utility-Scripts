# Written by:	Brandon Johns
# Last edited:	2021-12-15
# Purpose:	Clone git repo from S Drive

### Notes ###
#   See main notes file

# If setting fail to change, manually run from the orign repo (tested - works through powershell)
#   git config receive.denyCurrentBranch updateInstead
#   git --global mergetool.keepBackup false

# Sample use:
#   $ShareRoot="S:/RoMI-Lab/Construction-Robots"
#   ./bj_GitCloneLocal.ps1 "$ShareRoot/Git/CraneExp" "$HOME/Documents/Brandon/git"
#   ./bj_GitCloneLocal.ps1 "$ShareRoot/Git/HRI-GettingStartedNotes" "$HOME/Documents/Brandon/git"
#   ./bj_GitCloneLocal.ps1 "$ShareRoot/Git/Matlab-CraneSim" "$HOME/Documents/Brandon/git"
#   ./bj_GitCloneLocal.ps1 "$ShareRoot/Git/Utility-Scripts" "$HOME/Documents/Brandon/git"

################################################################
# Script input
################################
param (
	[Parameter(Mandatory=$true,ValueFromPipeline=$false)][string]$originGitRepo,
	[Parameter(Mandatory=$true,ValueFromPipeline=$false)][string]$destination
)
# INPUT:
#	originGitRepo = path to root of git repo
#	destination = Path to git repo to create, not including the repo itself

################################################################
# Automated
################################
# Give same name to new repo
$originLeaf = Split-Path $originGitRepo -Leaf
$newGitRepo = Join-Path $destination $originLeaf

# Promp the user for confirmation to proceed
Write-Host ""
Write-Host ("Will create new Git Reopsitory @ " + $newGitRepo )
Write-Warning "Do you want to proceed? (Y/H)" -WarningAction Inquire -ActionPreference

# Configure origin repo to accept pushes (safe - should reject if pending changes on branch being pushed to)
git -C $originGitRepo config receive.denyCurrentBranch updateInstead

# Configure origin repo to not keep old merge tool data
git -C $originGitRepo config --global mergetool.keepBackup false

# Create a local git repo from another local git repo
New-Item -Path $destination -Type Directory
git clone --no-local --no-hardlinks $originGitRepo $newGitRepo

# Set user and email in new repo
git -C $newGitRepo config user.name "brandon"
git -C $newGitRepo config user.email "test@test"

Write-Host "BJ: Finished"
pause
