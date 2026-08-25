@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul || exit /b 1
set "VCPKG_ROOT=C:\Users\juanj\develop\_btps_build\vcpkg"
set "PATH=%VCPKG_ROOT%;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;%PATH%"
cd /d "C:\Users\juanj\develop\_btps_build\BESTIARY"
cmake --build build --config RelWithDebInfo
exit /b %ERRORLEVEL%
