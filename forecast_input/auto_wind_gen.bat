rem @echo off
set logDate=%1
if not "%logDate%"=="" goto MVAUTO

for /F "tokens=1" %%a in ('date /t') do set DATE_TODAY=%%a

REM [Date Format = yyyy-mm-dd]
set yyyy=%DATE_TODAY:~0,4%
set mm=%DATE_TODAY:~5,2%
set dd=%DATE_TODAY:~8,2%

REM ###########################################################################
REM dayCnt: 며칠 전 것을 설정할 지 결정
REM ###########################################################################
set dayCnt=0

REM Substract your days here
set /A dd=1%dd% - 100 - %dayCnt%
set /A mm=1%mm% - 100

:CHKDAY
if /I %dd% GTR 0 goto DONE
set /A mm=%mm% - 1
if /I %mm% GTR 0 goto ADJUSTDAY
set /A mm=12
set /A yyyy=%yyyy% - 1

:ADJUSTDAY
if %mm%==1 goto SET31
if %mm%==2 goto LEAPCHK
if %mm%==3 goto SET31
if %mm%==4 goto SET30
if %mm%==5 goto SET31
if %mm%==6 goto SET30
if %mm%==7 goto SET31
if %mm%==8 goto SET31
if %mm%==9 goto SET30
if %mm%==10 goto SET31
if %mm%==11 goto SET30

REM ** Month 12 falls through

:SET31
set /A dd=31 + %dd%
goto CHKDAY

:SET30
set /A dd=30 + %dd%
goto CHKDAY

:LEAPCHK
set /A tt=%yyyy% %% 4
if not %tt%==0 goto SET28
set /A tt=%yyyy% %% 100
if not %tt%==0 goto SET29
set /A tt=%yyyy% %% 400
if %tt%==0 goto SET29

:SET28
set /A dd=28 + %dd%
goto CHKDAY

:SET29
set /A dd=29 + %dd%
goto CHKDAY

:DONE
if /I %mm% LSS 10 set mm=0%mm%
if /I %dd% LSS 10 set dd=0%dd%
set logDate=%yyyy%%mm%%dd%

:MVAUTO
echo %logDate%
echo %logDate% > "E:\KMADATA\forecast_input\ymd.dat"

mkdir 02.ws_hor\%logDate%

setlocal enabledelayedexpansion
for /l %%a in (0,3,87) do (
  set n=%%a
  if !n! lss 10 (
    rem echo 0!n!
    set cfn=0!n!
  ) else (
  rem echo !n!
  set cfn=!n!
  )
  echo !cfn!
00.program\wgrib2\wgrib2.exe "E:\KMADATA\r120_v070_erea_unis_h0!cfn!.%logDate%00.gb2"  -d 26 -ijbox 165:300 77:247  "E:\KMADATA\forecast_input\01.wind\r%logDate%!cfn!u.dat" text
00.program\wgrib2\wgrib2.exe "E:\KMADATA\r120_v070_erea_unis_h0!cfn!.%logDate%00.gb2"  -d 27 -ijbox 165:300 77:247  "E:\KMADATA\forecast_input\01.wind\r%logDate%!cfn!v.dat" text
00.program\wgrib2\wgrib2.exe "E:\KMADATA\r120_v070_erea_unis_h0!cfn!.%logDate%00.gb2"  -d 16 -ijbox 165:300 77:247  "E:\KMADATA\forecast_input\02.ws_hor\%logDate%\R_NCPCP_%logDate%!cfn!.dat" text
00.program\wgrib2\wgrib2.exe "E:\KMADATA\r120_v070_erea_unis_h0!cfn!.%logDate%00.gb2"  -d 39 -ijbox 165:300 77:247  "E:\KMADATA\forecast_input\02.ws_hor\%logDate%\R_TMP_%logDate%!cfn!.dat" text
00.program\wgrib2\wgrib2.exe "E:\KMADATA\r120_v070_erea_unis_h0!cfn!.%logDate%00.gb2"  -d 44 -ijbox 165:300 77:247  "E:\KMADATA\forecast_input\02.ws_hor\%logDate%\R_RH_%logDate%!cfn!.dat" text
00.program\wgrib2\wgrib2.exe "E:\KMADATA\r120_v070_erea_unis_h0!cfn!.%logDate%00.gb2"  -d 115 -ijbox 165:300 77:247  "E:\KMADATA\forecast_input\02.ws_hor\%logDate%\R_PRES_%logDate%!cfn!.dat" text
00.program\wgrib2\wgrib2.exe "E:\KMADATA\r120_v070_erea_unis_h0!cfn!.%logDate%00.gb2"  -d 1 -ijbox 165:300 77:247  "E:\KMADATA\forecast_input\02.ws_hor\%logDate%\R_NDNSW_%logDate%!cfn!.dat" text
)

