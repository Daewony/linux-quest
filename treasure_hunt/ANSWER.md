# 宝探し QUEST

## 1. 合言葉

**ペンギンは海を渡る**

`castle/treasure_box/open.sh` を実行して、宝箱を開いたときに確認しました。

```text
＞  宝箱が開いた！  ＜
合言葉は「ペンギンは海を渡る」だ。
```

## 2. Step 1：宝箱を開ける

以下は実際に実行した主なコマンドです。探索中は `ls` や `pwd` なども繰り返し使用しました。

```bash
bash ~/setup_treasure_hunt.sh
cd ~/treasure_hunt/
ls
cat README.txt
cd village/
ls -al
cat .secret_note
cd ..
cd forest/
ls
find -iname "map.txt"
cat ./tree_14/branch_3/hollow/map.txt
cd ..
cd cave/
ls -al
cd scrolls/
ls -al
find ./ -name "*.txt" | xargs grep "TREASURE"
cd ~/treasure_hunt/
cd castle/
ls -lhS
cat library.txt
vim library.txt
lsattr library.txt
less library.txt
cd treasure_box/
ls -al
./open.sh
chmod +x open.sh
ls -al
./open.sh
```

**実行結果と学んだこと**

- `ls -al` で通常の `ls` では見えない `.secret_note` を発見しました。
- `find` で森の中の `map.txt` を一度に探しました。
- `find` と `xargs grep` を組み合わせ、500本の巻物の中から大文字の `TREASURE` を検索しました。途中でコマンドの書き方を間違えましたが、修正して検索できました。
- `ls -lhS` でファイルをサイズの大きい順に並べ、`library.txt` を見つけました。
- 長いファイルを最初は `cat` などで調べましたが、その後 `less` を使って、開いたまま `/` でキーワードを検索する方法も確認しました。
- `open.sh` は最初そのままでは実行できませんでしたが、`chmod +x open.sh` で実行権限を追加して実行できました。

## 3. Step 2：宝の持ち帰りと後片付け

以下は実際の作業で実行した主なコマンドです。最初は `home` を `/root/home` に作ってしまったため、あとで正しい場所に移動しました。また、シンボリックリンクの作成も失敗した後に修正しました。

```bash
# 当初 /root/home で作業
cp ~/treasure_hunt/castle/treasure_box/open.sh ~/home/my_treasure.sh
ls
ln -s my_treasure.sh treasure_link.sh
ln -s ./my_treasure.sh treasure_link.sh
./treasure_link.sh
ls -al
rm treasure_link.sh
ln -s ./my_treasure.sh treasure_link.sh
ls -al
./treasure_link.sh
touch diary.txt
vim diary.txt
cat diary.txt

# forest の削除
cd ~/treasure_hunt/forest/
ls
cd ..
rm -r forest/
ls
ls -R

# home の場所を修正して、隠しファイルも含めて一覧表示
cd ~
mv home treasure_hunt/
cd treasure_hunt/
ls -alR
```

**実行結果**

- `my_treasure.sh` をコピーしました。
- シンボリックリンクの作成時に誤ったリンク先を設定してしまい、最初は実行できませんでした。リンクを作り直したところ、`./treasure_link.sh` で宝箱を開けました。
- `diary.txt` に `It's fun!` と書き込みました。
- `rm -r forest/` で `forest` を中身ごと削除しました。
- `home` を `~/treasure_hunt/home` に移動し、`ls -alR` で隠しファイルも含めて確認しました。

### Step 2-6：`ls -alR` の出力結果（一部）

