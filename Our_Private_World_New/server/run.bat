@echo off
title Habib Omri Server
cd /d "%~dp0"
echo ===================================================
echo           Habib Omri Server (Running...)
echo ===================================================
echo Local Server URL: http://192.168.1.2:8000
echo.
"C:\Users\hossam\AppData\Local\Programs\Python\Python313\python.exe" -m uvicorn main:app --host 0.0.0.0 --port 8000
pause
