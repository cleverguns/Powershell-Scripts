

###################################
# Source Location Details
#-------------------
$Source = "\\Server2012\ContentFolder"

# Destination Details
#-------------------
$Destination = "D:\ContentFolder"

# Log File Location
#-------------------
$Folderpath = "D:\FolderSync"

####################################
# Declaration of Variables
$Date1 = Get-Date -UFormat "%m-%d-%y"
$time = Get-Date -Format g
$Logname = "SyncLog.log"
$FilePath = "$Folderpath"+ "\$Logname"
$Errormap = $null
$errorcheck  = ''
$error.Clear()

###################################

# Setting Log File

    If ((Test-Path -Path $Folderpath))
    {
            if ((Test-Path -Path $FilePath))
            {
 
                $filesize = Get-ChildItem $FilePath ; if ($filesize.Length -gt 100kb ) {Remove-Item $filesize.FullName -Force; New-Item $logfolder\$Logname -ItemType file -Force} 
                
                else {}
             }
            else
            {
                New-Item $FilePath -ItemType file -Force
            }
    }
    else
    {

        New-Item $Folderpath -Type directory -Force
        New-Item $FilePath -ItemType file -Force

    }

##################################
# Connection to Source

If ((Test-Path -Path $Source))
    {
        Add-Content -Path $FilePath -Value "$time Connection to $Source established Successfully`n"  
    }
else
    {
        Add-Content -Path $FilePath -Value "$time Error : Connection to $Source Failed - Script execution stopped`n"
        exit
    }


#Represents the abstract class from which all implementations of the MD5 hash algorithm inherit.

##################################
function Get-FileMD5 {
    $error.Clear()
    Param([string]$file)
    $mode = [System.IO.FileMode]("open")
    $access = [System.IO.FileAccess]("Read")
    $md5 = New-Object System.Security.Cryptography.MD5CryptoServiceProvider
    $fs = New-Object System.IO.FileStream($file,$mode,$access)
    $Hash = $md5.ComputeHash($fs)
    $fs.Close()
    [string]$Hash = $Hash
    Return $Hash
}
Add-Content -Path $FilePath -Value "$time Data Replication Started`n"

##################################

function Copy-LatestFile{
    $error.Clear()
    Param($File1,$File2,[switch]$whatif)
    $File1Date = get-Item $File1 | foreach-Object{$_.LastWriteTimeUTC}
    $File2Date = get-Item $File2 | foreach-Object{$_.LastWriteTimeUTC}
    if($File1Date -gt $File2Date)
    {
        #Write-Host "$File1 is Newer... Copying..." -ForegroundColor Green
        Add-Content -Path $FilePath -Value "$time $File1 is Newer. Copying...`n"
        if($whatif){Copy-Item -path $File1 -dest $File2 -force -whatif}
        else{Copy-Item -path $File1 -dest $File2 -force}
        $errormap = $error[0]
        if($error[0] -eq $null) {} else {Add-Content -Path $FilePath -Value "$time Error $errormap"; $errorcheck = "1"}
    }

}

# Getting Files/Folders from Source and Destination
$SrcEntries = Get-ChildItem $Source -Recurse
$DesEntries = Get-ChildItem $Destination -Recurse

# Parsing the folders and Files from Collections
$Srcfolders = $SrcEntries | Where-Object{$_.PSIsContainer}
$SrcFiles = $SrcEntries | Where-Object{!$_.PSIsContainer}
$Desfolders = $DesEntries | Where-Object{$_.PSIsContainer}
$DesFiles = $DesEntries | Where-Object{!$_.PSIsContainer}

foreach($folder in $Srcfolders)
{
    $error.Clear()
    $SrcFolderPath = $source -replace "\\","\\" -replace "\:","\:"
    $DesFolder = $folder.Fullname -replace $SrcFolderPath,$Destination
    if(!(test-path $DesFolder))
    {
        Add-Content -Path $FilePath -Value "$time Folder $DesFolder Missing. Creating it!`n"
        new-Item $DesFolder -type Directory | out-Null
        $errormap = $error[0]
        if($error[0] -eq $null) {} else {Add-Content -Path $FilePath -Value "$time Error  $errormap"; $errorcheck = "1"}
    }
}

foreach($entry in $SrcFiles)
{
    $error.Clear()
    $SrcFullname = $entry.fullname
    $SrcName = $entry.Name
    $SrcFilePath = $Source -replace "\\","\\" -replace "\:","\:"
    $DesFile = $SrcFullname -replace $SrcFilePath,$Destination
    if(test-Path $Desfile)
    {
        $SrcMD5 = Get-FileMD5 $SrcFullname
        $DesMD5 = Get-FileMD5 $DesFile
        If(Compare-Object $srcMD5 $desMD5)
        {

            Add-Content -Path $FilePath -Value "$time The Files MD5's are Different... Checking Write`n"
            Copy-LatestFile $SrcFullname $DesFile
            $errormap = $error[0]
            if($error[0] -eq $null) {} else {Add-Content -Path $FilePath -Value "$time Error  $errormap"; $errorcheck = "1"}
        }
    }
    else
    {
        $error.Clear()
        Add-Content -Path $FilePath -Value "$time $Desfile Missing... Copying from $SrcFullname`n"
        copy-Item -path $SrcFullName -dest $DesFile -force
        $errormap = $error[0]
        if($errormap -eq $null) {} else {Add-Content -Path $FilePath -Value "$time Error  $errormap"; $errorcheck = "1"}
    }
}

# Checking for Files that are in the Destinatino, but not in Source
foreach($entry in $DesFiles)
{
    $error.Clear()
    $DesFullname = $entry.fullname
    $DesName = $entry.Name
    $DesFilePath = $Destination -replace "\\","\\" -replace "\:","\:"
    $SrcFile = $DesFullname -replace $DesFilePath,$Source
    if(!(Test-Path $SrcFile))
    {

        Add-Content -Path $FilePath -Value "$time $SrcFile is deleted from Source... Deleting it from Destination`n"
        Remove-Item -path $DesFullname -Recurse -force
        $errormap = $error[0]
        if($error[0] -eq $null) {} else {Add-Content -Path $FilePath -Value "$time Error  $errormap"; $errorcheck = "1"}
    }
}
$error.Clear()
$Source = Get-ChildItem $Destination -Recurse
$dirs = $Source | Where { (gci $_.fullName).count -eq 0 } | select -expandproperty FullName
$dirs | Foreach-Object { Remove-Item $_ }
if ($errorcheck -ne '1') { Add-Content -Path $FilePath -Value "$time Data Replication completed successfully`n"}
else {Add-Content -Path $FilePath -Value "$time Data Replication completed with some error - Please check the log for details`n"}

###################################
