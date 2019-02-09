@echo off
cmd /c webdev build
rem Have to split the SFTP script into separate files so it can try to create the directory, but not crash if it exists.
psftp -b deploy.bat.psftp.1 admin@10.58.92.2
psftp -b deploy.bat.psftp.2 admin@10.58.92.2