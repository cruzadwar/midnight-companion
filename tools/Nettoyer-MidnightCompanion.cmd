@echo off
setlocal
title Nettoyage Midnight Companion

echo Recherche des anciennes copies de Midnight Companion...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Cleanup-MidnightCompanion.ps1"
if errorlevel 1 (
    echo.
    echo Fermez completement WoW et Battle.net, puis relancez ce fichier.
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
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Cleanup-MidnightCompanion.ps1" -Apply
echo.
pause
