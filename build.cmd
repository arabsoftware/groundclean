@echo off
setlocal enabledelayedexpansion

rem ======================================================================
rem  GroundClean 1.1.3 - MSVC x86 + x64 build and verification.
rem  Run from a "x64 Native Tools Command Prompt" or any prompt where
rem  cl.exe and cmake.exe are on PATH.
rem ======================================================================

set ROOT=%~dp0
set FAIL=0

echo.
echo [1/4] Configure x86
cmake -S "%ROOT%." -B "%ROOT%build\x86" -A Win32 -DGC_STATIC_RUNTIME=ON
if errorlevel 1 goto :fail

echo.
echo [2/4] Build x86
cmake --build "%ROOT%build\x86" --config Release
if errorlevel 1 goto :fail

echo.
echo [3/4] Configure x64
cmake -S "%ROOT%." -B "%ROOT%build\x64" -A x64 -DGC_STATIC_RUNTIME=ON
if errorlevel 1 goto :fail

echo.
echo [4/4] Build x64
cmake --build "%ROOT%build\x64" --config Release
if errorlevel 1 goto :fail

echo.
echo Built:
dir /b "%ROOT%build\x86\bin\GroundClean.exe"
dir /b "%ROOT%build\x64\bin\GroundClean.exe"
echo.
echo Smoke check (x64, dry-run, C: only):
"%ROOT%build\x64\bin\GroundClean.exe" --dry-run --drives=C --no-kill --verbose
echo Exit code: %errorlevel%
goto :eof

:fail
set FAIL=1
echo.
echo BUILD FAILED
exit /b %FAIL%