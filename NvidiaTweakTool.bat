@echo off
SETLOCAL EnableDelayedExpansion
SET version=1.0
title NvidiaTweakTool
chcp 65000
color a
cls
goto startmenu

:startmenu
@echo off
color a
mode con cols=103 lines=28
cls
echo.
echo.
echo.                                            NvidiaTweakTool
echo.                                            Wellcome: %username%
echo.                                  ===================================
echo.
echo.
echo.          1:Disable Nvidia Telemetry (Admin)                7:Disable NVIDIA HD Audio Timeouts
echo.          2:Opt out of nvidia telemtry 
echo.          3:Remove Nvidia telemetry                         
echo.          4:Remove Nvidia telemetry packages               
echo.                                                            8:Disable HDCP
echo.                                                            9:Enable HDCP 
echo.          				                         
echo.          5:Remove Nvidia leftover files                    10:Enable MSI Mode                                                           
echo.                                                                      
echo.          6:Optimize Nvidia tasks/services                  11:Nvidia Tweaks (HoneCtrl)           
echo.      
echo.                                                X:exit
echo.
echo.
echo.                                  ===================================
SET /P AREYOUSURE=
IF %AREYOUSURE%==1 GOTO distele
IF %AREYOUSURE%==2 GOTO opttele
IF %AREYOUSURE%==3 GOTO retele
IF %AREYOUSURE%==4 GOTO telepack
IF %AREYOUSURE%==5 GOTO releft
IF %AREYOUSURE%==6 GOTO opsert
IF %AREYOUSURE%==7 GOTO disautimeout
IF %AREYOUSURE%==8 GOTO disHDCP
IF %AREYOUSURE%==9 GOTO enHDCP
IF %AREYOUSURE%==10 GOTO msimode
IF %AREYOUSURE%==11 GOTO Hone
IF %AREYOUSURE%==X GOTO ext
IF %AREYOUSURE%==x GOTO ext
goto startmenu



:ext
exit


:distele
cls
reg add "HKCU\Software\HoneCTRL" /v NVTTweaks /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\Startup\SendTelemetryData" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d 0 /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f
schtasks /change /disable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
schtasks /change /disable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
schtasks /change /disable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
schtasks /change /disable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
cls
echo.
Echo.2
timeout /t 1 /nobreak > nul
Echo.1
timeout /t 1 /nobreak > nul
goto startmenu


:opttele
cls
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d 0 /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f
echo.
Echo.2
timeout /t 1 /nobreak > nul
Echo.1
timeout /t 1 /nobreak > nul
goto startmenu


:retele
cls
@echo off

set cwd=%cd%
set batchpath=%~dp0