setlocal enabledelayedexpansion
for /l %%a in (0,1,36) do (
  set n=%%a
  if !n! lss 10 (
    rem echo 0!n!
    set cfn=0!n!
  ) else (
  rem echo !n!
  set cfn=!n!
  )
  echo !cfn!
00.program\wgrib2\wgrib2.exe "E:\KMADATA\l015_v070_erlo_unis_h0!cfn!.%logDate%00.gb2" -d 15 -text "E:\KMADATA\forecast_input\01.wind\l%logDate%!cfn!u.dat"
00.program\wgrib2\wgrib2.exe "E:\KMADATA\l015_v070_erlo_unis_h0!cfn!.%logDate%00.gb2" -d 16 -text "E:\KMADATA\forecast_input\01.wind\l%logDate%!cfn!v.dat"
00.program\wgrib2\wgrib2.exe "E:\KMADATA\l015_v070_erlo_unis_h0!cfn!.%logDate%00.gb2" -d 8 -text "E:\KMADATA\forecast_input\02.ws_hor\%logDate%\L_NCPCP_%logDate%!cfn!.dat"
00.program\wgrib2\wgrib2.exe "E:\KMADATA\l015_v070_erlo_unis_h0!cfn!.%logDate%00.gb2" -d 21 -text "E:\KMADATA\forecast_input\02.ws_hor\%logDate%\L_TMP_%logDate%!cfn!.dat"
00.program\wgrib2\wgrib2.exe "E:\KMADATA\l015_v070_erlo_unis_h0!cfn!.%logDate%00.gb2" -d 26 -text "E:\KMADATA\forecast_input\02.ws_hor\%logDate%\L_RH_%logDate%!cfn!.dat"
00.program\wgrib2\wgrib2.exe "E:\KMADATA\l015_v070_erlo_unis_h0!cfn!.%logDate%00.gb2" -d 136 -text "E:\KMADATA\forecast_input\02.ws_hor\%logDate%\L_PRES_%logDate%!cfn!.dat"
00.program\wgrib2\wgrib2.exe "E:\KMADATA\l015_v070_erlo_unis_h0!cfn!.%logDate%00.gb2" -d 1 -text "E:\KMADATA\forecast_input\02.ws_hor\%logDate%\L_NDNSW_%logDate%!cfn!.dat"
)

cd 00.program
wind2yecs32bit.exe
wind2geum32bit.exe
cd ..

move 01.wind\*%logDate%*.dat 02.ws_hor\%logDate%\
cd 00.program
ws_make.exe
cd ..

echo open ftp://realtime:rmarkd23@118.219.45.145:1023> ws_ftp_exe.txt
echo option confirm off>> ws_ftp_exe.txt
echo cd ./3_Met_Data>> ws_ftp_exe.txt
echo put E:\KMADATA\forecast_input\02.ws_hor\%logDate%\%logDate%.pre>> ws_ftp_exe.txt
echo put E:\KMADATA\forecast_input\02.ws_hor\%logDate%\%logDate%.wth>> ws_ftp_exe.txt
echo exit>> ws_ftp_exe.txt
"C:\Program Files\WinSCP\WinSCP.com" /console /script="ws_ftp_exe.txt"

call daejeon.bat

del ymd.dat
