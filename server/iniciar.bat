@echo off
tasklist /FI "IMAGENAME eq mysqld.exe" | find /I "mysqld.exe" >nul
if errorlevel 1 start "" /MIN "C:\xampp\mysql\bin\mysqld.exe" --defaults-file=C:\xampp\mysql\bin\my.ini --standalone
cd /D "%~dp0"
start "" /MIN "C:\Program Files\nodejs\node.exe" server.js
echo API RutaExpress en http://localhost:3001/api
timeout /t 3 >nul
