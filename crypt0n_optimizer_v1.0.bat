@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Crypt0n Optimizer v1.0

:: ===============================================
::   C R Y P T 0 N   O P T I M I Z E R   v1.0
::   Optimizador con niveles y restauración
::   Uso: Ejecutar como Administrador
:: ===============================================

:: ---- Comprobación de privilegios ----
>nul 2>&1 net session || (
  echo.
  echo [Crypt0n] Necesas ejecutar como **Administrador**.
  echo Clic derecho en este .bat -> "Ejecutar como administrador".
  pause
  exit /b 1
)

:: ---- Variables generales ----
set "START_TS=%DATE%_%TIME%"
set "START_TS=%START_TS::=-%"
set "START_TS=%START_TS:/=-%"
set "START_TS=%START_TS: =_%"
set "ROOT=%~dp0"
set "BACKUP=%ROOT%backups\%START_TS%"
set "RESTORE=%BACKUP%\restore.cmd"
set "LOG=%BACKUP%\crypton.log"
set "PS=PowerShell -NoProfile -ExecutionPolicy Bypass -Command"
set "CHANGELOG=%BACKUP%\changelog.txt"

:: ---- Preparar carpetas/log ----
if not exist "%BACKUP%" mkdir "%BACKUP%"
echo [LOG] Inicio: %DATE% %TIME% > "%LOG%"
echo [Cambios aplicados] > "%CHANGELOG%"

:: ---- ANSI / ESC para barra de progreso (misma línea) ----
for /F "delims=" %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"

:: ==========================================================
:: DISCLAIMER OBLIGATORIO
:: ==========================================================
cls
call :banner
echo ===================== A V I S O  L E G A L ======================
echo Este script ("Crypt0n Optimizer v1.0") aplica ajustes avanzados a Windows.
echo Puede modificar registro, servicios, tareas, paquetes UWP y energia.
echo -----------------------------------------------------------------
echo RECOMENDACION: Crear una carpeta exclusiva para este script,
echo ya que generara respaldos y archivos de restauracion en subcarpetas.
echo -----------------------------------------------------------------
echo TU USO ES VOLUNTARIO Y BAJO TU PROPIA RESPONSABILIDAD.
echo Los autores NO se hacen responsables de daños, perdida de datos
echo ni consecuencias directas o indirectas. Haz backup antes de usar.
echo =================================================================
echo Para continuar, escribe:  ACEPTO
echo (debes escribir exactamente: A C E P T O)
echo -----------------------------------------------------------------
set /p USER_CONFIRM=Confirmacion: 
if /I not "%USER_CONFIRM%"=="ACEPTO" (
  echo.
  echo No se recibio "ACEPTO". Saliendo sin realizar cambios...
  echo [ABORT] Usuario no acepto el disclaimer. >> "%LOG%"
  timeout /t 2 >nul
  exit /b 0
)

:: ---- Info inicial ----
cls
call :banner
echo Descripcion: Optimizacion por niveles con respaldo y restauracion automatica.
echo Backups: "%BACKUP%"
echo Log     : "%LOG%"
echo.

:: ---- Variables de progreso ----
set /a TOTAL_STEPS=0
set /a CURRENT_STEP=0

:: ---- Menu principal ----
:menu
echo Selecciona un nivel:
echo   [1] Minimo      - Ajustes suaves; sin cambios agresivos.
echo   [2] Basico      - + Telemetria reducida y limpieza.
echo   [3] Intermedio  - + Servicios no criticos en manual, efectos minimos.
echo   [4] Avanzado    - + Debloat moderado y ajustes de red.
echo   [5] Ultra       - + Debloat agresivo y max rendimiento.
echo   [R] Restaurar   - Revertir cambios con restore.cmd (desde backup actual).
echo   [Q] Salir
echo.
set /p CH=Opcion: 

