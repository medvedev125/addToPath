@echo Simple batch to simply add HOME directory of specific tool to user environment variables.
@echo usage:
@echo 	addToPath.bat [additational_path]
@echo usage example:
@echo 	addToPath.bat c:\Program Files (x86)\Java\jdk1.7.0_45\bin

@call :main %*
@exit /b %errorcode%

:addToPathLikeVar
	@rem remove the additational_path from the PATH and add it to beginning
	@set addToPathLikeVar_path_var=%~1
	@set addToPathLikeVar_additational_path=%~2
	@set addToPathLikeVar_result=

	@rem todo: support multiply pathes as arguments: addToPath.bat ["additational_path1"] ["additational_path2"] ...
	@rem todo: check langth of path variable
	

	@if "%addToPathLikeVar_additational_path%"=="" (
		@set addToPathLikeVar_result=%addToPathLikeVar_path_var%
		@exit /b %errorcode%
	)
	@rem handle the case when "\" is in the end of addToPathLikeVar_additational_path or items in addToPathLikeVar_path_var
	@set addToPathLikeVar_additational_path=%addToPathLikeVar_additational_path:/=\%
	@set backslash_in_end=%addToPathLikeVar_additational_path:~-1%
	@if "%backslash_in_end%"=="\" @set addToPathLikeVar_additational_path=%addToPathLikeVar_additational_path:~0,-1%

	@if "%addToPathLikeVar_path_var%"=="" (
		@set addToPathLikeVar_result=%addToPathLikeVar_additational_path%
		@exit /b %errorcode%
	)

	@rem handle the case when "\" is in the end of an exits item in addToPathLikeVar_path_var
	@call set addToPathLikeVar_result=%%addToPathLikeVar_path_var:%addToPathLikeVar_additational_path%\=%%
	@if not "%addToPathLikeVar_result%"=="" (
		@call set addToPathLikeVar_result=%%addToPathLikeVar_result:%addToPathLikeVar_additational_path%=%%
	)
	@if not "%addToPathLikeVar_result%"=="" (
		@set addToPathLikeVar_result=%addToPathLikeVar_result:;;=;%
	)

	@if not "%addToPathLikeVar_result%"=="" (
		@set addToPathLikeVar_result=%addToPathLikeVar_additational_path%;%addToPathLikeVar_result%
	) else (
		@set addToPathLikeVar_result=%addToPathLikeVar_additational_path%
	)

	@exit /b %errorcode%

:main
	@rem input arguments
	@set additational_path=%*

	@rem todo: support multiply pathes as arguments: addToPath.bat ["additational_path1"] ["additational_path2"] ...

	@rem @echo [DEBUG] Run...
	@rem @echo [DEBUG] additational_path=%additational_path%
	
	@set user_path=
	@for /F "tokens=1,3 skip=2" %%G IN ('reg query HKCU\Environment') DO @(
		@if "%%G"=="Path" (
			@set user_path=%%H
		)
	)
	
	@rem @echo [DEBUG] user_path=%user_path%

	@call :addToPathLikeVar "%user_path%" "%additational_path%"

	@rem @echo [DEBUG] addToPathLikeVar_result=%addToPathLikeVar_result%
		
	@if "%user_path%"=="%addToPathLikeVar_result%" (
		@echo Path is already updated
		@exit /b %errorcode%
	)
	
	@setx Path "%addToPathLikeVar_result%"
	@echo Path has been updated

	@exit /b %errorcode%