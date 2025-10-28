@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging !
set _DEBUG=0

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0

call :env
if not %_EXITCODE%==0 goto end

@rem #########################################################################
@rem ## Main

set "_PATH=%PATH%"
set "PATH=%PATH%;%ERLANG_HOME%\bin"

if %_DEBUG%==1 echo %_DEBUG_LABEL% "%_ESCRIPT_CMD%" "%_ELVIS_SCRIPT%" %* 1>&2

call "%_ESCRIPT_CMD%" "%_ELVIS_SCRIPT%" %*
if not %ERRORLEVEL%==0 (
    set "PATH=%_PATH%"
    echo %_ERROR_LABEL% Failed to execute Elvis script 1>&2
    set _EXITCODE=1
    goto end
)
set "PATH=%_PATH%"
goto end

@rem #########################################################################
@rem ## Subroutines

:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"

set _DEBUG_LABEL=[%_BASENAME%]
set _ERROR_LABEL=Error:
set _WARNING_LABEL=Warning:

set _ESCRIPT_CMD=
if not exist "%ERLANG_HOME%\bin\escript.exe" (
    echo %_ERROR_LABEL% Escript executable not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_ESCRIPT_CMD=%ERLANG_HOME%\bin\escript.exe"

set _ELVIS_SCRIPT=
if not exist "%~dp0\elvis" (
    echo %_ERROR_LABEL% Elvis script not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_ELVIS_SCRIPT=%~dp0\elvis"
goto :eof

@rem #########################################################################
@rem ## Cleanup

:end
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
