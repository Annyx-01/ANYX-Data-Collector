@echo off
title USB Data Launcher
color 0A

:: Get USB drive
set "usbDrive=%~d0"
set "CONFIG_FILE=%usbDrive%\config.ini"
set "SHOW_MODE=NO"

:: Read config for show mode
if exist "%CONFIG_FILE%" (
    for /f "tokens=2 delims==" %%a in ('type "%CONFIG_FILE%" ^| find "SHOW_PROGRESS"') do set "SHOW_MODE=%%a"
)

:: Launch based on mode
if /i "%SHOW_MODE%"=="YES" (
    call file.bat
    echo.
    echo Press any key to exit...
    pause >nul
) else (
    wscript "%CD%\visible.vbs" file.bat
)

exit /b 0