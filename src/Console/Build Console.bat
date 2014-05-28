@echo off
set begin_file=Index.htm
set result_file=Console.htm
if exist %result_file% del /q %result_file%
for /f "delims=" %%a in (%begin_file%) do (
  (echo %%a)|>nul find  "/*end_style*/"&&(copy /d Console.htm + style.css)
  (echo %%a)|>nul find  "/*end_code*/"&&(copy /d Console.htm + code.js)
  (echo %%a)>>%result_file%
)
:copy /y %result_file% %begin_file% >nul
:del /f /q %result_file% >nul
ping -n 10 127.0.0.1 > NUL