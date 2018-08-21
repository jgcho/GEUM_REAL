rem @echo off

rem 날짜 파일 ymd.dat 생성하기
set CDIR=E:\KMADATA\forecast_input\
set CDIR=.\

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
echo %logDate%> "%CDIR%ymd.dat"
