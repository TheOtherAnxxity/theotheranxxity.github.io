# Declare HTML used to beautify mod list
[String[]]$Html = @(
"<!DOCTYPE html>"
"<html lang=`"en`">"
"<head>"
"<title>Mod List</title>"
"<meta charset=`"UTF-8`">"
"<link rel=`"stylesheet`" href=`"../../mod-list.css`">"
"<script src=`"https://kit.fontawesome.com/1565b8f9f4.js`" crossorigin=`"anonymous`"></script>"
"</head>"
"<body>"
"</body>"
"</html>"
)
# Declare modpack name and version
[String]$ModPackVersion = "1.0.0"
[String]$ModPackName = "Guns Go Brrrr"
[String]$ModPackFile = ("./" + $ModPackName + "-" + $ModPackVersion + ".zip")
[String]$ModPackPath = "C:\Users\ASUS\WebstormProjects\theotheranxxity.github.io\mod-packs\guns-go-brrrr"

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
Add-Content -Path "./mod-list.html" -Value $Html[0..8]
Add-Content -Path "./mod-list.html" -Value $ModList
Add-Content -Path "./mod-list.html" -Value $Html[9, 10]
# Delete old modlist
Remove-Item "./modlist.html"
