# Reset this repo to the rebase-practice starting point.
# Destroys local practice branches. Does not touch the remote.

git switch -q main
git reset --hard practice-main

git branch -f feature/greeting practice-feature
git branch -D backup backup2 backup-before-rebase 2>$null | Out-Null

git switch -q feature/greeting

Write-Host "`nReset. Starting point:`n"
git log --oneline --graph --all --decorate
