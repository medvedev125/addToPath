
@echo Batch to simply add directory to PATH variable.
@echo Usage:
@echo Add to the user settings variable:
@echo 	addToPath.bat [additationalPath]
@echo Add to local Path varaible only:
@echo 	addToPath.bat /l [additationalPath]
@echo usage example:
@echo 	addToPath.bat c:\Program Files (x86)\Java\jdk1.7.0_45\bin

@rem todo: support multiply pathes as arguments: addToPath.bat ["additationalPath1"] ["additationalPath2"] ...
@rem todo: check langth of path variable

@rem impl note: call set Path=%%addToPathes_result%% 
@rem            Such assignment (call set) is mandatory, since the variable Path can have parentheses and IF expression will be incorrect

@call :get_echo_state
@set addToPath_oldEchoState=%get_echo_state_result%
@echo off
call :main %*

exit /b %errorcode%

:get_echo_state
	@rem result: get_echo_state_result - ON or OFF
	@set get_echo_state_result=
	@FOR /F "usebackq tokens=3 delims=. " %%I in (`echo`) DO @(
		set get_echo_state_result=%%I
	)
	@exit /b %errorcode%

:canonizePath
	set canonizePath_path=%~1
	set canonizePath_result=
	
	rem handle the case when "\" is in the end of addToPathes_additationalPath or items in addToPathes_pathes
	set canonizePath_result=%canonizePath_path:/=\%
	set canonizePath_backslashInEnd=%canonizePath_result:~-1%
	if "%canonizePath_backslashInEnd%"=="\" set canonizePath_result=%canonizePath_result:~0,-1%
	
	exit /b %errorcode%

:removeFromPathes
	set removeFromPathes_pathes=%~1
	set removeFromPathes_removingPath=%~2
	
	rem handle the case when "\" is in the end of an exits item in addToPathes_pathes
	call set removeFromPathes_result=%%removeFromPathes_pathes:%removeFromPathes_removingPath%\;=%%
	if "%removeFromPathes_result%"=="" (
		exit /b %errorcode%
	)
	
	call set removeFromPathes_result=%%removeFromPathes_result:%removeFromPathes_removingPath%;=%%
	if "%removeFromPathes_result%"=="" (
		exit /b %errorcode%
	)

	if "%removeFromPathes_result%"=="%removeFromPathes_removingPath%\" (
		set removeFromPathes_result=
	)

	if "%removeFromPathes_result%"=="%removeFromPathes_removingPath%" (
		set removeFromPathes_result=
	)
	
	exit /b %errorcode%
	
:addToPathes
	rem remove the additationalPath from the PATH and add it to beginning
	set addToPathes_pathes=%~1
	set addToPathes_additationalPath=%~2
	set addToPathes_result=

	rem prepare the addToPathes_additationalPath argumemt
	if "%addToPathes_additationalPath%"=="" (
		call set addToPathes_result=%%addToPathes_pathes%%
		exit /b %errorcode%
	)

	call :canonizePath "%addToPathes_additationalPath%"
	set addToPathes_additationalPath=%canonizePath_result%

	rem prepare the addToPathes_pathes argumemt
	if "%addToPathes_pathes%"=="" (
		call set addToPathes_result=%%addToPathes_additationalPath%%
		exit /b %errorcode%
	)

	rem remove addToPathes_additationalPath from addToPathes_pathes
	call :removeFromPathes "%addToPathes_pathes%" "%addToPathes_additationalPath%"
	set addToPathes_result=%removeFromPathes_result%
	if "%addToPathes_result%"=="" (
		call set addToPathes_result=%%addToPathes_additationalPath%%
		exit /b %errorcode%
	)

	rem add addToPathes_additationalPath to the begining of addToPathes_pathes
	set addToPathes_result=%addToPathes_additationalPath%;%addToPathes_result%

	exit /b %errorcode%

:main

	rem input arguments
	set allArgs=%*
	set addToLocalPathVar=False
	if "%1"=="/l" (
		set addToLocalPathVar=True
		call set allArgs=%%allArgs:*%1 =%%
		shift
	)

	set additationalPath=%allArgs%

	set user_path=
	if "%addToLocalPathVar%"=="True" (
		call set user_path=%%Path%%
	) else (
		for /F "tokens=1,3 skip=2" %%G IN ('reg query HKCU\Environment') DO (
			if "%%G"=="Path" (
				call set user_path=%%H
			)
		)
	)

	call :addToPathes "%user_path%" "%additationalPath%"

	if "%user_path%"=="%addToPathes_result%" (
		echo Path is already updated
		exit /b %errorcode%
	)

	if "%addToLocalPathVar%"=="True" (
		call set Path=%%addToPathes_result%%
	) else (
		setx Path "%addToPathes_result%"
	)
	echo Path has been updated

	exit /b %errorcode%
	