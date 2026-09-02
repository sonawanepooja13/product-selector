@echo off
REM Build an executable for Windows using PyInstaller.
REM Usage: double-click this file or run from command prompt in the project root.

SET PYTHON=python

REM Create (or reuse) a venv to avoid polluting system Python
IF NOT EXIST .venv (
    %PYTHON% -m venv .venv
)

CALL .venv\Scripts\activate

REM Upgrade pip and install required build packages
pip install --upgrade pip
pip install -r requirements.txt

REM Ensure output folder for exports exists so PyInstaller can include it
mkdir project_management_exports 2>nul

REM Build single-file GUI executable (no console). Change --windowed to --console if you want a console window.
pyinstaller --noconfirm --onefile --windowed --name "CompanyManagementSoftware" --add-data "project_management_exports;project_management_exports" main.py

IF %ERRORLEVEL% NEQ 0 (
    echo PyInstaller failed. Check output above.
    pause
) ELSE (
    echo Build succeeded. Executable located at dist\CompanyManagementSoftware.exe
    pause
)
