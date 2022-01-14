@echo off
:: Version 1.0.2
::     .AUTHORS
::        steen_pedersen@ - 2022
::
::    .LICENSE
::        MIT
::
:: The Launcher for the PowerShell script to be executed by EEDK package
:: Make sure that both the CMD file and PS1 file is included in the EEDK package
:: Use the 
::
pushd "%~dp0"
SET SRCDIR=
for /f "delims=" %%a in ('cd') do @set SRCDIR=%%a
setlocal ENABLEEXTENSIONS
setlocal EnableDelayedExpansion

:: Set the ISO Date to yyyymmddhhmmss using wmic
:: this is not possible using %date% as the format can be different based on date settings
for /F "tokens=2 delims==." %%I in ('wmic os get localdatetime /VALUE') do set "l_MyDate=%%I"
set ISO_DATE_TIME2=%l_MyDate:~0,14%

for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
::set ISO_DATE_TIME=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
set ISO_DATE_TIME=!ldt:~0,4!-!ldt:~4,2!-!ldt:~6,2! !ldt:~8,2!:!ldt:~10,2!:!ldt:~12,6!

set l_EEDK_Debug_log=%temp%\EEDK_Debug.log
set l_PowerShell_script=EEDK_ps1_template.ps1

set cmdstr=%*
echo %ISO_DATE_TIME% EEDK start path: %SRCDIR%>>%l_EEDK_Debug_log%
echo %ISO_DATE_TIME% EEDK arguments : !cmdstr!>>%l_EEDK_Debug_log%

:: Check execution context 32 or 64 bit - using sysnative
if exist %windir%\sysnative\WindowsPowerShell\v1.0\powershell.exe  (
	goto context32bit
) else (
    goto context64bit
)

:context64bit
echo %ISO_DATE_TIME% EEDK Context   : ---- Context 64 bit ------- >>%l_EEDK_Debug_log%
set l_powershell_path=%windir%\System32\WindowsPowerShell\v1.0\powershell.exe
::%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File %l_PowerShell_script% %cmdstr% >>%l_EEDK_Debug_log% 
goto start_PowerShell


:context32bit
echo %ISO_DATE_TIME% EEDK arguments : ---- Context 32 bit ------- >>%l_EEDK_Debug_log%
set l_powershell_path=%windir%\sysnative\WindowsPowerShell\v1.0\powershell.exe
::%windir%\sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File %l_PowerShell_script% %cmdstr% >>%l_EEDK_Debug_log% 
goto start_PowerShell

:start_PowerShell
echo %ISO_DATE_TIME% EEDK starting PowerShell Script: %l_PowerShell_script% %cmdstr% >>%l_EEDK_Debug_log%
%l_powershell_path% -ExecutionPolicy Bypass -File %l_PowerShell_script% %cmdstr% >>%l_EEDK_Debug_log% 2>&1

IF !ERRORLEVEL! NEQ 0 ( 
   echo %ISO_DATE_TIME% EEDK Error running PowerShell Errorlevel !ERRORLEVEL! >>%l_EEDK_Debug_log%
)else (
echo %ISO_DATE_TIME% EEDK Done running PowerShell Errorlevel !ERRORLEVEL! >>%l_EEDK_Debug_log%
)


:end_of_file
:: Exit and pass proper exit to agent
Exit /B !ERRORLEVEL!
