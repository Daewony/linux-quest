# Git タイムマシン

## Step 1：Git の初期設定

### 実行したコマンドと結果

**1. Git のバージョン確認**

```bash
git --version
```

```text
git version 2.53.0
```

**2. ユーザー名の設定と確認**

```bash
git config --global user.name "kangdaewon"
git config --global user.name
```

```text
kangdaewon
```

**3. メールアドレスの設定と確認**

```bash
git config --global user.email "kangdaewon.training@gmail.com"
git config --global user.email
```

```text
kangdaewon.training@gmail.com
```

**4. デフォルトブランチ名の設定と確認**

```bash
git config --global init.defaultBranch main
git config --global init.defaultBranch
```

```text
main
```

## Step 2：リポジトリの作成と README の追加

### 1. リポジトリの作成

**実行したコマンド**

```bash
pwd
git init
git status
ls -a
```

**実行結果（主な部分）**

```text
/work
Initialized empty Git repository in /work/.git/
On branch main
No commits yet
nothing to commit (create/copy files and use "git add" to track)
.  ..  .git
```

### 2. README.md の作成

**実行したコマンド**

```bash
touch README.md
git status
vim README.md
cat README.md
```

**ファイル作成直後の `git status`**

```text
On branch main
No commits yet
Untracked files:
    README.md
nothing added to commit but untracked files present (use "git add" to track)
```

**`cat README.md` の実行結果**

```text
# linux-quest

カン・デウォンの Linux QUEST の提出用リポジトリです。

## 自己紹介

- 名前：カン・デウォン
- 好きなもの：散歩、カツ丼

## ステータス

研修を始めました
```

### 3. ステージへの追加とコミット

**実行したコマンド**

```bash
git status
git add README.md
git status
git commit -h
git commit -m "README を追加"
git status
```

**`git add README.md` 後の `git status`**

```text
On branch main
No commits yet
Changes to be committed:
    new file: README.md
```

`git commit -h` では、コミット用のヘルプが表示され、`-m` がコミットメッセージを指定するオプションだと確認できました。

**コミット結果**

```text
[main (root-commit) 7283bf5] README を追加
 1 file changed, 12 insertions(+)
 create mode 100644 README.md
```

**コミット後の `git status`**

```text
On branch main
nothing to commit, working tree clean
```

### 4. 質問への回答：README.md の状態の変化

| タイミング         | `git status` の表示                     | 意味                                           |
| ------------------ | --------------------------------------- | ---------------------------------------------- |
| README.md 作成直後 | `Untracked files`                       | Git に追跡されていない状態                     |
| `git add` 後       | `Changes to be committed`               | ステージに追加された状態                       |
| `git commit` 後    | `nothing to commit, working tree clean` | 変更がコミットされ、未コミットの変更がない状態 |

## Step 3：変更の記録と Git コマンドの練習

### 1. learning_log.md の作成とコミット

**実行したコマンド**

```bash
touch learning_log.md
vim learning_log.md
cat learning_log.md
git status
git add .
git commit -m "学習日記を追加"
git status
```

**`cat learning_log.md` の実行結果**

```text
# 学習日記
- git status を使って、ファイルの状態を確認する方法を学びました。
- Vimで日本語が文字化けしたときは、UTF-8の設定を確認する必要があると学びました。
- git add は変更をステージに追加し、git commit はその変更を履歴に記録するコマンドだと復習しました。
- Gitの操作を写真撮影に例えると、add は写真に写る人を選び、commit は写真を撮ってアルバムに保存することだと考えました。
```

**`git add .` の前の `git status`**

```text
On branch main
Untracked files:
    learning_log.md
nothing added to commit but untracked files present (use "git add" to track)
```

**コミット結果**

```text
[main cd8790d] 学習日記を追加
 1 file changed, 5 insertions(+)
 create mode 100644 learning_log.md
```

**コミット後の `git status`**

```text
On branch main
nothing to commit, working tree clean
```

### 2. README.md の変更と差分の確認

**実行したコマンド**

```bash
git diff
vim README.md
git diff
git status
git add README.md
git status
git diff
git diff -h
git diff --cached
git commit -m "好きなものを変更"
git status
```

最初の `git diff` は何も表示されませんでした。README.md を編集した後、`git diff` に次の変更が表示されました。

```diff
- 好きなもの：散歩、カツ丼
+ 好きなもの：散歩
```

**`git add README.md` の前の `git status`**

```text
On branch main
Changes not staged for commit:
    modified: README.md
no changes added to commit (use "git add" and/or "git commit -a")
```

**`git add README.md` の後の `git status`**

```text
On branch main
Changes to be committed:
    modified: README.md
```

この時点で再び実行した `git diff` には何も表示されませんでした。一方、`git diff --cached` には上記の README.md の変更が表示されました。`git diff -h` ではオプションのヘルプを確認しました。

