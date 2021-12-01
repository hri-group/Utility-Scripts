# Written by:	Brandon Johns
# Last edited:	2021-12-01
# Purpose:	Mirror files from Amarantha to G-Drive: RoMI Construction

### Notes ###


################################################################
# Helper
################################
Class SourceDest {[String]$source; [String]$destAppend}
$SourceDestList = @()

################################################################
# Script input
################################
# Output of "whoami" and "hostname", as run on computer to backup (Prevent running on wrong machine)
$whoamiOutput = "amarantha\brand"
$hostnameOutPut = "Amarantha"

# Backup destination
$destinationRoot = "G:\Shared drives\RoMI Lab Construction\"

# Locations to backup
$SourceDestList += [SourceDest]@{
    source="G:\Shared drives\PhD Brandon Johns\1 Literature Review\PhD Docear 1\literature_repository"
    destAppend="Brandon-Literature"
}
$SourceDestList += [SourceDest]@{
    source="G:\Shared drives\PhD Brandon Johns\1 Literature Review\PhD Docear 1\PhD Docear 1.bib"
    destAppend="Brandon-Literature"
}
$SourceDestList += [SourceDest]@{
    source="C:\Users\Brand\Documents\MATLAB\2020 PhD\Matlab-CraneSim\CraneSim2"
    destAppend="Brandon-CraneSim"
}

# Locations of Git repos to push
$gitList = @(
    
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

# Test destination exists
if (-not (Test-Path $destinationRoot))
{
    echo ("Error: Destination does not exist")
    pause
    throw "Destination does not exist"
}

# Log file
$Flag_Error_Robocopy = $false
$Flag_Error_GitPush = $false

# Backup each source
Foreach ($sd in $SourceDestList)
{
    $source = $sd.source
    $destination = Join-Path $destinationRoot $sd.destAppend
    
    if (Test-Path -Path $source -Type leaf) 
    { # Copying a file
        # Create path
        $destDir = Split-Path -Path $destination
        if (-not (Test-Path $destDir))
        {
            New-Item -Path $destDir -Type Directory
        }

        Copy-Item -LiteralPath $source -Destination $destination
    }
    else
    { # Copying a folder
        # Add top dir back to robocopy
        $destination1 = Join-Path $destination (Split-Path $source -Leaf)

        # disable output: /NFL /NDL /NJH /NJS /nc /ns /np
        robocopy $source $destination1 /mir /mt /NFL /NDL /NJH /NJS /NC /NS /NP
        $EC = $LastExitCode

        # Log the exit code of robocopy
        echo ("BJ: Robocopy Exit Code (success<=7) = " + $EC + "`n")
        if ($EC -ge 8) { $Flag_Error_Robocopy = "error" }
    }
}


# Tell user about any errors
if ($Flag_Error_Robocopy)
{
    echo "BJ: Robocopy completed with errors"
    pause
}
if ($Flag_Error_GitPush)
{
    echo "BJ: Git Push exited with errors"
    pause
}

echo "BJ: Finished"
