@echo off
setlocal
cd /d "%~dp0"
if "%~1"=="" goto nofile
set "JOBID=%RANDOM%%RANDOM%"
set "EXT=%~x1"
mkdir "data\input\%JOBID%" 2>nul
copy "%~1" "data\input\%JOBID%\source%EXT%" >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "$job='%JOBID%'; $ext='%EXT%'; $obj=[ordered]@{job_id=$job; input_path='/data/input/'+$job+'/source'+$ext; model='medium'; chunk_minutes=6; enhance_audio=$true; output_name='Rasshifrovka_soveshchaniya'; auto_safe_model=$true}; $obj | ConvertTo-Json | Set-Content -Encoding UTF8 ('data/jobs/'+$job+'.ready.json')"
echo Created job: %JOBID%
echo Status: http://localhost:7861/jobs/%JOBID%
pause
exit /b 0
:nofile
echo Drag audio/video file onto this BAT file.
pause
exit /b 1
