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
set dayCnt=1

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
set YESTERDAY=%yyyy%%mm%%dd%


REM Substract your days here
set /A dd=1%dd% - 100 + %dayCnt%
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
set TODAY=%yyyy%%mm%%dd%


REM ##  mainprogram start

   
date /t > 00inp.dat

copy 00inp.dat E:\KMADATA\2018_particle\01air_p\00inp.dat
copy 00inp.dat E:\KMADATA\2018_particle\02tot_c\00inp.dat
copy 00inp.dat E:\KMADATA\2018_particle\03humid\00inp.dat
copy 00inp.dat E:\KMADATA\2018_particle\04air_t\00inp.dat
copy 00inp.dat E:\KMADATA\2018_particle\05xwind\00inp.dat
copy 00inp.dat E:\KMADATA\2018_particle\06ywind\00inp.dat
cd keep

mkdir %DATE_TODAY%

cd %DATE_TODAY%
mkdir 01large_2d
mkdir 02large_wave
mkdir 03large_3d
mkdir 04small_3d
mkdir 05small_wave
mkdir 06small_3d_real
mkdir 07small_wq
cd ..
cd ..
copy 00inp.dat 00setup_model\00large\step0_boxSet\00inp.dat
copy 00inp.dat 00setup_model\00large\step1_discharge\00inp.dat
copy 00inp.dat 00setup_model\00large\step2_bcc\00inp.dat
copy 00inp.dat 00setup_model\00large\step3_wave\00inp.dat
copy 00inp.dat 00setup_model\00small\step0_boxSet\00inp.dat
copy 00inp.dat 00setup_model\00small\step1_discharge\00inp.dat
copy 00inp.dat 00setup_model\00small\step2_bcc\00inp.dat
copy 00inp.dat 00setup_model\00small\step3_wave\00inp.dat
00mke_export_wgrib.exe
copy 01mke_export_wgrib.bat ..\01mke_export_wgrib.bat
cd ../
call 01mke_export_wgrib.bat

move *air_p.dat 2018_particle\01air_p\
move *tot_c.dat 2018_particle\02tot_c\
move *humid.dat 2018_particle\03humid\
move *air_t.dat 2018_particle\04air_t\
move *xwind.dat 2018_particle\05xwind\
move *ywind.dat 2018_particle\06ywind\

cd 2018_particle
cd 01air_p
2018step_write_airp.exe
copy 00air_press_utc.amp E:\KMADATA\2018_particle\00setup_model\00large\step0_boxSet\
copy 00air_press_utc.amp E:\KMADATA\2018_particle\00setup_model\00small\step0_boxSet\
cd ..
cd 02tot_c
2018step_write_totc.exe
copy 00cloud_utc.amc E:\KMADATA\2018_particle\00setup_model\00large\step0_boxSet\
copy 00cloud_utc.amc E:\KMADATA\2018_particle\00setup_model\00small\step0_boxSet\
cd ..
cd 03humid
2018step_write_humd.exe
copy 00hum_ty_utc.amr E:\KMADATA\2018_particle\00setup_model\00large\step0_boxSet\
copy 00hum_ty_utc.amr E:\KMADATA\2018_particle\00setup_model\00small\step0_boxSet\
cd ..
cd 04air_t
2018step_write_airt.exe
copy 00air_temp_utc.amt E:\KMADATA\2018_particle\00setup_model\00large\step0_boxSet\
copy 00air_temp_utc.amt E:\KMADATA\2018_particle\00setup_model\00small\step0_boxSet\
cd ..
cd 05xwind
2018step_write_xwnd.exe
copy 00x-wind_utc.amu E:\KMADATA\2018_particle\00setup_model\00large\step0_boxSet\
copy 00x-wind_utc.amu E:\KMADATA\2018_particle\00setup_model\00small\step0_boxSet\
cd ..
cd 06ywind
2018step_write_ywnd.exe
copy 00y-wind_utc.amv E:\KMADATA\2018_particle\00setup_model\00large\step0_boxSet\
copy 00y-wind_utc.amv E:\KMADATA\2018_particle\00setup_model\00small\step0_boxSet\
cd ..

copy E:\KMADATA\forecast_input\"x_wind_yecs_%TODAY%.wnd" E:\KMADATA\2018_particle\00setup_model\00large\step3_wave\x_wind_yecs.wnd
copy E:\KMADATA\forecast_input\"y_wind_yecs_%TODAY%.wnd" E:\KMADATA\2018_particle\00setup_model\00large\step3_wave\y_wind_yecs.wnd
copy E:\KMADATA\forecast_input\"x_wind_geum_%TODAY%.wnd" E:\KMADATA\2018_particle\00setup_model\00large\step3_wave\x_wind_geum.wnd
copy E:\KMADATA\forecast_input\"y_wind_geum_%TODAY%.wnd" E:\KMADATA\2018_particle\00setup_model\00large\step3_wave\y_wind_geum.wnd

REM ++++++++++++++++++++++++++++++++++++++++++++
REM + 유역모델로 기상자료 업로드 처리 START
REM ++++++++++++++++++++++++++++++++++++++++++++
call E:\KMADATA\watershed_realtime\sheddown.bat
cd ..
REM --------------------------------------------
REM - 유역모델로 기상자료 업로드 처리 END
REM --------------------------------------------

REM ++++++++++++++++++++++++++++++++++++++++++++
REM + 유역모델 결과 다운로드 처리 START
REM ++++++++++++++++++++++++++++++++++++++++++++

REM 다운로드 위치는 E:\KMADATA\watershed_realtime\%DATE_TODAY%\