**コミット結果**

```text
[main f7296e8] 好きなものを変更
 1 file changed, 1 insertion(+), 1 deletion(-)
```

**コミット後の `git status`**

```text
On branch main
nothing to commit, working tree clean
```

### 3. 質問への回答：ステージに追加する前と後の違い

`git diff` は、作業ディレクトリとステージの差分を表示します。`git add README.md` の前は README.md の変更が表示されましたが、`git add` の後は両方の内容が同じになったため、何も表示されませんでした。

一方、`git diff --cached` はステージと最後のコミットの差分を表示するため、ステージに追加した README.md の変更を確認できました。

### 4. 質問への回答：新しい learning_log.md の表示について

`learning_log.md` は作成直後、Git に追跡されていない `Untracked` の状態でした。`git diff` は追跡されていない新規ファイルの内容を通常表示しません。ステージに追加すると、`git diff --cached` で新しいファイルの内容を確認できます。

※ 実際のターミナル記録では、`learning_log.md` が Untracked の時点で `git diff` を実行した記録はありません。この説明は Git の動作についての回答です。

### 5. コミット履歴の確認

**実行したコマンド**

```bash
git log
git log --oneline
git show
```

**`git log --oneline` の実行結果（Step 3 終了時点）**

```text
f7296e8 (HEAD -> main) 好きなものを変更
cd8790d 学習日記を追加
7283bf5 README を追加
```

※ これは Step 3 の時点の履歴です。QUEST で求められている「最終的なコミット履歴」は Step 6 まで終わってから、別途記録します。

**`git show` の実行結果（主な変更部分）**

```diff
- 好きなもの：散歩、カツ丼
+ 好きなもの：散歩
```

`git log --oneline` ではコミットの履歴を一行ずつ確認しました。`git show` では、最新コミットの変更内容を確認しました。

---

## Step 4：上書きしてしまった README.md の復元

### 1. 作業前の状態確認

**実行したコマンド**

```bash
git status
git diff -- learning_log.md
```

**確認した結果**

```text
On branch main
Changes not staged for commit:
        modified:   learning_log.md
Untracked files:
        time_machine/
```

`learning_log.md` は見出しの後に空行が1行追加されていました。`time_machine/` はまだ Git に追跡されていない状態でした。

### 2. README.md を上書きして変更内容を確認

**実行したコマンド**

```bash
echo "Linux の QUEST を始めました" > README.md
git diff README.md
git status
```

**`git diff README.md` の結果（主な部分）**

```diff
@@ -1,12 +1 @@
-# linux-quest
-
-カン・デウォンの Linux QUEST の提出用リポジトリです。
-
-## 自己紹介
-
-- 名前：カン・デウォン
-- 好きなもの：散歩
-
-## ステータス
-
-研修を始めました
```

**`git status` の結果（該当部分）**

```text
Changes not staged for commit:
        modified:   README.md
        modified:   learning_log.md
Untracked files:
        time_machine/
```

`>` で README.md を上書きしたため、以前の自己紹介などが消えてしまいました。`git diff` では、元の README.md の12行が削除されたことを確認しました。

### 3. README.md の復元

**実行したコマンド**

```bash
git restore -h
git restore README.md
cat README.md
git diff README.md
git status
```

Web 検索で `git restore` の使い方を調べ、`git restore -h` でもオプションを確認したうえで、`README.md` だけを復元しました。

**`cat README.md` の実行結果**

```text
# linux-quest

カン・デウォンの Linux QUEST の提出用リポジトリです。

## 自己紹介

- 名前：カン・デウォン
- 好きなもの：散歩

## ステータス

研修を始めました
```

復元後の `git diff README.md` には何も表示されませんでした。

**復元後の `git status`（主な部分）**

```text
On branch main
Changes not staged for commit:
        modified:   learning_log.md
Untracked files:
        time_machine/
```

README.md は最後のコミットと同じ内容に戻り、変更一覧から消えました。`learning_log.md` や `time_machine/` の内容には影響しませんでした。

---

## Step 5：間違ってステージしたファイルを直す

### 1. 実験用ファイルの作成

**実行したコマンド**

```bash
mkdir tmp
echo "作業用のメモ" > tmp/memo.txt
echo "debug info" > debug.log
echo "GitHub のパスワード: hogehoge" > secret.txt
git status
```

**実行結果（主な部分）**

```text
Changes not staged for commit:
        modified:   learning_log.md
Untracked files:
        debug.log
        secret.txt
        time_machine/
        tmp/
```

### 2. ステージに追加して状態を確認

**実行したコマンド**

```bash
git add .
git status
```

**実行結果**

```text
On branch main
Changes to be committed:
        new file:   debug.log
        modified:   learning_log.md
        new file:   secret.txt
        new file:   time_machine/ANSWER.md
        new file:   tmp/memo.txt
```

