echo off
set GAME_FOLDER=C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops
set OAT_BASE=C:\OAT
set MOD_BASE=%cd%
set GAME_LANGUAGE=english
set FILENAME=%GAME_LANGUAGE:~0,2%_zombie_cod5_factory

"%OAT_BASE%\Linker.exe" ^
-v ^
--load "%MOD_BASE%\zone\mod.ff" ^
--load "%GAME_FOLDER%\zone\%GAME_LANGUAGE%\%FILENAME%.ff" ^
--base-folder "%OAT_BASE%" ^
--asset-search-path "%MOD_BASE%" ^
--source-search-path "%MOD_BASE%\zone_source" ^
--output-folder "%MOD_BASE%\zone\%GAME_LANGUAGE%" %FILENAME%

set err=%ERRORLEVEL%

if %err% EQU 0 (
XCOPY "%MOD_BASE%\zone\%GAME_LANGUAGE%\%FILENAME%.ff" "%LOCALAPPDATA%\Plutonium\storage\t5\zone\%FILENAME%.ff" /Y
) ELSE (
COLOR C
echo FAIL!
)
pause