@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
cd /d %~dp0
cls
color 0B
SETLOCAL enabledelayedexpansion
title CLI
if exist "%userprofile%\onedrive" (
    echo do you want to set it to onedrive, or no one drive? Y/N
    set /p "yorn=>> "
    if "!yorn!" == "y" (
    set "defaultfileloc=!userprofile!\onedrive\desktop"
    echo The default file location is set as "!userprofile!\onedrive\desktop"
    timeout /t 1 >nul
    )
    if "!yorn!" == "n" (
    set "defaultfileloc=!userprofile!\desktop"
    echo The default file location is set as "!userprofile!\desktop"
    timeout /t 1 >nul
    )   
) else (
    set "defaultfileloc=!userprofile!\desktop"
    echo The default file location is set as "!userprofile!\desktop"
    timeout /t 1 >nul
)
if exist "%defaultfileloc%\%username%_PC_INFO.txt" (
    echo A file already exists in the default location. Do you want to overwrite it? Y/N
    set /p "overwrite=>> "
    if "!overwrite!" == "y" (
        echo Overwriting the file...
        del /q "%defaultfileloc%\%username%_PC_INFO.txt"
        if "!errorlevel!"=="0" (
            echo File deleted successfully.
        ) else (
            echo Failed to delete the file. Please check permissions or if the file is in use.
        )
        timeout /t 1 >nul
    ) else (
        echo The file will not be overwritten. Exiting the script.
        timeout /t 1 >nul
        goto eq432
    )
)
:eq432
echo.
echo Where do you want the file?
echo Press enter for the default
echo Default is desktop
set /p "userpath=>> "
if "!userpath!"=="" (
    set "targetloc=!defaultfileloc!"
) else (
    set "targetloc=!userpath!"
)
if not exist "%targetloc%" (
    mkdir "%targetloc%"
)
echo PC INFO REPORT >> "%targetloc%\%username%_PC_INFO.txt"
echo made for %username% on %computername% at %time% on %date% >> "%targetloc%\%username%_PC_INFO.txt"
echo. >> "%targetloc%\%username%_PC_INFO.txt"
echo ^<------NETWORK INFO------^> >> "%targetloc%\%username%_PC_INFO.txt"
ipconfig /all >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "try { (Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 5) } catch { 'Unable to retrieve public IP (no internet or blocked)' }" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-DnsClientCache | Select Entry,Data,TTL | Format-Table -AutoSize | Out-String -Width 200" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-NetTCPConnection | Select LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess | Format-Table -AutoSize | Out-String -Width 200" >> "%targetloc%\%username%_PC_INFO.txt"
echo ^<------NETWORK END------^> >> "%targetloc%\%username%_PC_INFO.txt"
echo. >> "%targetloc%\%username%_PC_INFO.txt"
echo ^<------PC INFO------^> >> "%targetloc%\%username%_PC_INFO.txt"
systeminfo >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-CimInstance Win32_ComputerSystem | Select Manufacturer,Model,Name | Format-List" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-CimInstance Win32_Bios | Select SerialNumber | Format-List" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-CimInstance Win32_LogicalDisk | Select DeviceID,VolumeName,Size,FreeSpace | Format-Table -AutoSize | Out-String -Width 200" >> "%targetloc%\%username%_PC_INFO.txt"
echo ^<------PC END------^> >> "%targetloc%\%username%_PC_INFO.txt"
echo. >> "%targetloc%\%username%_PC_INFO.txt"
echo ^<------HARDWARE INFO------^> >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-CimInstance Win32_Processor | Select Name,NumberOfCores,MaxClockSpeed | Format-List" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-CimInstance Win32_PhysicalMemory | Select Manufacturer,Capacity,Speed | Format-Table -AutoSize | Out-String -Width 200" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-CimInstance Win32_VideoController | Select Name,AdapterRAM | Format-List" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID | Select @{N='Monitor';E={($_.UserFriendlyName -ne 0 | ForEach-Object {[char]$_}) -join ''}}, @{N='Serial';E={($_.SerialNumberID -ne 0 | ForEach-Object {[char]$_}) -join ''}} | Format-Table -AutoSize" >> "%targetloc%\%username%_PC_INFO.txt"
echo ^<------HARDWARE END------^> >> "%targetloc%\%username%_PC_INFO.txt"
echo. >> "%targetloc%\%username%_PC_INFO.txt"
echo ^<------PC HEALTH------^> >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "$os=Get-CimInstance Win32_OperatingSystem; $up=(Get-Date)-$os.LastBootUpTime; \"Last Boot: $($os.LastBootUpTime)`nUptime: $($up.Days)d $($up.Hours)h $($up.Minutes)m\"" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') { 'Reboot Required: YES' } else { 'Reboot Required: NO' }" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-WinEvent -FilterHashtable @{LogName='System';Level=2;StartTime=(Get-Date).AddHours(-24)} -ErrorAction SilentlyContinue | Select TimeCreated,ProviderName,Id,Message | Format-List" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-HotFix | Sort-Object InstalledOn -Descending | Select -First 10 HotFixID,Description,InstalledOn | Format-Table -AutoSize | Out-String -Width 200" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-PhysicalDisk | Select FriendlyName,MediaType,HealthStatus,OperationalStatus | Format-Table -AutoSize | Out-String -Width 200" >> "%targetloc%\%username%_PC_INFO.txt
echo ^<------PC HEALTH END------^> >> "%targetloc%\%username%_PC_INFO.txt"
echo. >> "%targetloc%\%username%_PC_INFO.txt"
echo ^<------WINDOWS SECURITY------^> >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-MpComputerStatus | Select AntivirusEnabled,AntivirusSignatureLastUpdated,RealTimeProtectionEnabled,QuickScanAge,FullScanAge | Format-List" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-NetFirewallProfile | Select Name,Enabled | Format-Table -AutoSize" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-BitLockerVolume | Select MountPoint,VolumeStatus,ProtectionStatus | Format-Table -AutoSize" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "cscript //nologo $env:windir\system32\slmgr.vbs /dli" >> "%targetloc%\%username%_PC_INFO.txt"
echo ^<------WINDOWS SECURITY END------^> >> "%targetloc%\%username%_PC_INFO.txt"
echo. >> "%targetloc%\%username%_PC_INFO.txt"
echo ^<------SOFTWARE STUFF------^> >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | Where-Object {$_.DisplayName} | Select DisplayName,DisplayVersion,Publisher | Sort DisplayName | Format-Table -AutoSize | Out-String -Width 200" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-WindowsOptionalFeature -Online | Where-Object {$_.State -eq 'Enabled'} | Select FeatureName | Format-Table -AutoSize" >> "%targetloc%\%username%_PC_INFO.txt"
powershell -command "Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name Version,Release -ErrorAction SilentlyContinue | Where {$_.PSChildName -match '^(?!S)\p{L}'} | Select PSChildName,Version,Release | Format-Table -AutoSize" >> "%targetloc%\%username%_PC_INFO.txt"
echo ^<------SOFTWARE END------^> >> "%targetloc%\%username%_PC_INFO.txt"
choice /c yn /m "Open the file now"
if !errorlevel! == 1 start "" notepad "%targetloc%\%username%_PC_INFO.txt"
cls
echo last boot time was
systeminfo | find "System Boot Time"
echo.
timeout /t 3 >nul
exit
