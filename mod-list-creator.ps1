# Input parameters
param (
    [Parameter(Mandatory=$true)]
    [string]$ModPackPath,
    
    [Parameter(Mandatory = $true)]
    [string]$StyleSheet,
    
    [Parameter()]
    [string]$FontAwesome = $null
)

if (-not ($FontAwesome -eq $null)) {
    $FontAwesome = "<script src=`"$FontAwesome`" crossorigin=`"anonymous`"></script>"
} else {
    $FontAwesome = ""
}

# Declare HTML used to beautify mod list
[string[]]$Html = @(
    '<!DOCTYPE html>'
    '<html lang="en">'
    '<head>'
    '<title>Mod List</title>'
    '<meta charset="UTF-8">'
    "<link rel=`"stylesheet`" href=`"$StyleSheet`">"
    "$FontAwesome"
    '</head>'
    '<body>'
    '</body>'
    '</html>'
)

# Validate that path exists
if (-not (Test-Path -Path $ModPackPath)) {
    Write-Error "Failed to validate given path"
    Exit 1
}

# Set location
Set-Location $ModPackPath

[string]$ModPackName
[string]$ModPackVersion

# Validate that it is indeed a packwiz mod pack by running packwiz refrsh
$PackwizRefresh = Start-Process -FilePath "packwiz" -ArgumentList "refresh" -NoNewWindow -PassThru -Wait
if ($PackwizRefresh.ExitCode -ne 0) {
    Write-Error "Failed to validate folder as packwiz mod pack"
    Exit $PackwizRefresh.ExitCode
}

# Auto fetch both mod pack name and version
foreach($line in ((Get-Content -Path "./pack.toml") | ForEach-Object -Process { $_ = $_.Trim(); $_.StartsWith("name") -or $_.StartsWith("version") })) {
    # Yes this is pretty horrible but since there is only one name and one version key this should work.
    [string]$Type
    if ($line.StartsWith("name")) {
        $line = $line.TrimStart("name")
        $Type = "name"
    } elseif ($line.StartsWith("version")) {
        $line = $line.TrimStart("version")
        $Type = "version"
    }
    $line = $line.TrimStart()
    $line = $line.TrimStart('=')
    $line = $line.Trim()
    if ($line.StartsWith('"')) {
        $line = $line.Trim('"')
    } elseif ($line.StartsWith("'")) {
        $line = $line.Trim("'")
    }
    if ($Type -eq "name") {
        $ModPackName = $line
    } elseif ($Type -eq "version") {
        $ModPackVersion = $line
    }
}

# Construct mod pack file and path
[string]$ModPackFile = "./$ModPackName-$ModPackVersion.zip"

# Export using packwiz
Start-Process -FilePath "packwiz" -ArgumentList @("curseforge", "export") -NoNewWindow -Wait

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

# Delete old modlist
Remove-Item "./modlist.html"

# Beautify old mod list and write it to new mod list
Add-Content -Path "./mod-list.html" -Value $Html[0..9]
Add-Content -Path "./mod-list.html" -Value $ModList
Add-Content -Path "./mod-list.html" -Value $Html[10, 11]
