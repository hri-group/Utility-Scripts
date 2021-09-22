# Utility-Scripts
Random utility scripts and notes

## (Matlab) Video To Gif
Convert a video to a gif - useful for adding to HRI slides

## (PowerShell) Bootable USB
Use powershell to create a bootable USB
For installing Ubuntu, etc.

## (PowerShell / Bash) Auto S Drive
Connect / disconnect from a Network drive (e.g. Monash S-Drive / Monash user home folder) and complete related tasks
*	Mostly intended for working on shared computers

Securely handle credentials
*	Does not store credentials - Prompts for user password input every time connecting
	*	Change this at your own risk
*	Detects if already connected (doesn't require credential input) and leaves connected when finished

Each script is self contained to work around restrictions with running remote scripts. Hence the duplication

Use
*	The current state of the scripts is as I use them. You will need to adjust. I leave in all variants for reference.
*	Read over the script and input your parameters in the "Script input" field
*	Run:
	*	Powershell: double clicking on script
	*	Bash: run from terminal

### AutoBackup
Create backups of specified files/folders to network drive
Push any git repos

### TmpConnect
Connect to S Drive and then pause. Disconnect when user resumes.
Intended for use in meeting rooms

### AutoPull
Pull any git repos


