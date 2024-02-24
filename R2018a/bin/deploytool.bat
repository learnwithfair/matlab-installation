@echo off
rem DEPLOYTOOL.BAT
SETLOCAL
set DEPLOYTOOLARCH=UNSET
set DEPLOYTOOLPATH=%~dp0
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set DEPLOYTOOLARCH=win64
) else if "%PROCESSOR_ARCHITEW6432%" == "AMD64" (
  set DEPLOYTOOLARCH=win64
)
if %DEPLOYTOOLARCH% == win64 (
  if not exist "%DEPLOYTOOLPATH%win64" (
    @echo "%DEPLOYTOOLPATH%win64" does not exist
    set errorlevel=1
    goto DONE
  )
)
set MWArgs=
:LOOP
if "%~1"=="" GOTO CONTINUE
if %1==-win32 (
  @echo -win32 is not supported
  set errorlevel=1
  goto DONE
) else (
  if not defined MWArgs (
    set MWArgs=%1
  ) else (
    set MWArgs=%MWArgs% %1
  )
)
shift
goto LOOP
:CONTINUE
if %DEPLOYTOOLARCH%==UNSET (
  @echo Unsupported architecture
  set errorlevel=1
  goto DONE
)
set PATH=%DEPLOYTOOLPATH%%DEPLOYTOOLARCH%;%PATH%
"%DEPLOYTOOLPATH%%DEPLOYTOOLARCH%\deploytool" %MWArgs%
:DONE
ENDLOCAL
"%SystemRoot%\system32\cmd" /c exit %errorlevel%
