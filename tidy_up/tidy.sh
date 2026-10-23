#!/bin/bash

for file in ~/messy_downloads/*
do
    if [ -f "$file" ]; then
        if [[ "$file" == *.* ]]; then
            echo "File: ${file##*/} (${file##*.})"
        else
            echo "File: ${file##*/} ()"
        fi
    fi
done