:: set executable
set dir=NvTelemetry
if exist "%cwd%\%dir%\" (
    echo [33m[removing dir][0m %dir%
    RMDIR /S /Q "%cwd%\%dir%" >NUL  2>NUL
)

set file=NvContainer\NvContainerTelemetryApi.nvi
if exist "%cwd%\%file%" (
    echo [33m[removing file][0m %file%
    DEL /Q /S "%cwd%\%file%" >NUL  2>NUL
)

set file=NvContainer\x86\NvContainerTelemetryApi.dll
if exist "%cwd%\%file%" (
    echo [33m[removing file][0m %file%
    DEL /Q /S "%cwd%\%file%" >NUL  2>NUL
)

set file=NvContainer\x86_64\NvContainerTelemetryApi.dll
if exist "%cwd%\%file%" (
    echo [33m[removing file][0m %file%
    DEL /Q /S "%cwd%\%file%" >NUL  2>NUL
)

set file=Update.Core\UpdateCore.nvi
if exist "%cwd%\%file%" (
    echo [33m[updating file][0m %file%
    %xmlstarlet_exe% ed --inplace --delete "/nvi/manifest/file[starts-with(@name,'NvTm') and contains(@name,'.exe')]" "%cwd%\%file%"
    %xmlstarlet_exe% ed --inplace --delete "/nvi/phases/standard[@phase='copyx86BackendBinaries']/copyFile[starts-with(@target,'NvTm') and contains(@target,'.exe')]" "%cwd%\%file%"
    %xmlstarlet_exe% ed --inplace --delete "/nvi/phases/standard[starts-with(@phase,'scheduleNvTm') and scheduleTask[@action='create']]" "%cwd%\%file%"
)

set file=Display.Driver\DisplayDriver.nvi
if exist "%cwd%\%file%" (
    echo [33m[updating file][0m %file%
    %xmlstarlet_exe% ed --inplace --update "/nvi/properties/bool[@name='UsesNvTelemetry']/@value" --value "false" "%cwd%\%file%"
    %xmlstarlet_exe% ed --inplace --update "//exe[contains(@condition,'Global:EnableTelemetry')]/arg[contains(@value,'-enableTelemetry:true')]" --value "-enableTelemetry:false" "%cwd%\%file%"
)

set file=DisplayDriverCrashAnalyzer\DisplayDriverCrashAnalyzer.nvi
if exist "%cwd%\%file%" (
    echo [33m[updating file][0m %file%
    %xmlstarlet_exe% ed --inplace --update "/nvi/properties/bool[@name='UsesNvTelemetry']/@value" --value "false" "%cwd%\%file%"
)

set file=GFExperience.NvStreamSrv\GFExperience.NvStreamSrv.nvi
if exist "%cwd%\%file%" (
    echo [33m[updating file][0m %file%
    %xmlstarlet_exe% ed --inplace --update "/nvi/properties/bool[@name='UsesNvTelemetry']/@value" --value "false" "%cwd%\%file%"
)

set file=nodejs\nodejs.nvi
if exist "%cwd%\%file%" (
    echo [33m[updating file][0m %file%
    %xmlstarlet_exe% ed --inplace --update "/nvi/properties/bool[@name='UsesNvTelemetry']/@value" --value "false" "%cwd%\%file%"
)

set file=NvBackend\NvBackend.nvi
if exist "%cwd%\%file%" (
    echo [33m[updating file][0m %file%
    %xmlstarlet_exe% ed --inplace --update "/nvi/properties/bool[@name='UsesNvTelemetry']/@value" --value "false" "%cwd%\%file%"
    %xmlstarlet_exe% ed --inplace --delete "/nvi/dependencies/package[@package='NvTelemetry']" "%cwd%\%file%"
)

set file=NvCamera\NvCamera.nvi
if exist "%cwd%\%file%" (
    echo [33m[updating file][0m %file%
    %xmlstarlet_exe% ed --inplace --update "/nvi/properties/bool[@name='UsesNvTelemetry']/@value" --value "false" "%cwd%\%file%"
)

set file=NvAbHub\NvAbHub.nvi
if exist "%cwd%\%file%" (
    echo [33m[updating file][0m %file%
    %xmlstarlet_exe% ed --inplace --delete "/nvi/dependencies/package[@package='NvTelemetry']" "%cwd%\%file%"
)

echo.
Echo.2
timeout /t 1 /nobreak > nul
Echo.1
timeout /t 1 /nobreak > nul
goto startmenu


:telepack
cls
if exist "%ProgramFiles%\NVIDIA Corporation\Installer2\InstallerCore\NVI2.DLL" (
    rundll32 "%PROGRAMFILES%\NVIDIA Corporation\Installer2\InstallerCore\NVI2.DLL",UninstallPackage NvTelemetryContainer
    rundll32 "%PROGRAMFILES%\NVIDIA Corporation\Installer2\InstallerCore\NVI2.DLL",UninstallPackage NvTelemetry
)
echo.
Echo.2
timeout /t 1 /nobreak > nul
Echo.1
timeout /t 1 /nobreak > nul
goto startmenu


:releft
cls
del /s %systemdrive%\System32\DriverStore\FileRepository\NvTelemetry*.dll
rmdir /s /q "%ProgramFiles%\NVIDIA Corporation\NvTelemetry" 2
rmdir /s /q "%ProgramFiles(x86)%\NVIDIA Corporation\NvTelemetry" 2
echo.
Echo.2
timeout /t 1 /nobreak > nul
Echo.1
timeout /t 1 /nobreak > nul
goto startmenu


:opsert
cls
cls
schtasks /change /TN NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /DISABLE
schtasks /change /TN NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /DISABLE
schtasks /change /TN NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /DISABLE
)
echo.
Echo.2
timeout /t 1 /nobreak > nul
Echo.1
timeout /t 1 /nobreak > nul
goto startmenu


:disautimeout
cls
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e96c-e325-11ce-bfc1-08002be10318}\0000\PowerSettings" /v "ConservationIdleTime" /t REG_BINARY /d 00000000
yes
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e96c-e325-11ce-bfc1-08002be10318}\0000\PowerSettings" /v "IdlePowerState" /t REG_BINARY /d 00000000
yes
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e96c-e325-11ce-bfc1-08002be10318}\0000\PowerSettings" /v "PerformanceIdleTime" /t REG_BINARY /d 00000000
yes
cls
echo.
Echo.2
timeout /t 1 /nobreak > nul
Echo.1
timeout /t 1 /nobreak > nul
goto startmenu


:disHDCP
cls
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "1" /f
cls
echo.
Echo.2
timeout /t 1 /nobreak > nul
Echo.1
timeout /t 1 /nobreak > nul
goto startmenu

:enHDCP
cls
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "0" /f
cls
echo.
Echo.2
timeout /t 1 /nobreak > nul
Echo.1
timeout /t 1 /nobreak > nul
goto startmenu

:Hone
cls
	reg add "HKCU\Software\HoneCTRL" /v "NvidiaTweaks" /f
	rem Nvidia Reg
	reg add "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /t Reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t Reg_DWORD /d "0" /f
	rem Unrestricted Clocks
	cd "%SYSTEMDRIVE%\Program Files\NVIDIA Corporation\NVSMI\"
	nvidia-smi -acp UNRESTRICTED
	nvidia-smi -acp DEFAULT
	rem Nvidia Registry Key
	for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		rem Disalbe Tiled Display
		reg add "%%a" /v "EnableTiledDisplay" /t REG_DWORD /d "0" /f
		rem Disable TCC
		reg add "%%a" /v "TCCSupported" /t REG_DWORD /d "0" /f
	)
	rem Silk Smoothness Option
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v "EnableRID61684" /t REG_DWORD /d "1" /f
start https://github.com/luke-beep
echo. Support this guy who made this tweaks!
Pause
echo.
Echo.2
timeout /t 1 /nobreak > nul
Echo.1
timeout /t 1 /nobreak > nul
goto startmenu


:msimode
cls
	reg add "HKCU\Software\HoneCTRL" /v "MSIModeTweaks" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
cls
echo.
Echo.2
timeout /t 1 /nobreak > nul
Echo.1
timeout /t 1 /nobreak > nul
goto startmenu

