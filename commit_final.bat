@echo off
setlocal
set REPO=C:\Users\Team_2\proejcts\adp_mobile
cd /d "%REPO%"
del /f /q ".git\index.lock" 2>nul
git status --short
git commit -F "%REPO%\.git.commit.msg.txt"
git status --short
git log --oneline -6
echo DONE
