@echo off
cmd /c webdev build
cd build
7z a dashboard.zip "@.build.manifest" .build.manifest
psftp -b ..\deploy.bat.psftp admin@172.22.11.2
del dashboard.zip
cd ..
rem That's so webdev doesn't complain next time
plink -m deploy.bat.plink admin@172.22.11.2
