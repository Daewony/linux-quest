# お片付けスクリプト

## ステップ4〜8の実行結果

### テスト環境について

各ステップの動作確認には、`mktemp -d` コマンドで作成した一時ディレクトリを使用しました。

例えば、以下のコマンドを実行すると、一時ディレクトリが作成され、そのパスが `TEST4` という変数に保存されます。

```bash
TEST4=$(mktemp -d /tmp/tidy-step4.XXXXXX)
```

- `mktemp -d`：一時ディレクトリを作成します。
- `XXXXXX`：重複しないように、異なる文字列に置き換えられます。
- `$(...)`：コマンドの出力結果を取得します。
- `TEST4=...`：取得したディレクトリのパスを変数に保存します。

また、`touch` や `printf` を使ってテスト用のファイルを作成しました。

既存のファイルに影響を与えないように、各ステップで別々のテストディレクトリを使用しました。

なお、ステップ4と5については、Gitでそれぞれのステップを完了した時点のコミットに切り替えて動作を確認しました。

---

### ステップ4：引数で対象ディレクトリを指定する

ディレクトリを引数で指定し、そのディレクトリ内のファイルが正しく分類されることを確認しました。

#### テスト環境の準備

```bash
TEST4=$(mktemp -d /tmp/tidy-step4.XXXXXX)

touch "$TEST4/photo.JPG" "$TEST4/report.pdf"
```

`photo.JPG` と `report.pdf` の2つのファイルを作成しました。

#### 正常な場合

**実行コマンド**

```bash
./tidy.sh "$TEST4"
find "$TEST4" -print | sort
```

**実行結果**

```text
photo.JPG -> images/
report.pdf -> documents/
/tmp/tidy-step4.83ztnT
/tmp/tidy-step4.83ztnT/documents
/tmp/tidy-step4.83ztnT/documents/report.pdf
/tmp/tidy-step4.83ztnT/images
/tmp/tidy-step4.83ztnT/images/photo.JPG
```

画像ファイルは `images/`、文書ファイルは `documents/` に分類されることを確認しました。

#### 引数を指定しなかった場合

**実行コマンド**

```bash
./tidy.sh
echo $?
```

**実行結果**

```text
使い方: ./tidy.sh ディレクトリ
1
```

#### 存在しないディレクトリを指定した場合

**実行コマンド**

```bash
./tidy.sh ~/no_such_dir
echo $?
```

**実行結果**

```text
エラー: /root/no_such_dir はディレクトリではありません
1
```

引数が指定されていない場合と、存在しないディレクトリが指定された場合に、エラーメッセージを表示し、終了ステータス `1` で終了することを確認しました。

---

### ステップ5：同名ファイルの上書きを防止する

移動先に同じ名前のファイルが存在する場合、ファイル名に連番を付け、既存のファイルを上書きせずに移動できることを確認しました。

#### テスト環境の準備

```bash
TEST5=$(mktemp -d /tmp/tidy-step5.XXXXXX)

mkdir -p "$TEST5/images"

printf 'old\n' > "$TEST5/images/photo.JPG"
printf 'new\n' > "$TEST5/photo.JPG"
```

最初に、以下のようなファイル構成を作成しました。

```text
テストディレクトリ/
├── photo.JPG
└── images/
    └── photo.JPG
```

`images/photo.JPG` には `old`、移動する `photo.JPG` には `new` という内容を書き込みました。

#### 実行コマンド

```bash
./tidy.sh "$TEST5"
find "$TEST5" -print | sort
```

#### 実行結果

```text
photo.JPG -> images/photo_1.JPG
/tmp/tidy-step5.KVhS6j
/tmp/tidy-step5.KVhS6j/images
/tmp/tidy-step5.KVhS6j/images/photo.JPG
/tmp/tidy-step5.KVhS6j/images/photo_1.JPG
```

#### ファイル内容の確認

**実行コマンド**

```bash
cat "$TEST5/images/photo.JPG"
cat "$TEST5/images/photo_1.JPG"
```

**実行結果**

```text
old
new
```

既存の `photo.JPG` は上書きされず、新しいファイルが `photo_1.JPG` として保存されることを確認しました。

また、両方のファイルの内容が正しく保持されていることも確認しました。

---

### ステップ6：dry-runモードを実装する