`git add .` では、必要のないファイルも一緒にステージに追加されました。

### 3. 必要のないファイルをステージから外す

**実際に確認した操作**

```bash
git restore --staged tmp debug.log secret.txt
git status
git restore --staged time_machine/
git status
```

**最後の `git status` の結果**

```text
On branch main
Changes to be committed:
        modified:   learning_log.md
Untracked files:
        debug.log
        secret.txt
        time_machine/
        tmp/
```

ファイルを削除せず、ステージから外すことができました。提出用の `time_machine/ANSWER.md` もこの段階ではコミットしないため、ステージから外しました。

### 4. 学習日記をコミット

**実行したコマンド・確認した結果**

```bash
git commit -m "学習日記を更新"
git status
git show b28e51f
```

```text
[main b28e51f] 学習日記を更新
 1 file changed, 1 insertion(+)
```

`git show b28e51f` で、このコミットでは `# 学習日記` の後に空行が1行追加されただけだと気づきました。VS Code で書いた 10月13日の学習内容を保存し忘れていたため、保存してから再度確認しました。

**保存後に確認した学習内容（主な部分）**

```text
# 学習日記

### 2026.10.13

- git restore を使って、README.md の変更を元に戻す方法を学びました。

### 2026.10.08
```

新しい内容は、後で以下のコミットとして記録したことを `git log --oneline` で確認しました。

```text
ef67f75 Gitの復元操作の学習記録を追加
```

※ この追加コミットの入力コマンド全文・実行直後の出力は共有されたログに残っていないため、ここには履歴から確認できる事実だけを記載します。

### 5. `.gitignore` を作成してコミット

**実行・確認したコマンド**

```bash
git rev-parse --show-toplevel
touch .gitignore
git status
git add .gitignore
git status
git commit -m "Gitの除外設定を追加"
git status
```

**リポジトリの場所**

```text
/work
```

**`.gitignore` に設定した内容**

```gitignore
tmp/
*.log
secret.txt
```

**設定後の `git status`（コミット前）**

```text
On branch main
Untracked files:
        .gitignore
        time_machine/
```

`tmp/`、`debug.log`、`secret.txt` は一覧に出なくなりました。ファイル自体は削除していません。

**`.gitignore` をステージした後の状態**

```text
Changes to be committed:
        new file:   .gitignore
Untracked files:
        time_machine/
```

**コミット結果**

```text
[main 754f7d8] Gitの除外設定を追加
 1 file changed, 3 insertions(+)
 create mode 100644 .gitignore
```

**コミット後の `git status`**

```text
On branch main
Untracked files:
        time_machine/
nothing added to commit but untracked files present
```

### 6. 質問への回答：秘密情報をコミットして GitHub に push したらどうなるか

パスワードや AWS のアクセスキーが他人に見られ、悪用される可能性があります。不正アクセスや金銭的な被害につながる危険があります。また、ファイルを削除しても Git の履歴に残るため、注意が必要です。実際の秘密情報を公開してしまった場合は、その情報を無効にして再発行する必要があります。

---

## Step 6：コミットを取り消す

### 1. README.md の自己紹介削除とステータス変更

**実行した主なコマンド**

```bash
cat README.md
vim README.md
cat README.md
vim README.md
cat README.md
git status
git add README.md
```

最初は誤って見出しを `## Git を練習中` に変更してしまいました。ステージの状態を調べ、次のコマンドも実行しました。

```bash
git restore README.md
git status
git restore --staged README.md
git status
vim README.md
cat README.md
```

**修正後の README.md**

```text
# linux-quest

カン・デウォンの Linux QUEST の提出用リポジトリです。

## ステータス

Git を練習中
```

**コミット前に実行したコマンド**

```bash
git add README.md
git diff
git diff --cached
```

`git diff` には何も表示されず、`git diff --cached` で次の変更を確認しました。

```diff
-## 自己紹介
-
-- 名前：カン・デウォン
-- 好きなもの：散歩
-
 ## ステータス

-研修を始めました
+Git を練習中
```

**コミット・履歴確認**

```bash
git commit -m "README を整理"
git log --oneline
git show 7dce18b
```

**確認結果**

```text
7dce18b (HEAD -> main) README を整理
754f7d8 Gitの除外設定を追加
...
```

`git show 7dce18b` で自己紹介の削除とステータス変更が同じコミットに含まれていることを確認しました。

### 2. 履歴を残して変更を取り消す

**実行したコマンド**

```bash
git revert HEAD
git log --oneline
cat README.md
```

`git revert HEAD` の実行時には Vim が開き、デフォルトのメッセージを確認して保存しました。

**コミット結果**

