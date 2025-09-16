@echo off
echo Kikay Model Conversion Script
echo =============================
echo This script converts H5 models to TensorFlow Lite format
echo.

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% == 0 (
    echo Python is installed
) else (
    echo Python is not installed or not in PATH
    echo Please install Python from https://www.python.org/downloads/
    echo Or from the Microsoft Store
    echo.
    pause
    exit /b
)

echo Installing required packages...
pip install tensorflow
if %errorlevel% neq 0 (
    echo Failed to install TensorFlow
    pause
    exit /b
)

echo.
echo Converting models...
python convert_models.py
if %errorlevel% neq 0 (
    echo Model conversion failed
    pause
    exit /b
)

echo.
echo Model conversion completed successfully!
echo TFLite models are saved in the 'tflite_models' directory
echo.
pause