`--dry-run` オプションを指定すると、実際にはファイルの移動やディレクトリの作成を行わず、分類予定の結果だけを表示するようにしました。

#### テスト環境の準備

```bash
TEST2=$(mktemp -d /tmp/tidy-drycheck.XXXXXX)

printf 'test\n' > "$TEST2/sample.txt"
```

`sample.txt` を作成し、実行前後でファイルの配置が変化するか確認しました。

#### dry-runモードの確認

**実行コマンド**

```bash
find "$TEST2" -print | sort

./tidy.sh --dry-run "$TEST2"

find "$TEST2" -print | sort
```

**実行結果**

```text
/tmp/tidy-drycheck.PKZSgs
/tmp/tidy-drycheck.PKZSgs/sample.txt
[dry-run] sample.txt -> documents/
/tmp/tidy-drycheck.PKZSgs
/tmp/tidy-drycheck.PKZSgs/sample.txt
```

実行前後でファイルの配置は変わらず、`documents/` ディレクトリも作成されていないことを確認しました。

#### 通常モードの確認

**実行コマンド**

```bash
./tidy.sh "$TEST2"
find "$TEST2" -print | sort
```

**実行結果**

```text
/tmp/tidy-drycheck.PKZSgs
/tmp/tidy-drycheck.PKZSgs/documents
/tmp/tidy-drycheck.PKZSgs/documents/sample.txt
```

通常モードでは、`documents/` ディレクトリが作成され、`sample.txt` が移動されることを確認しました。

---

### ステップ7：カテゴリ別のファイル数を集計する

ファイルを分類するときに、カテゴリごとのカウンターを増やし、処理が終わった後に集計結果を表示するようにしました。

#### テスト環境の準備

```bash
TEST7=$(mktemp -d /tmp/tidy-step7.XXXXXX)

touch "$TEST7/a.jpg" "$TEST7/b.PNG" \
      "$TEST7/c.pdf" "$TEST7/d.txt" \
      "$TEST7/e.mp3" "$TEST7/f.zip" \
      "$TEST7/g"
```

合計7つのファイルを作成しました。

- 画像：2件
- 文書：2件
- 音楽：1件
- 圧縮ファイル：1件
- その他：1件

#### dry-runモードの確認

**実行コマンド**

```bash
./tidy.sh --dry-run "$TEST7"
```

**実行結果**

```text
[dry-run] a.jpg -> images/
[dry-run] b.PNG -> images/
[dry-run] c.pdf -> documents/
[dry-run] d.txt -> documents/
[dry-run] e.mp3 -> music/
[dry-run] f.zip -> archives/
[dry-run] g -> others/
----
images: 2 件
documents: 2 件
music: 1 件
archives: 1 件
others: 1 件
```

#### 通常モードの確認

**実行コマンド**

```bash
./tidy.sh "$TEST7"
```

**実行結果**

```text
----
images: 2 件
documents: 2 件
music: 1 件
archives: 1 件
others: 1 件
```

dry-runモードと通常モードの両方で、正しく集計されることを確認しました。

#### 分類済みディレクトリでの再実行

**実行コマンド**

```bash
./tidy.sh "$TEST7"
```

**実行結果**

```text
----
images: 0 件
documents: 0 件
music: 0 件
archives: 0 件
others: 0 件
```

すでにファイルが分類されている場合は、新しく処理するファイルがないため、すべてのカウントが `0` になることを確認しました。

---

### ステップ8：どこからでも tidy コマンドを実行する

環境変数 `PATH` に登録されている `/usr/local/bin` に、元のスクリプトを指すシンボリックリンクを作成しました。

#### シンボリックリンクの作成

**実行コマンド**

```bash
ln -s /work/tidy_up/tidy.sh /usr/local/bin/tidy
```

#### リンクの確認

**実行コマンド**

```bash
command -v tidy
ls -l /usr/local/bin/tidy
```

**実行結果**

```text
/usr/local/bin/tidy
lrwxrwxrwx 1 root root 21 Oct 28 17:46 /usr/local/bin/tidy -> /work/tidy_up/tidy.sh
```

`/usr/local/bin/tidy` が元の `/work/tidy_up/tidy.sh` を指していることを確認しました。

#### lsコマンドの場所の確認

**実行コマンド**