if /I "%CH%"=="1" set "LEVEL=MINIMO"     & set "LEVEL_DESC=Aplicar ajustes suaves, sin desinstalar apps ni tocar servicios criticos." & call :set_total MINIMO     & goto confirm
if /I "%CH%"=="2" set "LEVEL=BASICO"     & set "LEVEL_DESC=Minimo + reducir telemetria, limpiar temporales y algunas tareas ruidosas." & call :set_total BASICO     & goto confirm
if /I "%CH%"=="3" set "LEVEL=INTERMEDIO" & set "LEVEL_DESC=Basico + servicios no criticos a Manual, efectos visuales minimos."         & call :set_total INTERMEDIO & goto confirm
if /I "%CH%"=="4" set "LEVEL=AVANZADO"   & set "LEVEL_DESC=Intermedio + desinstala bloat comun y mejora red."                          & call :set_total AVANZADO   & goto confirm
if /I "%CH%"=="5" set "LEVEL=ULTRA"      & set "LEVEL_DESC=Avanzado + debloat agresivo, maxima performance, telemetria al minimo."     & call :set_total ULTRA      & goto confirm
if /I "%CH%"=="R" goto restore
if /I "%CH%"=="Q" goto end
echo Opcion invalida.
echo.
goto menu

:confirm
echo.
echo Nivel seleccionado: %LEVEL%
echo %LEVEL_DESC%
choice /M "¿Continuar?"
if errorlevel 2 goto menu

:: ---------------------------------------------
:: PROGRESO: inicializa el medidor
:: ---------------------------------------------
set /a CURRENT_STEP=0
call :progress 0 %TOTAL_STEPS%

:: ---- Crear restore.cmd base ----
call :init_restore & call :step & echo - Restauracion base creada>>"%CHANGELOG%"

:: ---- Punto de restauracion ----
call :checkpoint "CRPT_%LEVEL%" & call :step & echo - Punto de restauracion creado>>"%CHANGELOG%"

:: ---- Respaldo de claves ----
call :export_reg & call :step & echo - Respaldos de registro realizados>>"%CHANGELOG%"

:: ---- Ajustes comunes ----
call :common_power          & call :step & echo - Plan de energia ajustado>>"%CHANGELOG%"
call :common_bgapps         & call :step & echo - Apps en segundo plano limitadas>>"%CHANGELOG%"
call :common_notifications  & call :step & echo - Sugerencias/promos desactivadas>>"%CHANGELOG%"
call :common_cleanup        & call :step & echo - Limpieza de temporales y WinSxS>>"%CHANGELOG%"

if /I "%LEVEL%"=="MINIMO"     goto finish_level
if /I "%LEVEL%"=="BASICO"     ( call :tweak_telemetry & call :step & echo - Telemetria reducida>>"%CHANGELOG%" & call :tweak_schtasks & call :step & echo - Tareas de telemetria deshabilitadas>>"%CHANGELOG%" & goto finish_level )
if /I "%LEVEL%"=="INTERMEDIO" ( call :tweak_services  & call :step & echo - Servicios no criticos a Manual>>"%CHANGELOG%" & call :tweak_visual   & call :step & echo - Efectos visuales reducidos>>"%CHANGELOG%" & goto finish_level )
if /I "%LEVEL%"=="AVANZADO"   ( call :debloat_moderado & call :step & echo - Apps sugeridas desinstaladas>>"%CHANGELOG%" & call :net_tweaks    & call :step & echo - Ajustes de red aplicados>>"%CHANGELOG%" & goto finish_level )
if /I "%LEVEL%"=="ULTRA"      ( call :ultimate_perf    & call :step & echo - Plan Ultimate Performance>>"%CHANGELOG%" & call :debloat_agresivo & call :step & echo - Apps de sistema innecesarias eliminadas>>"%CHANGELOG%" & call :tweak_telemetry_extra & call :step & echo - Telemetria extra desactivada>>"%CHANGELOG%" & call :widgets_off & call :step & echo - Widgets/Noticias desactivados>>"%CHANGELOG%" & call :cortana_off & call :step & echo - Cortana desactivada>>"%CHANGELOG%" & goto finish_level )

:finish_level
:: Cerrar barra al 100%
call :progress %TOTAL_STEPS% %TOTAL_STEPS%
echo.

