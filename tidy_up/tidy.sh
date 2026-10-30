#!/bin/bash

# 引数が2つ指定された場合のオプション処理 / 인수가 2개인 경우 옵션 처리
if [ $# -eq 2 ]; then 
    if [ "$1" = "--dry-run" ]; then
        command_option="$1"
        shift 1
    else
        echo "エラー: 引数を2つ指定する場合、--dry-run オプションのみ使用できます。" >&2
        exit 1
    fi
fi

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

images_count=0
documents_count=0
music_count=0
archives_count=0
others_count=0

for file in "$1"/*
do
    # 通常のファイル以外はスキップする / 일반 파일이 아니면 건너뛰기
    if [ ! -f "${file}" ]; then
        continue
    fi

    # ex) ./tidy.sh /tmp/tidy-step5-practice

    # echo "Processing: $file"
        # Processing: /tmp/tidy-step5-case1/photo.JPG
    # echo "filename: ${file##*/}"
        # filename: photo.JPG

    extension="${file##*.}"
    # echo "extension: ${extension}"
        # extension: JPG

    # 拡張子に応じて分類先を決定する / 확장자에 따라 분류할 폴더 결정
    case ${extension,,} in
        jpg|jpeg|png|gif)
            destination="images"
            images_count=$((images_count + 1))
            ;;
        pdf|txt|md|docx)
            destination="documents"
            documents_count=$((documents_count + 1))
            ;;
        mp3|wav)
            destination="music"
            music_count=$((music_count + 1))
            ;;
        zip|gz)
            destination="archives"
            archives_count=$((archives_count + 1))
            ;;
        *)
            destination="others"
            others_count=$((others_count + 1))
            ;;
    esac

    filename="${file##*/}"

    if [ "$command_option" = "--dry-run" ]; then
        echo "[dry-run] ${filename} -> ${destination}/"
        continue
    fi

    # 分類先のディレクトリを作成する / 분류 대상 디렉터리 생성
    mkdir -p "$1"/${destination}

    # 同名のファイルが存在するか確認する / 같은 이름의 파일이 존재하는지 확인
    if [ -e "$1"/${destination}/${filename} ]; then
        # 同名のファイルが存在する場合 / 같은 이름의 파일이 존재하는 경우
            # ファイル名に連番を付けて移動する / 파일명에 일련번호를 붙여 이동한다
            # 変更後のファイル名と移動先を表示する / 변경 후의 파일명과 이동할 위치를 표시한다

        name="${filename%.*}"
        extension="${filename##*.}"

        count=1
        while true
        do
            # 拡張子の有無に応じて新しいファイル名を生成する / 확장자 유무에 따라 새로운 파일명 생성
            if [[ "$filename" == *.* ]]; then
                filenameWithCount="${name}_${count}.${extension}"
            else
                filenameWithCount="${name}_${count}"
            fi

            if [ -e "$1"/${destination}/${filenameWithCount} ]; then
                # 使用可能なファイル名が見つかるまで番号を増やす / 사용 가능한 파일명을 찾을 때까지 번호 증가
                count=$((count + 1))
            else
                # ファイル名を変更して移動する / 파일명을 변경하여 이동
                mv "$file" "$1/${destination}/$filenameWithCount"
                echo  "${filename} -> ${destination}/$filenameWithCount"
                break
            fi
        done

    # 同名のファイルが存在しない場合 / 같은 이름의 파일이 존재하지 않는 경우
    else 
        # ファイルをそのまま移動する / 파일을 그대로 이동한다
        mv "$file" "$1"/${destination}/
    fi   
done

echo "----
images: ${images_count} 件
documents: ${documents_count} 件
music: ${music_count} 件
archives: ${archives_count} 件
others: ${others_count} 件"