```bash
type -a ls
type -P ls
```

**実行結果**

```text
ls is aliased to `ls --color=auto'
ls is /usr/bin/ls
ls is /bin/ls
/usr/bin/ls
```

現在のBashでは `ls` がエイリアスとして設定されており、実行ファイルは `/usr/bin/ls` から見つかることを確認しました。

#### 別のディレクトリからの実行

**実行コマンド**

```bash
cd /tmp
pwd
command -v tidy
tidy --dry-run "$TEST7"
```

**実行結果**

```text
/tmp
/usr/local/bin/tidy
----
images: 0 件
documents: 0 件
music: 0 件
archives: 0 件
others: 0 件
```

元のスクリプトがあるディレクトリとは異なる場所からでも、`tidy` コマンドを実行できることを確認しました。

#### 新しいBashからの実行

Macのターミナルから、同じDockerコンテナに新しいBashで接続して確認しました。

**実行コマンド（Mac側）**

```bash
docker exec -it f612f4a7cbfd bash
```

**実行コマンド（Dockerコンテナ内）**

```bash
command -v tidy
tidy --dry-run /work/tidy_up
```

**実行結果**

```text
/usr/local/bin/tidy
[dry-run] tidy.sh -> others/
----
images: 0 件
documents: 0 件
music: 0 件
archives: 0 件
others: 1 件
```

新しいBashからでも `tidy` コマンドを実行できることを確認しました。

今回は、すでに `PATH` に登録されている `/usr/local/bin` を利用したため、`PATH` の設定を追加する必要はありませんでした。

---

## ステップ10：振り返り

### Q1. シェルスクリプトの1行目に書く `#!/bin/bash` は何のためにありますか

`#!/bin/bash` は「シバン」と呼ばれ、スクリプトを直接実行するときに、どのインタープリターを使用するかを指定するためのものです。

この場合は、Bashを使ってスクリプトを実行するように指定しています。

例えば、`bash tidy.sh` のように実行する場合は、すでにBashを指定しているため、シバンによるインタープリターの指定は必要ありません。

### Q2. スクリプトに渡された引数と、その数は、どのようにして取得しましたか

スクリプトに渡された引数は、`$1`、`$2` などを使って取得しました。

`$1` は1つ目の引数、`$2` は2つ目の引数を表します。また、引数の数は `$#` で取得できます。

今回のスクリプトでは、`--dry-run` オプションが指定された場合に `shift 1` を使い、先頭の引数を取り除きました。

これにより、元の2つ目の引数を `$1` として扱えるようにしました。

### Q3. ファイル名にスペースが含まれるファイルを正しく扱うために、どのような工夫をしましたか。工夫しないとどんな問題が起きましたか

ファイル名やディレクトリ名にスペースが含まれていても正しく処理できるように、`"$file"` や `"$1"` のように変数をダブルクォーテーションで囲みました。

ダブルクォーテーションで囲まないと、Bashがスペースの部分で文字列を分割してしまい、1つのファイル名が複数の引数として扱われることがあります。

その結果、ファイルが見つからなかったり、正しく移動できなかったりする問題が発生します。

### Q4. 終了ステータスとは何ですか。なぜエラーのときに `0` 以外の値で終了すべきなのですか

終了ステータスとは、コマンドやスクリプトが終了したときに、その実行結果を示す数値です。

一般的に、`0` は正常終了、`0` 以外の値はエラーなどを表します。また、エラーの種類によって異なる数値を使うこともできます。

エラーが発生したときに `0` 以外の値で終了する理由は、他のプログラムやスクリプトが処理の成功・失敗を正しく判断できるようにするためです。

### Q5. ステップ8は、どのような仕組みで実現しましたか。環境変数 `PATH` という言葉を使って説明してください

ステップ8では、環境変数 `PATH` とシンボリックリンクを利用しました。

`PATH` は、コマンドを実行するときに、実行ファイルを探すディレクトリを指定する環境変数です。

今回は、すでに `PATH` に登録されている `/usr/local/bin` に、元のスクリプト `/work/tidy_up/tidy.sh` を指すシンボリックリンク `tidy` を作成しました。

これにより、どのディレクトリからでも `tidy` というコマンドでスクリプトを実行できるようになりました。

また、新しいBashからも実行できることを確認しました。
