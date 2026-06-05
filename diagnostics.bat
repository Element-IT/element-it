@echo off
setlocal
cd /d "%~dp0"
echo === Docker version ===
docker --version
echo.
echo === Docker compose version ===
docker compose version
echo.
echo === Docker info short ===
docker info --format "{{.ServerVersion}}"
echo.
echo === NVIDIA inside Docker test ===
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
pause
