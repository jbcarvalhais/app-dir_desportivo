@echo off
title Diretor Desportivo
cd /d "%~dp0"
start "Diretor Desportivo - servidor (nao fechar esta janela)" cmd /k "python -m http.server 8000"
timeout /t 2 /nobreak >nul
start "" http://localhost:8000/
exit
