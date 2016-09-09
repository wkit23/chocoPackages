# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

$ErrorActionPreference = 'Stop'; # stop on all errors


$packageName= 'kibana' # arbitrary name for the package, used in messages
$packageVersion = '4.1.11'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://download.elastic.co/kibana/kibana/kibana-4.1.11-windows.zip' # download url, HTTPS preferred
$cmd_file   = "$toolsDir\$packageName-$packageVersion-windows\bin\kibana.bat"

Install-ChocolateyZipPackage "$packageName" $url $toolsDir

## Runs processes asserting UAC, will assert administrative rights - used by Install-ChocolateyInstallPackage
## - https://chocolatey.org/docs/helpers-start-chocolatey-process-as-admin
Write-Host "Setting $packageName as service"
Start-ChocolateyProcessAsAdmin "install $packageName $cmd_file" nssm

Write-Host "Starting service $packageName"
Start-Service "$packageName"