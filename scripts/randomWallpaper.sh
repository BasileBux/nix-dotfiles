#!/usr/bin/env bash

# Get a list of all files in the directory
files=(~/Pictures/wallpaper/*.png)

# Get the number of files in the directory
num_files=${#files[@]}

# Generate a random index between 0 and (num_files - 1)
random_index=$((RANDOM % num_files))

# Select a random file
random_file=${files[$random_index]}

# Copy the selected file to the home directory and name it wallpaper.png
cp $random_file ~/wallpaper.png
