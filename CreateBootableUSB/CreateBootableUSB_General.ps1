<#
Written By:			Brandon Johns
Version Created:	2021-03-30
Last Updated:		2021-03-30

Adapted from
	https://www.thomasmaurer.ch/2018/07/create-a-usb-drive-for-windows-server-2019-installation/

######################################################
# Purpose
###########################
Use powershell to create a bootable USB
	e.g. For installing Ubuntu
	No third party tools required

Should also work for installing anything that usually goes on a CD, hence the ISO file (untested)

When to not use this script
	To install Windows 10
		You can use this script if you have an ISO, but it may be easier to use the Microsoft's Media Creation Tool
		https://www.microsoft.com/en-gb/software-download/windows10

######################################################
# How to use this script
###########################
Download the ISO for the new operating system
	Ubuntu: https://ubuntu.com/download/desktop
	Windows Server: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019?filetype=ISO
	etc.

Plug in USB

Set the variables
	$ISOFile = Path to the ISO with Ubuntu
	$USBFName = Name given by USB manufacturer
		To get this name, run
			Get-Disk | Where-Object -FilterScript{ $_.BusType -eq "USB" } | Format-Table -AutoSize
		Then identify your USB from the table and copy the FriendlyName value
	$USBFS = File system to use on the USB
		Match this to the requirements for the ISO
			Ubuntu: FAT32
			Windows: NTFS
		Accepted values (as of 2021-03): FAT, FAT32, exFAT, NTFS, ReFS
			See the 'Format-Volume' parameter '-FileSystem'
			https://docs.microsoft.com/en-us/powershell/module/storage/format-volume?view=windowsserver2019-ps
	$USBLabel = (any text string)
		This will show as the USB's name when you plug it in
		I suggest only use characters from A-Z (all caps) for the least chance of anything going wrong

Start PowerShell (admin)
Run the script by copy pasting each line into powershell... or all at once if you're brave
DONE

###########################
Note on windows images and using GPT partition style (for UEFI)
	Not all UEFI computers are able to boot from external boot media that use a NTFS filesystem
	=> Use MBR where you can
	Otherwise, if the install.wim file is larger than 4GB (FAT32 problems), split it with either one of
		dism /Split-Image
		Split-WindowsImage
	Setting the destination onto the USB, to where it should go
	Reference
		https://www.thomasmaurer.ch/2018/07/create-a-usb-drive-for-windows-server-2019-installation/
		https://docs.microsoft.com/en-us/powershell/module/dism/split-windowsimage?view=windowsserver2019-ps
		https://www.dell.com/support/kbdoc/en-au/000127789/windows-10-iso-contains-wim-file-that-is-big-for-fat32-file-system

#>
######################################################
# Script
###########################
# Set Variables
$ISOFile = "C:\Users\Brand\Downloads\ubuntu-18.04.4-desktop-amd64.iso"
$USBFS = FAT32
$USBLabel = UBUNTU
$USBFName = "SanDisk Ultra"
# $USBFName = "Generic Flash Disk"

# Setting: Pause execution on non-terminating errors
$ErrorActionPreference = "Inquire"

# Get the right USB Drive
$USBDrive = Get-Disk | Where FriendlyName -eq $USBFName

# Clean the USB Drive (THIS WILL REMOVE EVERYTHING)
$USBDrive | Clear-Disk -RemoveData -Confirm:$true -PassThru

# Convert Disk to MBR
$USBDrive | Set-Disk -PartitionStyle MBR

# Create partition primary and format
$Volume = $USBDrive | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem $USBFS -NewFileSystemLabel $USBLabel

# Set Partiton to Active
$Volume | Get-Partition | Set-Partition -IsActive $true

# Mount ISO
$ISOMounted = Mount-DiskImage -ImagePath $ISOFile -StorageType ISO -PassThru

# Driver letter
$ISODriveLetter = ($ISOMounted | Get-Volume).DriveLetter

# Copy Files to USB
Copy-Item -Path ($ISODriveLetter +":\*") -Destination ($Volume.DriveLetter + ":\") -Recurse

# Dismount ISO
Dismount-DiskImage -ImagePath $ISOFile
