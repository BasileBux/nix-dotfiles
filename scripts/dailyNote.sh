#!/usr/bin/env bash

currentDate=$(date +%d-%b-%Y)
filePath=~/tmp/notes/daily-$currentDate.md

nvim ${filePath}
