@echo off
rem MCC.BAT
SETLOCAL
set MCCARCH=UNSET
set MCCPATH=%~dp0
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set MCCARCH=win64
) else if "%PROCESSOR_ARCHITEW6432%" == "AMD64" (
  set MCCARCH=win64
)
if %MCCARCH%==win64 (
  if not exist "%MCCPATH%win64" (
    @echo "%MCCPATH%win64" does not exist
    set errorlevel=1
    goto DONE
  )
)
if %MCCARCH%==UNSET (
  @echo Unsupported architecture
  set errorlevel=1
  goto DONE
)
set PATH="%MCCPATH%%MCCARCH%";%PATH%
"%MCCPATH%%MCCARCH%\mcc" %*
:DONE
ENDLOCAL
"%SystemRoot%\system32\cmd" /c exit %errorlevel%
