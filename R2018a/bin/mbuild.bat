@echo off
rem MBUILD.BAT
rem Compile and link tool 

rem display Help

SETLOCAL
set helpFlag=%1

if "%helpFlag%"=="" goto :displayHelp
if "%helpFlag%"=="-h" goto :displayHelp
if "%helpFlag%"=="-help" goto :displayHelp
if "%helpFlag%"=="-getWin10SDKVersion" goto :getWin10SDKVersion

ENDLOCAL

rem Switch between creating a shared library, executable or COM components.
for %%i in (%1 %2 %3) do (
if "%%i"=="mbuild" goto :buildLibrary
if "%%i"=="mbuild_com" goto :buildCOM
)

goto :buildEXE

:buildLibrary
:buildCOM

"%~dp0\win64\mex.exe" %*
goto DONE  

:buildEXE
"%~dp0\win64\mex.exe" -client mbuild %* 
goto DONE

:displayHelp
"%~dp0\win64\mbuildHelp.exe"
goto DONE

:getWin10SDKVersion
@REM Gets the Windows 10 SDK version for include directory
@REM *** For internal use only. ***

@REM Redirect the error to NUL and leave output as is for MEX
@call :GetWin10SdkVerHelper HKLM\SOFTWARE\Wow6432Node 2> nul
@if errorlevel 1 call :GetWin10SdkVerHelper HKCU\SOFTWARE\Wow6432Node 2> nul
@if errorlevel 1 call :GetWin10SdkVerHelper HKLM\SOFTWARE 2> nul
@if errorlevel 1 call :GetWin10SdkVerHelper HKCU\SOFTWARE 2> nul
@if errorlevel 1 exit /B 1
@exit /B 0

:GetWin10SdkVerHelper

@REM Get Windows 10 SDK installation folder
@for /F "tokens=1,2*" %%i in ('^""%SystemRoot%\system32\reg.exe" query "%1\Microsoft\Microsoft SDKs\Windows\v10.0" /v "InstallationFolder"^"') DO (
    @if "%%i"=="InstallationFolder" (
        @SET WindowsSdkDir=%%k
    )
)

@REM Get Windows 10 SDK Version number which will be used to determine 
@REM INCLUDE directories in MinGW's options file
@set foundSDK=0
@setlocal enableDelayedExpansion
@if not "%WindowsSdkDir%"=="" @for /f %%i IN ('dir "%WindowsSdkDir%include\" /b /ad-h /on') DO (
    @REM Skip if Windows.h is not found in %%i\um.
    @if EXIST "%WindowsSdkDir%include\%%i\um\Windows.h" (
        @set result=%%i
        @if "!result:~0,3!"=="10." (
            @set SDK=!result!
            @set foundSDK=1
        )
    )
)

@if "%foundSDK%"=="0" (
  @set WindowsSdkDir=
  @exit /B 1
)
@endlocal & echo %SDK%
@exit /B 0

:DONE
"%SystemRoot%\system32\cmd" /c exit %errorlevel%
