@echo off
setlocal
cd /d "%~dp0"
docker compose -f docker-compose.gpu.yml down
docker compose -f docker-compose.cpu.yml down
pause
