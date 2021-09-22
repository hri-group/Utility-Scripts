# Written By:			Brandon Johns
# Version Created:	2021-03-30
# Last Updated:		2021-03-30
# Adapted from:		https://www.thomasmaurer.ch/2018/07/create-a-usb-drive-for-windows-server-2019-installation/

# See notes in general file

# $ISOFile = Path to the ISO with Ubuntu
# $USBFName = Name given by USB manufacturer
#	To get this name, run
#		Get-Disk | Where-Object -FilterScript{ $_.BusType -eq "USB" } | Format-Table -AutoSize
#	Then identify your USB from the table and copy the FriendlyName value

######################################################
# Script
###########################
# Set Variables
$ISOFile = "C:\Users\Brand\Downloads\ubuntu-18.04.4-desktop-amd64.iso"
$USBFName = "SanDisk Ultra"
# $USBFName = "Generic Flash Disk"

$ErrorActionPreference = "Inquire"
$USBDrive = Get-Disk | Where FriendlyName -eq $USBFName
$USBDrive | Clear-Disk -RemoveData -Confirm:$true -PassThru
$USBDrive | Set-Disk -PartitionStyle MBR
$Volume = $USBDrive | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel UBUNTU
$Volume | Get-Partition | Set-Partition -IsActive $true
$ISOMounted = Mount-DiskImage -ImagePath $ISOFile -StorageType ISO -PassThru
$ISODriveLetter = ($ISOMounted | Get-Volume).DriveLetter
Copy-Item -Path ($ISODriveLetter +":\*") -Destination ($Volume.DriveLetter + ":\") -Recurse
Dismount-DiskImage -ImagePath $ISOFile
