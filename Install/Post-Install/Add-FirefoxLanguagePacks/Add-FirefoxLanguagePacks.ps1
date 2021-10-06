<#
.SYNOPSIS
    Deploy additional language packs to Firefox install directory
.DESCRIPTION
    This post install script will create the necessary directory for Firefox language packs, copy the packs to that folder and rename them to the correct format  
#>

<#
    Check OS architecture and adjust paths accordingly
#>
if ([System.Environment]::Is64BitOperatingSystem -ne "True"){
    $architecture = ${Env:ProgramFiles(x86)}
} else {
    $architecture = $Env:Programfiles
}

<#
    Check if distribution and distribution/extensions exist under Firefox install directory
    If not, Create folders
#>
$folder = $architecture + '\Mozilla Firefox\distribution\extensions\'
if (-not(Test-Path -Path $folder -PathType Container)) {
    try {
        $null = New-Item -ItemType Directory -Path $folder -Force -ErrorAction Stop
    }
    catch {
        throw $_
    }
}

<#
    Copy language packs to extensions folder
    Rename language packs to meet required naming convention
#>
Copy-Item -Filter '.\*.xpi' -Destination $folder
Get-ChildItem -Path $folder | Rename-Item -NewName {"langpack-" + (($_.name).TrimEnd(".xpi")) + "@firefox.mozilla.org.xpi"}


<#
    Get system locale
    Check to see if policies.json exists
        If it doesn't, Create it and populate it with the relavant policy information
        If it does exist, Amend it to include the relevant policy information
#>
$systemlocale = (Get-WinSystemLocale).name
$json = @"
{
  "policies": {
   "RequestedLocales": "$systemlocale"
  }
}
"@
$policiesfile = $architecture + '\Mozilla Firefox\distribution\policies.json'

if (-not(Test-Path -Path $policiesfile -PathType Leaf)) {
    New-Item -ItemType File -Path $policiesfile -Force
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($policiesfile, $json, $Utf8NoBomEncoding)
} else {
    $policyjson = Get-Content $policiesfile | ConvertFrom-Json -Depth 10
    $policyjson.policies | Add-Member -NotePropertyName RequestedLocales -NotePropertyValue "$systemlocale" -Force
    $policyjson = $policyjson | ConvertTo-Json -Depth 10
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($policiesfile, $policyjson, $Utf8NoBomEncoding)
}