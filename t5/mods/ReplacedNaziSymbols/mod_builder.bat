echo off
set MOD_NAME=ReplacedNaziSymbols
set GAME_FOLDER=C:\Program Files (x86)\Steam\steamapps\content\app_42700\depot_42706
set OAT_BASE=C:\OAT
set MOD_BASE=%cd%

"%OAT_BASE%\Linker.exe" ^
-v ^
--load "%GAME_FOLDER%\zone\German\ge_zombie_cod5_factory.ff" ^
--base-folder "%OAT_BASE%" ^
--asset-search-path "%MOD_BASE%" ^
--source-search-path "%MOD_BASE%\zone_source" ^
--output-folder "%MOD_BASE%\zone" mod

set err=%ERRORLEVEL%

if %err% EQU 0 (
XCOPY "%MOD_BASE%\zone\mod.ff" "%LOCALAPPDATA%\Plutonium\storage\t5\mods\%MOD_NAME%\mod.ff" /Y
) ELSE (
COLOR C
echo FAIL!
)
pause