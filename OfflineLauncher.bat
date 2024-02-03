@echo off
::Username
set username=Unknown Soldier
::Game Paths
set iw5Path="C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Modern Warfare 3"
set t6Path="C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops II"
set t5Path="C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops"
set t4Path="C:\Program Files (x86)\Steam\steamapps\common\Call of Duty World at War"
::Mod name (default "")
set mod=""

title Plutonium Offline Launcher
echo Choose a game to launch using Plutonium
echo 1. iw5mp
echo 2. t6mp
echo 3. t6zm
echo 4. t5mp
echo 5. t5sp
echo 6. t4mp
echo 7. t4sp
set /P choice=

if not %mod%=="" goto:load_mod_prompt_exit
:load_mod_prompt
set /P load_mod="Would you like to load a mod (Y/N)? "
if "%load_mod:Y=y%"=="y" (
	set /P mod="Enter the mod name> "
) else if not "%load_mod:N=n%"=="n" (
	goto:load_mod_prompt
)

:load_mod_prompt_exit

cd /D %LOCALAPPDATA%\Plutonium

goto:case_%choice%
goto:EOF

:case_1
set gamepath=%iw5Path:"=%
set game=iw5mp
goto:gamestart

:case_2
set gamepath=%t6Path:"=%
set game=t6mp
goto:gamestart

:case_3
set gamepath=%t6Path:"=%
set game=t6zm
goto:gamestart

:case_4
set gamepath=%t5Path:"=%
set game=t5mp
goto:gamestart

:case_5
set gamepath=%t5Path:"=%
set game=t5sp
goto:gamestart

:case_6
set gamepath=%t4Path:"=%
set game=t4mp
goto:gamestart

:case_7
set gamepath=%t4Path:"=%
set game=t4sp
goto:gamestart

:gamestart
start bin\plutonium-bootstrapper-win32.exe %game% "%gamepath%" -lan +name "%username%" +set fs_game %mod%