REM --------------------------------------------
REM - 유역모델 결과 다운로드 처리 END
REM --------------------------------------------

REM ++++++++++++++++++++++++++++++++++++++++++++
REM + 유역모델이 안돌았을 경우 START
REM ++++++++++++++++++++++++++++++++++++++++++++

REM 다운로드 위치는 E:\KMADATA\watershed_realtime\%DATE_TODAY%\
REM 위에 오늘날짜의 0 data 생성

REM --------------------------------------------
REM - 유역모델이 안돌았을 경우 END
REM --------------------------------------------

REM ++++++++++++++++++++++++++++++++++++++++++++
REM + 하구둑 방류량 처리 START
REM ++++++++++++++++++++++++++++++++++++++++++++
REM 위치는 E:\KMADATA/2018_particle/00setup_model/00small/step0_boxSet
REM 파일명은 RLT_079.DAT 형식은 RLT_078.DAT 유지. 방류량만 산정 /7 할 것
REM --------------------------------------------
REM - 하구둑 방류량 처리 END
REM --------------------------------------------

cd 2018_particle
copy E:\KMADATA\watershed_realtime\%DATE_TODAY%\"%TODAY%_Flowrate.csv" E:\KMADATA\2018_particle\00setup_model\00small\step0_boxSet\
copy E:\KMADATA\watershed_realtime\%DATE_TODAY%\"%TODAY%_Sediment.csv" E:\KMADATA\2018_particle\00setup_model\00small\step0_boxSet\
copy E:\KMADATA\watershed_realtime\%DATE_TODAY%\"%TODAY%_Flowrate.csv" E:\KMADATA\2018_particle\00setup_model\00small\step4_wq_inp\
copy E:\KMADATA\watershed_realtime\%DATE_TODAY%\"%TODAY%_Sediment.csv" E:\KMADATA\2018_particle\00setup_model\00small\step4_wq_inp\
copy E:\KMADATA\watershed_realtime\%DATE_TODAY%\"%TODAY%_Nitrogen.csv" E:\KMADATA\2018_particle\00setup_model\00small\step4_wq_inp\
copy E:\KMADATA\watershed_realtime\%DATE_TODAY%\"%TODAY%_Carbon.csv" E:\KMADATA\2018_particle\00setup_model\00small\step4_wq_inp\
copy E:\KMADATA\watershed_realtime\%DATE_TODAY%\"%TODAY%_Phosphorus.csv" E:\KMADATA\2018_particle\00setup_model\00small\step4_wq_inp\
copy E:\KMADATA\forecast_input\02.ws_hor\%YESTERDAY%\*.dae E:\KMADATA\2018_particle\00setup_model\00small\step0_boxSet\
copy E:\KMADATA\forecast_input\02.ws_hor\%TODAY%\*.dae E:\KMADATA\2018_particle\00setup_model\00small\step0_boxSet\
copy E:\KMADATA\forecast_input\02.ws_hor\%YESTERDAY%\*.wda E:\KMADATA\2018_particle\00setup_model\00small\step4_wq_inp\
copy E:\KMADATA\forecast_input\02.ws_hor\%TODAY%\*.wda E:\KMADATA\2018_particle\00setup_model\00small\step4_wq_inp\

cd 00setup_model
cd 00large
cd step1_discharge
00mke_dis.exe
cd ..
cd step2_bcc
00mke_bcc.exe
01mke_bcc_2d.exe
cd ..
cd step0_boxSet
01mke_mdf.exe
02mke_mdf.exe
copy * E:\KMADATA\2018_particle\00setup_model\01large_2d\
copy * E:\KMADATA\2018_particle\00setup_model\03large_3d\
cd ..
cd step3_wave
01mke_large_wave.exe
copy * E:\KMADATA\2018_particle\00setup_model\02large_wave\
cd ..
cd ..
cd 00small
cd step0_boxSet
01mke_mdf.exe
02mke_mdf.exe
dir/b *.csv >  00csv.dat
dir/b *.dae >  00dae.dat
03-0sor.exe
03-1mke_baekje_dis.exe
03-2make_baek.exe
03conv_discharge.exe
copy * E:\KMADATA\2018_particle\00setup_model\04small_3d\
copy * E:\KMADATA\2018_particle\00setup_model\06small_3d_real\
cd..
cd step3_wave
01mke_mdw.exe
copy * E:\KMADATA\2018_particle\00setup_model\05small_wave\
cd ..
cd step4_wq_inp
copy * E:\KMADATA\2018_particle\00setup_model\07small_wq\
cd ..
cd ..

cd 01large_2d
copy * E:\KMADATA\2018_particle\keep\%DATE_TODAY%\01large_2d\
cd ..
cd 02large_wave
copy * E:\KMADATA\2018_particle\keep\%DATE_TODAY%\02large_wave\
cd ..
cd 03large_3d
copy * E:\KMADATA\2018_particle\keep\%DATE_TODAY%\03large_3d\
cd ..
cd 04small_3d
copy * E:\KMADATA\2018_particle\keep\%DATE_TODAY%\04small_3d\
cd ..
cd 05small_wave
copy * E:\KMADATA\2018_particle\keep\%DATE_TODAY%\05small_wave\
cd ..
cd 06small_3d_real
copy * E:\KMADATA\2018_particle\keep\%DATE_TODAY%\06small_3d_real\
cd ..
cd 07small_wq
copy * E:\KMADATA\2018_particle\keep\%DATE_TODAY%\07small_wq\
cd ..
cd ..