echo =====================================================
echo [Crypt0n Optimizer v1.0] Nivel "%LEVEL%" aplicado.
echo Se genero "restore.cmd" en: "%RESTORE%"
echo Se guardaron respaldos en: "%BACKUP%"
echo -----------------------------------------------------
echo Lista de cambios aplicados:
type "%CHANGELOG%"
echo =====================================================
echo.
pause
goto menu

:: ================= SUBRUTINAS =================

:banner
echo ---------------------------------------------------------------
echo        Crypt0n Optimizer v1.0  -  Optimizador por niveles
echo ---------------------------------------------------------------
echo.
exit /b

:checkpoint
set "CHK_NAME=%~1"
%PS% "Try { Checkpoint-Computer -Description '%CHK_NAME%' -RestorePointType 'MODIFY_SETTINGS' } Catch { }" >> "%LOG%" 2>&1
exit /b

:export_reg
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "%BACKUP%\veffects_hkcu.reg" /y >nul 2>&1
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "%BACKUP%\cdm_hkcu.reg" /y >nul 2>&1
reg export "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "%BACKUP%\wu_hklm.reg" /y >nul 2>&1
reg export "HKLM\SYSTEM\CurrentControlSet\Services" "%BACKUP%\services_hklm.reg" /y >nul 2>&1
exit /b

:init_restore
(
  echo @echo off
  echo title Crypt0n Restore
  echo echo Restaurando ajustes principales...
) > "%RESTORE%"
exit /b

:add_restore
>> "%RESTORE%" echo %*
exit /b

:common_power
powercfg /GetActiveScheme > "%BACKUP%\powerplan_before.txt"
for /f "tokens=3 delims=:" %%A in ('powercfg /L ^| find /i "Alto rendimiento"') do set "SCHEME_HI=%%A"
if defined SCHEME_HI (powercfg -setactive %SCHEME_HI%) else (powercfg -setactive SCHEME_MIN) >nul 2>&1
call :add_restore powercfg -setactive SCHEME_BALANCED ^>nul 2^>^&1
exit /b

:common_bgapps
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul
call :add_restore reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 0 /f ^>nul
exit /b

:common_notifications
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-310093Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSyncProviderNotifications /t REG_DWORD /d 0 /f >nul
call :add_restore reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 1 /f ^>nul
call :add_restore reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-310093Enabled /t REG_DWORD /d 1 /f ^>nul
call :add_restore reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSyncProviderNotifications /t REG_DWORD /d 1 /f ^>nul
exit /b

:common_cleanup
cleanmgr /sagerun:1 >nul 2>&1
%PS% "Try { Start-Process Dism -ArgumentList '/Online','/Cleanup-Image','/StartComponentCleanup','/Quiet' -Wait } Catch {}" >> "%LOG%" 2>&1
exit /b

:tweak_telemetry
sc query DiagTrack >nul 2>&1 && (
  sc stop DiagTrack >nul 2>&1
  sc config DiagTrack start= disabled >nul 2>&1
  call :add_restore sc config DiagTrack start^= demand ^>nul
  call :add_restore sc start DiagTrack ^>nul
)
sc query dmwappushservice >nul 2>&1 && (
  sc stop dmwappushservice >nul 2>&1
  sc config dmwappushservice start= disabled >nul 2>&1
  call :add_restore sc config dmwappushservice start^= demand ^>nul
  call :add_restore sc start dmwappushservice ^>nul
)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f >nul
call :add_restore reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f ^>nul 2^>^&1
exit /b

:tweak_schtasks
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /DISABLE >nul 2>&1
call :add_restore schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /ENABLE ^>nul
call :add_restore schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /ENABLE ^>nul
call :add_restore schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /ENABLE ^>nul
exit /b

:tweak_services
for %%S in (MapsBroker XblAuthManager XblGameSave XboxGipSvc XboxNetApiSvc RetailDemo) do (
  sc query %%S >nul 2>&1 && (
    sc config %%S start= demand >nul 2>&1
    call :add_restore sc config %%S start^= auto ^>nul
  )
)
exit /b

:tweak_visual
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul
call :add_restore reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 1 /f ^>nul
exit /b

