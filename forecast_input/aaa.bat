@echo off

set logDate=20160810

echo open 106.247.29.119> ws_ftp_exe.txt
echo pc2>> ws_ftp_exe.txt
echo hc1004>> ws_ftp_exe.txt
echo cd met_data>> ws_ftp_exe.txt
echo put E:\KMADATA\forecast_input\02.ws_hor\%logDate%\%logDate%.pre>> ws_ftp_exe.txt
echo put E:\KMADATA\forecast_input\02.ws_hor\%logDate%\%logDate%.wth>> ws_ftp_exe.txt
echo bye>> ws_ftp_exe.txt
ftp -s:ws_ftp_exe.txt
