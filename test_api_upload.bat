@echo off
setlocal
cd /d "%~dp0"
if "%~1"=="" goto nofile
echo Sending file to transcriber API...
curl.exe -F "file=@%~1" -F "model=medium" -F "chunk_minutes=6" -F "enhance_audio=true" http://localhost:7861/upload
echo.
pause
exit /b 0
:nofile
echo Drag audio/video file onto this BAT file.
echo Or run: test_api_upload.bat "C:\path\audio.m4a"
pause
exit /b 1
