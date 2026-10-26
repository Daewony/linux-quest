#!/bin/bash

for file in ~/messy_downloads/*
do
    if [ -f "$file" ]; then
        extension="${file##*.}"

        case ${extension,,} in
    jpg|jpeg|png|gif)
        destination="images"

        mkdir -p ~/messy_downloads/${destination}
        mv "$file" ~/messy_downloads/${destination}/
        echo "${file##*/} -> ${destination}/"
        ;;
    pdf|txt|md|docx)
        destination="documents"

        mkdir -p ~/messy_downloads/${destination}                   
        mv "$file" ~/messy_downloads/${destination}/
        echo "${file##*/} -> ${destination}/"
        ;;
    mp3|wav)
        destination="music"

        mkdir -p ~/messy_downloads/${destination}
        mv "$file" ~/messy_downloads/${destination}/
        echo "${file##*/} -> ${destination}/"
        ;;
    zip|gz)
        destination="archives"

        mkdir -p ~/messy_downloads/${destination}
        mv "$file" ~/messy_downloads/${destination}/
        echo "${file##*/} -> ${destination}/"
        ;;
    *)
        destination="others"

        mkdir -p ~/messy_downloads/${destination}
        mv "$file" ~/messy_downloads/${destination}/
        echo "${file##*/} -> ${destination}/"
        ;;
        esac
    fi
done
   
