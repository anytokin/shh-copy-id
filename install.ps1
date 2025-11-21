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

# Where to download from: latest GitHub release asset
$DownloadUrl = "https://github.com/anytokin/shh-copy-id/releases/latest/download/ssh-copy-id.exe"

$AppName    = "ssh-copy-id.exe"
$FolderName = "shh-copy-id"

# Default install dir: %LOCALAPPDATA%\Programs\shh-copy-id
if (-not $InstallDir) {
    if ($env:LOCALAPPDATA) {
        $InstallDir = Join-Path $env:LOCALAPPDATA ("Programs\" + $FolderName)
    } else {
        # Fallback: %USERPROFILE%\shh-copy-id
        $InstallDir = Join-Path $env:USERPROFILE $FolderName
    }
}

Write-Host "Installing shh-copy-id to: $InstallDir" -ForegroundColor Cyan

# Create install directory

if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
}

$ExePath = Join-Path $InstallDir $AppName

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
        } else {
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
