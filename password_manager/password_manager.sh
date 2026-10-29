#!/bin/bash
echo "パスワードマネージャーへようこそ！"

read -p "サービス名を入力してください： " service_name
read -p "ユーザー名を入力してください： " user_name
read -p "パスワードを入力してください： " password

echo "${service_name}:${user_name}:${password}" >> password.txt

echo "Thank you!"