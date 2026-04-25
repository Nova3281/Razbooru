@echo off
setlocal

:: Create or clear the log file
set "LOG_FILE=%~dp0lastrun.log"
echo Starting Razbooru Launcher... > "%LOG_FILE%"
echo ---------------------------------------- >> "%LOG_FILE%"

:: Set the required version of anyOS here
set "REQUIRED_ANYOS_VERSION=1.0"
set "DOWNLOAD_LINK=https://github.com/Kuroahna/Zenbooru"

set "RAZ_PATH=%~dp0"
set "RAZ_PATH=%RAZ_PATH:\=/%"

echo Checking anyOS extension version...
echo Checking anyOS extension version... >> "%LOG_FILE%"

:: Use PowerShell to read manifest.json and compare the version
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "try { " ^
  "  $manifestPath = '%~dp0anyOS\manifest.json'; " ^
  "  if (-not (Test-Path $manifestPath)) { " ^
  "    Write-Host 'ERROR: anyOS extension not found!' -ForegroundColor Red; " ^
  "    Write-Host 'Please download it from: %DOWNLOAD_LINK%' -ForegroundColor Yellow; " ^
  "    exit 1; " ^
  "  } " ^
  "  $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json; " ^
  "  if ($manifest.version -ne '%REQUIRED_ANYOS_VERSION%') { " ^
  "    Write-Host ('WARNING: anyOS is out of date! (Found v' + $manifest.version + ', Expected v%REQUIRED_ANYOS_VERSION%)') -ForegroundColor Red; " ^
  "    Write-Host 'Please download the latest version from: %DOWNLOAD_LINK%' -ForegroundColor Yellow; " ^
  "    exit 1; " ^
  "  } " ^
  "} catch { Write-Error $_.Exception.Message; exit 1; }" 2>> "%LOG_FILE%"

if %errorlevel% neq 0 (
    echo [ERROR] Version check failed. See console or log for details. >> "%LOG_FILE%"
    pause
    exit /b
)

echo Configuring Chrome Profile to always ask for save location...
echo Configuring Chrome Profile... >> "%LOG_FILE%"

:: Use PowerShell to inject the download prompt setting directly into Chrome's brain
:: Depth is increased to 100 to prevent truncating massive profile configurations
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "try { " ^
  "  $prefDir = '%~dp0raz_profile\Default'; " ^
  "  $prefPath = Join-Path $prefDir 'Preferences'; " ^
  "  if (-not (Test-Path $prefDir)) { New-Item -ItemType Directory -Force -Path $prefDir | Out-Null; } " ^
  "  if (-not (Test-Path $prefPath)) { " ^
  "    Set-Content -Path $prefPath -Value '{\"download\":{\"prompt_for_download\":true}}'; " ^
  "  } else { " ^
  "    $prefs = Get-Content $prefPath -Raw | ConvertFrom-Json; " ^
  "    if (-not $prefs.download) { $prefs | Add-Member -Name 'download' -MemberType NoteProperty -Value @{} } " ^
  "    $prefs.download.prompt_for_download = $true; " ^
  "    $prefs | ConvertTo-Json -Depth 100 -Compress | Set-Content $prefPath; " ^
  "  } " ^
  "} catch { " ^
  "  Write-Error ('Preferences injection error: ' + $_.Exception.Message); " ^
  "}" 2>> "%LOG_FILE%"

echo Launching Razbooru with 2026 Security Bypass...
echo Launching Chrome... >> "%LOG_FILE%"

powershell -ExecutionPolicy Bypass -Command ^
"Start-Process 'chrome.exe' -ArgumentList ^
'--app=file:///%RAZ_PATH%index.html', ^
'--load-extension=%~dp0anyOS', ^
'--user-data-dir=%~dp0raz_profile', ^
'--disable-web-security', ^
'--disable-site-isolation-trials', ^
'--allow-file-access-from-files'" 2>> "%LOG_FILE%"

echo Launcher finished successfully. >> "%LOG_FILE%"