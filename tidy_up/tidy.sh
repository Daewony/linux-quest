#!/bin/bash

# 引数が指定されなかった場合
if [ -z "$1" ]; then
    echo "使い方: ./tidy.sh ディレクトリ" >&2
    exit 1
fi

# 存在しないディレクトリが指定された場合
if [ ! -d "$1" ]; then
    echo "エラー: $1 はディレクトリではありません" >&2
    exit 1
fi

for file in "$1"/*
do
    if [ -f "$file" ]; then
        extension="${file##*.}"

        case ${extension,,} in
            jpg|jpeg|png|gif)
                destination="images"

                mkdir -p "$1"/${destination}
                mv "$file" "$1"/${destination}/
                echo "${file##*/} -> ${destination}/"
                ;;
            pdf|txt|md|docx)
                destination="documents"

                mkdir -p "$1"/${destination}                   
                mv "$file" "$1"/${destination}/
                echo "${file##*/} -> ${destination}/"
                ;;
            mp3|wav)
                destination="music"

                mkdir -p "$1"/${destination}
                mv "$file" "$1"/${destination}/
                echo "${file##*/} -> ${destination}/"
                ;;
            zip|gz)
                destination="archives"

                mkdir -p "$1"/${destination}
                mv "$file" "$1"/${destination}/
                echo "${file##*/} -> ${destination}/"
                ;;
            *)
                destination="others"

                mkdir -p "$1"/${destination}
                mv "$file" "$1"/${destination}/
                echo "${file##*/} -> ${destination}/"
                ;;
        esac
    fi
done
   
