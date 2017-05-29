@echo Simple batch to simply add HOME directory of specific tool to user environment variables.
@echo usage:
@echo 	addToPath.bat [additational_path]
@echo usage example:
@echo 	addToPath.bat c:\Program Files (x86)\Java\jdk1.7.0_45\bin

@rem input arguments
@set additational_path=%*

@rem todo: support multiply pathes as arguments: addToPath.bat ["additational_path1"] ["additational_path2"] ...

@echo Run...
@echo additational_path = %additational_path%

@rem todo: check langth of path variable

@rem remove the additational_path from the PATH and add it to beginning
@call set NEW_PATH=%additational_path%;%%PATH:%additational_path%;=%%
@rem todo: handle the case when the "additational_path" is in end of PATH (so there is not the ";" sign)

call setx PATH "%NEW_PATH%"
