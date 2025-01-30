@echo off
setlocal enabledelayedexpansion

:: Define variables
set USER1=trainee
set USER2=simspace
set PASSWORD=simspace1

:: Check if USER2 already exists
net user %USER2% >nul 2>&1
if %errorlevel% neq 0 (
    echo Creating new user %USER2%...
    net user %USER2% %PASSWORD% /add /y
    net localgroup Administrators %USER2% /add
) else (
    echo %USER2% already exists.
)

:: Copy USER1's Desktop files to USER2's Desktop
set USER1_DESKTOP=C:\Users\%USER1%\Desktop
set USER2_DESKTOP=C:\Users\%USER2%\Desktop

if exist "%USER1_DESKTOP%" (
    echo Copying files from %USER1_DESKTOP% to %USER2_DESKTOP%...
    xcopy "%USER1_DESKTOP%\*" "%USER2_DESKTOP%\" /E /C /I /H /R /Y
) else (
    echo USER1 desktop not found.
)

:: Set ownership and permissions for USER2
echo Taking ownership of copied files...
takeown /F "%USER2_DESKTOP%" /R /D Y
icacls "%USER2_DESKTOP%" /grant %USER2%:F /T /C /Q

:: Remove USER1
net user %USER1% /delete
echo %USER1% has been removed from the system.

echo Operation completed.
pause
