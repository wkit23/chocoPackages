# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

$ErrorActionPreference = 'Stop'; # stop on all errors

$packageName = 'zookeeper' # arbitrary name for the package, used in messages
$packageversion = "3.4.8"
$toolsDir    = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url         = 'http://www-eu.apache.org/dist/zookeeper/zookeeper-3.4.8/zookeeper-3.4.8.tar.gz' 
$cmd_file    = "$toolsDir\$packageName-$packageVersion\bin\zkserver.cmd"
$configDir   = "$toolsDir\$packageName-$packageVersion\conf"
$dataDir     = "$toolsDir\$packageName-$packageVersion\Data"

#Install-ChocolateyPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-package
Install-ChocolateyZipPackage "$packageName" $url $toolsDir

## Unzips a file to the specified location - auto overwrites existing content
## - https://chocolatey.org/docs/helpers-get-chocolatey-unzip
Get-ChocolateyUnzip "$toolsDir\$packageName-$packageVersion.tar" $toolsDir

## Set some configurations
Write-Host "Setting up configuration"
New-Item $dataDir -ItemType Directory
Copy-Item $configDir\zoo_sample.cfg $configDir\zoo.cfg

# Set the data folder
$invertedPath = $configDir -replace '\\', '/'
(Get-Content $configDir\zoo.cfg) | ForEach-Object { $_ -replace "/tmp/zookeeper", $invertedPath } | Set-Content "$configDir\zoo.cfg"

# set the rolling log
$logSettings = "log4j.rootLogger=DEBUG, CONSOLE, ROLLINGFILE"
(Get-Content $configDir\log4j.properties) | ForEach-Object { $_ -replace "#$logSettings", $logSettings } | Set-Content $configDir\log4j.properties

## Runs processes asserting UAC, will assert administrative rights - used by Install-ChocolateyInstallPackage
## - https://chocolatey.org/docs/helpers-start-chocolatey-process-as-admin
Write-Host "Setting $packageName as service"
Start-ChocolateyProcessAsAdmin "install $packageName $cmd_file" nssm

Write-Host "Starting service $packageName"
Start-Service "$packageName"