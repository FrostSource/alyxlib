RESOURCE_MANIFEST_FILE = '''<!-- kv3 encoding:text:version{{e21c7f3c-8a33-41c5-9977-a76d3a32aa0d}} format:generic:version{{7412167c-06e9-4698-aff2-e63eb59037e7}} -->
{{
	resourceManifest = 
	[
		[ 
			"soundevents/{0}_soundevents.vsndevts",
		],
	]
}}
'''

SOUNDEVENT_FILE = '''<!-- kv3 encoding:text:version{{e21c7f3c-8a33-41c5-9977-a76d3a32aa0d}} format:generic:version{{7412167c-06e9-4698-aff2-e63eb59037e7}} -->
{{
    MySound = 
    {{
        type = "hlvr_default_3d"
        volume = 1.000000
        volume_falloff_min = 0.000000
        volume_falloff_max = 1000.000000
        vsnd_files = 
        [
            "sounds/common/null.vsnd",
        ]
    }}
}}
'''

SCRIPT_INIT_LOCAL = '''-- This file was automatically generated by AlyxLib.
require("{0}.init")
'''

SCRIPT_INIT_WORKSHOP = '''-- This file was automatically generated by AlyxLib.
-- Rename this file to the ID of your workshop item after upload.
require("{0}.init")
'''

SCRIPT_INIT_MAIN = '''-- This file was automatically generated by AlyxLib.

-- alyxlib can only run on server
if IsServer() then
    -- Load alyxlib before using it, in case this mod loads before the alyxlib mod.
    require("alyxlib.init")

    -- execute code or load mod libraries here

end
'''

ON_UPLOAD_FILE = '''@REM This file was automatically generated by alyxlib.\n@REM Run this file before uploading your addon to the workshop, then follow window instructions after uploading.
@echo off


IF NOT EXIST "{0}" (
echo AlyxLib folder wasn't found, cannot perform this batch file! Please rerun alyxlib.py to setup correctly...
PAUSE
EXIT
)

{1}

echo Symlinks have been removed, continue after uploading to workshop.
PAUSE
echo.

{2}

echo Symlinks reinstated! This window can now be closed.
PAUSE
'''