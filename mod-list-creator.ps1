# Input parameters
param (
    [Parameter(Mandatory=$true)]
    [string]$ModPackFolder,

    [Parameter(Mandatory=$true)]
    [string]$ModPackName,

    [Parameter(Mandatory=$true)]
    [string]$ModPackVersion,

    [Parameter()]
    [string]$ModPackSearchPath = "C:\Users\ASUS\WebstormProjects\theotheranxxity.github.io\mod-packs"
)

# Declare HTML used to beautify mod list
[string]$FontAwesome = "https://kit.fontawesome.com/1565b8f9f4.js"
[string[]]$Html = @(
    '<!DOCTYPE html>'
    '<html lang="en">'
    '<head>'
    '<title>Mod List</title>'
    '<meta charset="UTF-8">'
    '<link rel="stylesheet" href="../../mod-list.css">'
    "<script src=`"$FontAwesome`" crossorigin=`"anonymous`">"
    '</script>'
    '</head>'
    '<body>'
    '</body>'
    '</html>'
)

# Construct mod pack file and path
[string]$ModPackFile = "./$ModPackName-$ModPackVersion.zip"
[string]$ModPackPath = Join-Path -Path $ModPackSearchPath -ChildPath $ModPackFolder

# Set location
Set-Location $ModPackPath
# Export using packwiz
Start-Process -FilePath "./packwiz.exe" -ArgumentList @("curseforge", "export") -NoNewWindow -Wait

# Create a new temp directory
New-Item -Path "./temp" -ItemType Directory
# Unzip to the temp directory
Expand-Archive -Path $ModPackFile -DestinationPath "./temp"
# Move the mod list file
Move-Item -Path "./temp/modlist.html" -Destination "./modlist.html"
# Delete the temp directory
Remove-Item -Path "./temp" -Recurse
# Dlete the mod pack archive
Remove-Item $ModPackFile

# Create new mod list
New-Item -Path "./mod-list.html" -Force
$ModList = Get-Content -Path "./modlist.html"

# Beautify old mod list and write it to new mod list
Add-Content -Path "./mod-list.html" -Value $Html[0..9]
Add-Content -Path "./mod-list.html" -Value $ModList
Add-Content -Path "./mod-list.html" -Value $Html[10, 11]

# Delete old modlist
Remove-Item "./modlist.html"
