rem @echo off
set logDate=20180504
echo %logDate% > "E:\KMADATA\forecast_input\ymd.dat"

mkdir 02.ws_hor\%logDate%
rem move 01.wind\*%logDate%*.dat 02.ws_hor\%logDate%\
cd 00.program
ws_make.exe
cd ..

echo open ftp://administrator:rmarkd12#@en-gis.asuscomm.com:3221> ws_ftp_exe.txt
echo option confirm off>> ws_ftp_exe.txt
echo cd ./3_Met_Data/gum_hg>> ws_ftp_exe.txt
echo put E:\KMADATA\forecast_input\02.ws_hor\%logDate%\%logDate%.pre>> ws_ftp_exe.txt
echo put E:\KMADATA\forecast_input\02.ws_hor\%logDate%\%logDate%.wth>> ws_ftp_exe.txt
echo exit>> ws_ftp_exe.txt
"C:\Program Files\WinSCP\WinSCP.com" /console /script="ws_ftp_exe.txt"

call daejeon.bat

del ymd.dat
