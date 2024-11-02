echo off
set GAME_FOLDER=C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops
set OAT_BASE=C:\OAT
set MOD_BASE=%cd%

for %%I in (%MOD_BASE%\zone_source\*.zone) do call:linker %%~nI
exit /B

:linker %1
"%OAT_BASE%\Linker.exe" ^
-v ^
--load "%GAME_FOLDER%\zone\Common\%1.ff" ^
--base-folder "%OAT_BASE%" ^
--asset-search-path "%MOD_BASE%" ^
--source-search-path "%MOD_BASE%\zone_source" ^
--output-folder "%MOD_BASE%\zone" %1

set err=%ERRORLEVEL%

if %err% EQU 0 (
XCOPY "%MOD_BASE%\zone\%1.ff" "%LOCALAPPDATA%\Plutonium\storage\t5\zone\%1.ff" /Y
) ELSE (
COLOR C
echo FAIL!
)
pause
