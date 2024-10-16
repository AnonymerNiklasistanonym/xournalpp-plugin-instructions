#!/usr/bin/env pwsh

$localAppData = [System.Environment]::GetFolderPath('LocalApplicationData')
$programFiles = [System.Environment]::GetFolderPath('ProgramFiles')

$PLUGIN_DIR = Join-Path $localAppData "xournalpp\plugins"
$ICON_DIR = Join-Path $programFiles "Xournal++\share\icons"

$LOCAL_EXAMPLE_PLUGIN_DIRS = Get-ChildItem -Directory | ForEach-Object { $_.Name }
$LOCAL_EXAMPLE_PLUGIN_ICONS = Get-ChildItem -Recurse -Filter *.svg | ForEach-Object { $_.FullName }

foreach ($LOCAL_EXAMPLE_PLUGIN_DIR in $LOCAL_EXAMPLE_PLUGIN_DIRS) {
    $EXAMPLE_PLUGIN_DIR = Join-Path $PLUGIN_DIR $LOCAL_EXAMPLE_PLUGIN_DIR
    Write-Host "Copy plugin $LOCAL_EXAMPLE_PLUGIN_DIR to $EXAMPLE_PLUGIN_DIR"
    Remove-Item -Recurse -Force $EXAMPLE_PLUGIN_DIR -ErrorAction SilentlyContinue
    Copy-Item -Recurse $LOCAL_EXAMPLE_PLUGIN_DIR $EXAMPLE_PLUGIN_DIR
}

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "The script is not running as Administrator. Can't copy icons..."
    exit
}

New-Item -ItemType Directory -Force -Path $ICON_DIR | Out-Null
foreach ($LOCAL_EXAMPLE_PLUGIN_ICON in $LOCAL_EXAMPLE_PLUGIN_ICONS) {
    $PLUGIN_NAME = [System.IO.Path]::GetFileName($LOCAL_EXAMPLE_PLUGIN_ICON)
    $EXAMPLE_PLUGIN_ICON_FILE = Join-Path $ICON_DIR $PLUGIN_NAME
    Write-Host "Copy plugin icon $LOCAL_EXAMPLE_PLUGIN_ICON to $EXAMPLE_PLUGIN_ICON_FILE"
    Remove-Item -Force $EXAMPLE_PLUGIN_ICON_FILE -ErrorAction SilentlyContinue
    Copy-Item $LOCAL_EXAMPLE_PLUGIN_ICON $EXAMPLE_PLUGIN_ICON_FILE
}
