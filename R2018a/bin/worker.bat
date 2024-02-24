@echo off
REM Wrapper around matlab.bat for the Distributed Computing Toolbox

REM Copyright 2006-2010 The MathWorks, Inc.
REM $Revision: 1.1.6.9 $   $Date: 2010/11/08 01:53:47 $

setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM This includes the trailing slash. Must use delayed expansion
REM within parentheses
set MATLAB_BIN_DIR=%~dp0

REM Default to calling distcomp_evaluate_filetask
set MATLAB_FUNCTION_TO_CALL=distcomp_evaluate_filetask

REM process argument list.  It is not possible to have both the -parallel and -ipc flags
if "%1"=="-ipc" (
    set MDCE_IPC=1
    shift
    goto parseIpcInputs
)
if "%1"=="-parallel" (
    set MDCE_PARALLEL=1
    shift
)

goto runWorker


:parseIpcInputs
REM Parse the remaining input arguments for running with IPC.  We expect the following:
REM worker.bat -ipc channelName
if "%1"=="" (
    goto badIpcArgsExit
) 
set PCT_IPC_CHANNEL_NAME=%1
shift

REM Generate the command to call pctRequestServer
set MATLAB_FUNCTION_TO_CALL=pctRequestServer('start', '%PCT_IPC_CHANNEL_NAME%')

:runWorker
REM query bin\matlab.exe - this will set MATLAB_ARCH and MATLAB_ERROR
REM JLM - Be very careful with quotes in the parenthesised expression. 
REM Any more quotes will likely break it. We have no idea what '(' in
REM the MATLAB_BIN_DIR will do.
REM 
REM Don't skip any lines of output from MATLAB -query, but redirect all 
REM stdout and stderr to null for all lines.
FOR /F "usebackq delims=" %%I IN (`""!MATLAB_BIN_DIR!MATLAB.exe"" -query -dmlworker -noFigureWindows %*`) DO (
    %%I>NUL 2>NUL
)

REM check that the query responded with all necessary information
if not defined MATLAB_ERROR  goto badEnvExit
if not "%MATLAB_ERROR%"=="0" goto errorExit
if not defined MATLAB_ARCH   goto badEnvExit

REM Call the correct MATLAB binary with the correct -r function
"!MATLAB_BIN_DIR!%MATLAB_ARCH%\MATLAB.exe" -dmlworker -noFigureWindows -r "%MATLAB_FUNCTION_TO_CALL%" %1 %2 %3 %4 %5 %6 %7 %8 %9

ENDLOCAL
exit %ERRORLEVEL%


:errorExit
echo Unable to launch MATLAB. 'MATLAB -query' returned error code: %MATLAB_ERROR%
exit %MATLAB_ERROR%

:badEnvExit
echo 'MATLAB -query' did not set all required environment variables
exit 10

:badIpcArgsExit
echo Incorrect syntax for launching worker with IPC
exit 20