:debloat_moderado
%PS% "$apps = 'Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.Microsoft3DViewer','Microsoft.MicrosoftOfficeHub','Microsoft.MicrosoftSolitaireCollection','Microsoft.SkypeApp','Microsoft.ZuneMusic','Microsoft.ZuneVideo'; foreach($a in $apps){ Get-AppxPackage -AllUsers $a ^| Remove-AppxPackage -ErrorAction SilentlyContinue }" >> "%LOG%" 2>&1
call :add_restore echo ^(Reinstalar apps con Microsoft Store si se desea^)
exit /b

:net_tweaks
ipconfig /flushdns >nul
netsh int tcp set global autotuninglevel=normal >nul
call :add_restore netsh int tcp set global autotuninglevel^=normal ^>nul
exit /b

:ultimate_perf
for /f "tokens=4 delims= " %%G in ('powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2^>nul') do set "ULT=%%G"
if defined ULT powercfg -setactive %ULT% >nul 2>&1
call :add_restore powercfg -setactive SCHEME_BALANCED ^>nul
exit /b

:debloat_agresivo
%PS% "$list = @(
  '*Xbox*','*MixedReality*','Microsoft.OneConnect','Microsoft.3DBuilder',
  'Microsoft.ZuneMusic','Microsoft.ZuneVideo','Microsoft.BingNews',
  'Microsoft.MicrosoftStickyNotes'
); foreach($p in $list){ Get-AppxPackage -AllUsers $p ^| Remove-AppxPackage -ErrorAction SilentlyContinue }" >> "%LOG%" 2>&1
call :add_restore echo ^(Para apps: abrir Microsoft Store y reinstalar manualmente^)
exit /b

:tweak_telemetry_extra
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul
call :add_restore reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /f ^>nul 2^>^&1
exit /b

:widgets_off
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f >nul
call :add_restore reg delete "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /f ^>nul 2^>^&1
exit /b

:cortana_off
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >nul
call :add_restore reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /f ^>nul 2^>^&1
exit /b

:restore
echo.
echo === RESTAURAR DESDE BACKUP ACTUAL ===
echo Se ejecutara: "%RESTORE%" (si no existe, se usaran defaults).
if exist "%RESTORE%" (
  call "%RESTORE%"
) else (
  echo No existe restore.cmd en "%BACKUP%".
  echo Aplicando restauracion basica por defecto...
  powercfg -setactive SCHEME_BALANCED >nul 2>&1
  reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f >nul 2>&1
  reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /f >nul 2>&1
  schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /ENABLE >nul 2>&1
  schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /ENABLE >nul 2>&1
  schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /ENABLE >nul 2>&1
  sc config DiagTrack start= demand >nul 2>&1
  sc config dmwappushservice start= demand >nul 2>&1
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 1 /f >nul
)
echo.
pause
goto menu

:end
echo.
echo [Crypt0n Optimizer v1.0] Finalizado. Log en: "%LOG%"
exit /b 0

:: =================== PROGRESO ===================
:set_total
:: Base: 7 pasos comunes (init, checkpoint, export, power, bgapps, notif, cleanup)
if /I "%~1"=="MINIMO"     set /a TOTAL_STEPS=7
if /I "%~1"=="BASICO"     set /a TOTAL_STEPS=9
if /I "%~1"=="INTERMEDIO" set /a TOTAL_STEPS=9
if /I "%~1"=="AVANZADO"   set /a TOTAL_STEPS=9
if /I "%~1"=="ULTRA"      set /a TOTAL_STEPS=12
exit /b

:step
set /a CURRENT_STEP+=1
call :progress %CURRENT_STEP% %TOTAL_STEPS%
exit /b

:progress
:: %1 = current, %2 = total  (barra unica, misma linea)
setlocal EnableDelayedExpansion
if "%2"=="0" (endlocal & goto :eof)
set /a PERC=(100*%1)/%2
set /a WIDTH=30
set /a FILLED=(%1*%WIDTH%)/%2
set "BAR="
for /L %%G in (1,1,!FILLED!) do set "BAR=!BAR!█"
for /L %%G in (1,1,!WIDTH!-!FILLED!) do set "BAR=!BAR!."
<nul set /p "=%ESC%[2K%ESC%[1G[!BAR!] !PERC!%% (!1!/%2)"
endlocal & goto :eof
