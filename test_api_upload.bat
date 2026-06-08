@echo off
setlocal
cd /d "%~dp0"
if "%~1"=="" goto nofile
if "%TRANSCRIBER_URL%"=="" set "TRANSCRIBER_URL=http://localhost:7861"
echo Sending file to transcriber API at %TRANSCRIBER_URL%...
curl.exe -F "file=@%~1" -F "model=medium" -F "chunk_minutes=6" -F "enhance_audio=true" "%TRANSCRIBER_URL%/upload"
echo.
pause
exit /b 0
:nofile
echo Drag audio/video file onto this BAT file.
echo Or run: test_api_upload.bat "C:\path\audio.m4a"
echo Optional: set TRANSCRIBER_URL=http://politech.space:7861
pause
exit /b 1