```text
.:
total 28
drwxr-xr-x 6 root root 4096 Oct 16 16:02 .
drwx------ 1 root root 4096 Oct 16 16:02 ..
-rw-r--r-- 1 root root  239 Oct 16 14:46 README.txt
drwxr-xr-x 3 root root 4096 Oct 16 15:02 castle
drwxr-xr-x 3 root root 4096 Oct 16 14:46 cave
drwxr-xr-x 2 root root 4096 Oct 16 15:53 home
drwxr-xr-x 7 root root 4096 Oct 16 14:46 village

./castle:
total 204
drwxr-xr-x 3 root root   4096 Oct 16 15:02 .
drwxr-xr-x 6 root root   4096 Oct 16 16:02 ..
-rw-r--r-- 1 root root   2280 Oct 16 14:46 armory.txt
-rw-r--r-- 1 root root   2301 Oct 16 14:46 dungeon.txt
-rw-r--r-- 1 root root   2145 Oct 16 14:46 kitchen.txt
-rw-r--r-- 1 root root 178991 Oct 16 14:46 library.txt
-rw-r--r-- 1 root root   2537 Oct 16 14:46 throne_room.txt
drwxr-xr-x 2 root root   4096 Oct 16 14:46 treasure_box

./castle/treasure_box:
total 12
drwxr-xr-x 2 root root 4096 Oct 16 14:46 .
drwxr-xr-x 3 root root 4096 Oct 16 15:02 ..
-rwxr-xr-x 1 root root  363 Oct 16 14:46 open.sh
```

500本の巻物の表示は省略しました。最終的な一覧では、`./home` に `diary.txt`、`my_treasure.sh`、`treasure_link.sh` があり、`./village` に隠しファイル `.secret_note` が表示されていました。また、`forest` は表示されなくなりました。

## 4. Step 3：振り返り

### 質問1：OSとLinuxとは何ですか

OS（オペレーティングシステム）とは、CPU、メモリ、ストレージなどのコンピューターの資源を管理し、アプリケーションがそれらを利用できるようにするソフトウェアです。

LinuxはOSの中心となるカーネルの一つで、一般的にはLinuxカーネルを使ったOS全体を指すこともあります。Linuxはサーバーや開発環境などで広く使われています。

### 質問2：カーネルとディストリビューションとは何ですか。現在使っているディストリビューションは何ですか

カーネルとは、OSの中心となるソフトウェアで、CPUやメモリなどのハードウェア資源を管理する役割を持っています。

Linuxディストリビューションとは、Linuxカーネルにさまざまなソフトウェアや管理ツールを組み合わせ、実際に利用できるようにしたOSです。

現在使っているDockerコンテナのディストリビューションは **Ubuntu 26.04.1 LTS** です。`cat /etc/os-release` を実行し、`PRETTY_NAME="Ubuntu 26.04.1 LTS"` と表示されることを確認しました。

### 質問3：シェルとは何ですか。現在使っているシェルは何ですか

シェルとは、ユーザーが入力したコマンドを解釈し、プログラムの実行などを行うソフトウェアです。ターミナルはコマンドを入力して結果を確認するための画面であり、シェルとは役割が異なります。

現在使っているシェルは **Bash** です。`echo $SHELL` で `/bin/bash`、`ps -p $$ -o comm=` で `bash` と表示されることを確認しました。

### 質問4：絶対パスと相対パス、`~`・`.`・`..` の意味は何ですか

絶対パスは、ルートディレクトリ（`/`）から始まるパスで、現在の作業ディレクトリに関係なく場所を指定できます。

相対パスは、現在の作業ディレクトリを基準にして場所を指定するパスです。

`~` は現在のユーザーのホームディレクトリ、`.` は現在のディレクトリ、`..` は一つ上の親ディレクトリを表します。

### 質問5：ファイルを探すために使った2つのコマンドは、それぞれどのような場面で使いますか

`find` は、ファイルやディレクトリを名前や条件に基づいて探すときに使うコマンドです。

`grep` は、ファイルの中から特定の文字列やパターンを含む行を探すときに使うコマンドです。

今回のQUESTでは、`find` で森の中から `map.txt` を探し、`grep` で500本の巻物から大文字の `TREASURE` という文字列を探しました。
