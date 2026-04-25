@echo off
cd %~dp0
awk -f commands.awk
