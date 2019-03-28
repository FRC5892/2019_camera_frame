@echo off
rem cmd /c webdev build
cd build
7z a dashboard.zip "@.build.manifest" .build.manifest
psftp -b ..\deploy.bat.psftp admin@10.58.92.2
del dashboard.zip
cd ..
rem That's so webdev doesn't complain next time
plink -m deploy.bat.plink admin@10.58.92.2