```text
[main 029f985] Revert "README を整理"
 1 file changed, 6 insertions(+), 1 deletion(-)
```

**履歴の先頭部分**

```text
029f985 (HEAD -> main) Revert "README を整理"
7dce18b README を整理
754f7d8 Gitの除外設定を追加
```

**復元後の README.md**

```text
# linux-quest

カン・デウォンの Linux QUEST の提出用リポジトリです。

## 自己紹介

- 名前：カン・デウォン
- 好きなもの：散歩

## ステータス

研修を始めました
```

### 3. ステータスだけを別コミットで変更

**実行したコマンド**

```bash
vim README.md
cat README.md
git diff
git add README.md
git commit -m "READMEのステータスを更新"
git show
git log --oneline
```

README.md だけをステージしてコミットしました。

**コミット結果**

```text
[main eeed704] READMEのステータスを更新
 1 file changed, 1 insertion(+), 1 deletion(-)
```

**`git show` で確認した変更部分**

```diff
 ## ステータス

-研修を始めました
+Git を練習中
```

自己紹介を残したまま、ステータスだけを変更できました。

### 4. 質問への回答：revert の後、README.md はどうなったか

`git revert` により、消した自己紹介が戻り、ステータスも `研修を始めました` に戻りました。元の `README を整理` コミットは消えず、その変更を取り消した新しいコミットが追加されました。

### 5. 質問への回答：なぜ目的の違う変更をまとめないほうがよいか

1つのコミットには、できるだけ1つの目的の変更を入れるとよいと思います。何を変更したのか分かりやすく、問題が起きたときに必要な変更だけを取り消しやすいからです。Step 6では、自己紹介の削除とステータス変更を同じコミットにしたため、revert すると両方が戻りました。

---

## Step 7：振り返り

### 1. Git は何のために使うか

Git は、ファイルの変更履歴を管理するためのツールです。ゲームで大切な場面をセーブするように、変更をコミットとして記録できます。後から何が変わったのか調べたり、ミスをしたときに以前の状態に戻したりできます。

### 2. 作業ディレクトリ・ステージ・リポジトリとは何か／add・commit は何をするか

- **作業ディレクトリ（Working Tree）**：実際にファイルを編集する場所です。
- **ステージ（Staging Area）**：次のコミットに入れる変更を準備する場所です。`git add` で変更を追加します。
- **リポジトリ（Repository）**：`git commit` で記録した変更履歴を保管する場所です。

写真に例えると、`git add` は写真に入る人を選ぶこと、`git commit` は写真を撮って自分のアルバムに保存することです。`git push` は、その記録を GitHub などのリモートリポジトリへ送る別の操作です。

### 3. なぜステージが必要なのか

ステージは、今回コミットする変更を選ぶために必要です。必要な変更だけを選べるので、不要なファイルをコミットするミスを防ぎやすくなります。Step 5 では、`secret.txt` などをステージから外して、必要な `learning_log.md` の変更だけをコミットできました。

### 4. 良いコミットとは何か

1つのコミットには、できるだけ1つの目的に関係する変更を記録するとよいと思います。変更の理由が分かりやすく、問題があったときに必要な部分だけを戻しやすいからです。1つの目的のために複数ファイルを変更する場合は、同じコミットにまとめてもよいと思います。

### 5. どんなファイルを `.gitignore` に入れるとよいか、その理由は何か

`.gitignore` には、パスワードなどの秘密情報、ログ、作業用の一時ファイルなど、Git で管理する必要がないファイルを登録するとよいと思います。不要なファイルのコミットを防ぎ、情報漏えいの危険を減らせるからです。Step 5 では、`secret.txt`、`debug.log`、`tmp/` を除外しました。ただし、すでに Git が追跡しているファイルは `.gitignore` だけでは追跡を解除できません。

---

## Step 1〜6 終了後のコミット履歴

**実行したコマンド**

```bash
git log --oneline
```

**実行結果（Step 6 終了時点）**

```text
eeed704 (HEAD -> main) READMEのステータスを更新
029f985 Revert "README を整理"
7dce18b README を整理
754f7d8 Gitの除外設定を追加
ef67f75 Gitの復元操作の学習記録を追加
b28e51f 学習日記を更新
f7296e8 好きなものを変更
cd8790d 学習日記を追加
7283bf5 README を追加
```

※ 上記は `time_machine/ANSWER.md` をコミットする**前**に確認した履歴です。ANSWER.md をコミットすると、新しいコミットが履歴の先頭に追加されます。

## 生成 AI の利用について

分からない Git の考え方やオプションの意味を質問し、自分で実行したコマンドの結果を確認・振り返るために AI を利用しました。また、実際のターミナル記録と自分の回答をもとに、この `ANSWER.md` の文章整理を手伝ってもらいました。QUEST の操作は自分で行い、回答内容は確認しました。
