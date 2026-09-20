@echo off
setlocal
title Nettoyage Midnight Companion

if /I "%~1"=="--worker" (
    cd /d "%TEMP%"
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Cleanup-MidnightCompanion.ps1" -Apply
    echo.
    pause
    exit /b %errorlevel%
)

echo Recherche des anciennes copies de Midnight Companion...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Cleanup-MidnightCompanion.ps1"
if errorlevel 1 (
    echo.
    echo Fermez completement WoW, puis relancez ce fichier.
    pause
    exit /b 1
)

echo.
choice /C ON /N /M "Supprimer les copies listees ? [O]ui/[N]on : "
if errorlevel 2 (
    echo Aucun fichier supprime.
    pause
    exit /b 0
)

echo.
set "workerDir=%TEMP%\MidnightCompanion-Cleanup-%RANDOM%"
mkdir "%workerDir%" >nul 2>&1
copy /Y "%~f0" "%workerDir%\Nettoyer-MidnightCompanion.cmd" >nul
copy /Y "%~dp0Cleanup-MidnightCompanion.ps1" "%workerDir%\Cleanup-MidnightCompanion.ps1" >nul
start "" "%workerDir%\Nettoyer-MidnightCompanion.cmd" --worker
exit /b 0
