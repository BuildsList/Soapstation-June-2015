@echo off
set tab=	
echo. >> ../../.git/config
echo [merge "merge-dmm"] >> ../../.git/config
echo %tab%name = mapmerge driver >> ../../.git/config
echo %tab%driver = ./tools/mapmerge/mapmerge.sh %%O %%A %%B >> ../../.git/config
