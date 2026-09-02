@echo off
:: Change directory to the folder where this batch file is located
cd /d "%~dp0"

echo Installing required libraries...
echo.

set "PROJECT_PYTHON=%LocalAppData%\Programs\Python\Python314\python.exe"

if exist "%PROJECT_PYTHON%" (
    "%PROJECT_PYTHON%" -m pip install -r requirements.txt -q
    echo.
    echo Launching Booster Pump Control Panel...
    echo.
    "%PROJECT_PYTHON%" main.py
) else (
    python -m pip install -r requirements.txt -q
    echo.
    echo Launching Booster Pump Control Panel...
    echo.
    python main.py
)

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Application closed unexpectedly.
    pause
)

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Application closed unexpectedly.
    pause
)
