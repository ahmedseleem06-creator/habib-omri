@echo off
chcp 65001 > nul
echo ===================================================
echo     سيرفر تطبيق حبيب عمري (Habib Omri Server)
echo ===================================================
echo جاري فحص وتثبيت المكتبات المطلوبة...
py -m pip install -r requirements.txt
echo.
echo تشغيل السيرفر على http://localhost:8000 ...
py main.py
pause
