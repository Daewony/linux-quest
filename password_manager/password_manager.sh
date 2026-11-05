#!/bin/bash
echo "パスワードマネージャーへようこそ！"

while true
do
  read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" command

  case "${command}" in
    "Add Password")
      read -p "サービス名を入力してください：" service_name
      read -p "ユーザー名を入力してください：" user_name
      read -p "パスワードを入力してください：" password

      echo "${service_name}:${user_name}:${password}" >> password.txt
      echo "パスワードの追加は成功しました。"
      ;;
    "Get Password")
      read -p "サービス名を入力してください：" input_service_name

      hasServiceNameData="false"

      # コロン区切りで保存された情報を1行ずつ読み込む
      while IFS=':' read -r saved_service saved_user saved_password; do
        if [ "$saved_service" == "$input_service_name" ]; then
          hasServiceNameData="true"
          echo "サービス名: $saved_service"
          echo "ユーザー名: $saved_user"
          echo "パスワード: $saved_password"
        fi
      done < password.txt

      if [ "${hasServiceNameData}" == "false" ]; then
        echo "そのサービスは登録されていません。"
      fi
      ;;
    "Exit")
      break
      ;;
    *)
      echo "入力が間違えています。 (Add Password/Get Password/Exit)から入力してください。"
      ;;
  esac

done

echo "Thank you!"