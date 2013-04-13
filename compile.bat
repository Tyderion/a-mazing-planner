@echo off
cd
copy /b coffee\maze\obstacle.coffee+coffee\maze\overlay.coffee+coffee\maze\maze.coffee coffee\main.coffee
coffee -o js -c "coffee\main.coffee"
haml "haml\%%~nf.haml" "%%~nf.html"
