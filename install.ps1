<#
Simple installer for shh-copy-id on Windows.

Usage (PowerShell):

    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
    irm https://raw.githubusercontent.com/anytokin/shh-copy-id/main/install.ps1 | iex

Parameters:
    -InstallDir   Optional custom install directory
    -NoModifyPath Do not add the install directory to the user PATH
#>

param(
    [string]$InstallDir,
    [switch]$NoModifyPath
)

$ErrorActionPreference = "Stop"

# Configuration
$RepoOwner = "anytokin"
$RepoName  = "shh-copy-id"

# GitHub API for latest release (used only for version detection)
$GitHubApiLatestUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"

# Where to download from: latest GitHub release asset
$DownloadUrl = "https://github.com/$RepoOwner/$RepoName/releases/latest/download/ssh-copy-id.exe"

$AppName    = "ssh-copy-id.exe"
$FolderName = "shh-copy-id"

function Get-LatestGithubVersion {
    param(
        [string]$ApiUrl
    )

    try {
        $headers = @{ "User-Agent" = "shh-copy-id-installer" }
        $response = Invoke-RestMethod -Uri $ApiUrl -Headers $headers

        $tag = $response.tag_name
        if (-not $tag) {
            return $null
        }

        $tag = $tag.Trim()
        if ($tag.StartsWith("v")) {
            $tag = $tag.Substring(1)
        }

        $clean = $tag.Split("-", 2)[0]

        return [version]$clean
    }
    catch {
        Write-Warning "Could not determine latest version from GitHub: $($_.Exception.Message)"
        return $null
    }
}

function Get-InstalledSshCopyIdVersion {
    param(
        [string]$LocalExePath
    )

    $candidatePaths = @()

    # 1) Explicit local exe path (in InstallDir)
    if ($LocalExePath -and (Test-Path $LocalExePath)) {
        $candidatePaths += $LocalExePath
    }

    # 2) Whatever is currently on PATH
    $cmd = Get-Command "ssh-copy-id" -ErrorAction SilentlyContinue
    if ($cmd) {
        $candidatePaths += $cmd.Source
    }

    foreach ($path in ($candidatePaths | Select-Object -Unique)) {
        try {
            $output = & $path -v 2>$null
            if ($output -match '(\d+\.\d+\.\d+)') {
                return [version]$Matches[1]
            }
        }
        catch {
            # ignore and try next candidate
        }
    }

    return $null
}

# Default install dir: %LOCALAPPDATA%\Programs\shh-copy-id
if (-not $InstallDir) {
    if ($env:LOCALAPPDATA) {
        $InstallDir = Join-Path $env:LOCALAPPDATA ("Programs\" + $FolderName)
    }
    else {
        # Fallback: %USERPROFILE%\shh-copy-id
        $InstallDir = Join-Path $env:USERPROFILE $FolderName
    }
}

Write-Host "Installing shh-copy-id to: $InstallDir" -ForegroundColor Cyan

$ExePath = Join-Path $InstallDir $AppName

# Check versions
$latestVersion    = Get-LatestGithubVersion -ApiUrl $GitHubApiLatestUrl
$installedVersion = Get-InstalledSshCopyIdVersion -LocalExePath $ExePath

if ($installedVersion -and $latestVersion) {
    if ($installedVersion -ge $latestVersion) {
        Write-Host "ssh-copy-id is already up to date (installed: $installedVersion, latest: $latestVersion)." -ForegroundColor Green
        return
    }
    else {
        Write-Host "Updating ssh-copy-id from $installedVersion to $latestVersion..." -ForegroundColor Cyan
    }
}
elseif ($latestVersion) {
    Write-Host "Installing ssh-copy-id version $latestVersion..." -ForegroundColor Cyan
}
else {
    Write-Host "Installing latest ssh-copy-id (could not determine version from GitHub API)." -ForegroundColor Cyan
}

# Create install directory (if needed)
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
}

# Download executable
Write-Host "Downloading latest shh-copy-id from GitHub..." -ForegroundColor Cyan

try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ExePath -UseBasicParsing
}
catch {
    Write-Error "Failed to download shh-copy-id from $DownloadUrl"
    throw
}

Write-Host "Downloaded to $ExePath" -ForegroundColor Green

# Optionally add to PATH
if (-not $NoModifyPath) {
    $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")

    $paths = $currentUserPath -split ";" | Where-Object { $_ -ne "" }

    if ($paths -notcontains $InstallDir) {
        $newPath = if ($currentUserPath) {
            "$InstallDir;$currentUserPath"
        }
        else {
            $InstallDir
        }

        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "Added '$InstallDir' to your user PATH." -ForegroundColor Green
        Write-Host "You may need to open a new terminal for changes to take effect." -ForegroundColor Yellow
    }
    else {
        Write-Host "Install directory is already on your PATH." -ForegroundColor DarkYellow
    }
}
else {
    Write-Host "Skipping PATH modification because -NoModifyPath was provided." -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "Done! You should now be able to run:" -ForegroundColor Green
Write-Host "    ssh-copy-id user@host" -ForegroundColor Green
