# ひとりチーム開発

## GitHubリポジトリ

https://github.com/Daewony/linux-quest

## プルリクエスト

- Step 4： https://github.com/Daewony/linux-quest/pull/1
- Step 5： https://github.com/Daewony/linux-quest/pull/2
- Step 6（チームメンバー）： https://github.com/Daewony/linux-quest/pull/3
- Step 6（自分・コンフリクト解決）： https://github.com/Daewony/linux-quest/pull/4

## Step 1〜6：実行したコマンドと結果

### Step 1：GitHubとSSHで接続する

**実行した主なコマンド**

```bash
ssh-keygen -t ed25519 -C "kangdaewon.training@gmail.com"
ssh -T git@github.com
```

**実行結果**

- 秘密鍵 `id_ed25519` と公開鍵 `id_ed25519.pub` を作成した。
- 公開鍵をGitHubに登録した。
- SSH認証では、次のメッセージが表示された。

```text
Hi Daewony! You've successfully authenticated, but GitHub does not provide shell access.
```

- 秘密鍵のパーミッションは `600`、公開鍵は `644` だった。

### Step 2：GitHubでリポジトリを公開する

**実行した主なコマンド**

```bash
git remote add origin git@github.com:Daewony/linux-quest.git
git remote -v
git push -u origin main
```

**実行結果**

- GitHubに公開リポジトリ `linux-quest` を作成した。
- SSH形式のリモートリポジトリを登録した。
- `main -> main` と表示され、プッシュに成功した。
- GitHub上でREADMEとコミット履歴を確認できた。

### Step 3：チームメンバー用のリポジトリをクローンする

**実行した主なコマンド**

```bash
mkdir teammate
cd ~/teammate
git clone git@github.com:Daewony/linux-quest.git
cd linux-quest
pwd
git status
git log --oneline
```

**実行結果**

- `/root/teammate/linux-quest` にリポジトリをクローンできた。
- `main` ブランチとコミット履歴を確認できた。
- `git status` で `nothing to commit, working tree clean` と表示された。

### Step 4：GitHubフローで変更する

**実行した主なコマンド**

```bash
git switch -c add-goal
git diff
git add README.md
git commit
git commit --amend -m "Add training goal to README"
git push -u origin add-goal
git switch main
git pull
git branch -d add-goal
```

**実行結果**

- `add-goal` ブランチでREADMEに「研修のゴール」を追加した。
- コミット `0a687be` を作成した（コミットメッセージを修正した後のもの）。
- PR #1を作成し、変更内容を確認してレビューコメントを投稿した。
- PR #1を `main` にマージした（マージコミット：`51d938c`）。
- ローカルの `main` を更新し、不要になったブランチを削除した。

### Step 5：チームメンバーの変更を取り込む

**実行した主なコマンド：チームメンバー側**

```bash
git pull
git switch -c add-links
git status
git --no-pager diff
git add README.md
git --no-pager diff --cached
git commit -m "Add Git learning resource to README"
git push -u origin add-links
git switch main
git pull
git branch -d add-links
```

**実行した主なコマンド：自分側**

```bash
git pull
git log -1 --oneline
git --no-pager log --graph --oneline --all -8
```

**実行結果**

- READMEに「参考リンク」を追加し、Pro Gitの日本語版へのリンクを記載した。
- コミット `e0f75f6` を作成した。
- PR #2をマージした（マージコミット：`4fd675b`）。
- 自分のローカルリポジトリでも `git pull` を実行し、変更が反映されたことを確認した。
- コミットグラフでブランチの分岐とマージの履歴を確認した。

### Step 6：コンフリクトを解決する

**実行した主なコマンド：チームメンバー側**

```bash
git switch -c update-status-teammate
git add README.md
git commit -m "Update README status for team development"
git push -u origin update-status-teammate
```

**実行した主なコマンド：自分側**

```bash
git switch -c update-status
git --no-pager diff
git add README.md
git commit -m "Update README status for conflict practice"
git fetch origin
git merge origin/main
git status
git --no-pager diff
git add README.md
git --no-pager diff --cached
git commit -m "Merge origin/main and resolve README status conflict"
git push
```

**マージ後の整理に使ったコマンド**

```bash
git switch main
git pull
git branch -d update-status
# チームメンバー側：
git branch -d update-status-teammate
git log --graph
```

**実行結果**

- チームメンバーはステータスを「GitHub でチーム開発を練習中」に変更した（コミット：`6da3d64`）。
- 自分は同じ行を「コンフリクトの解決を練習中」に変更した（コミット：`9646528`）。
- チームメンバーのPR #3を先にマージした（マージコミット：`552fe68`）。
- 自分のPR #4では、同じ行の変更が競合してコンフリクトが発生した。

`git merge origin/main` の出力（主な部分）：

```text
CONFLICT (content): Merge conflict in README.md
Automatic merge failed; fix conflicts and then commit the result.
```

READMEの該当箇所には、次のマーカーが表示された。

```text
<<<<<<< HEAD
コンフリクトの解決を練習中
=======
GitHub でチーム開発を練習中
>>>>>>> origin/main
```

両方の変更を確認し、最終的に次の内容に修正した。

```text
GitHub でチーム開発とコンフリクトの解決を練習中
```

- `git add README.md` の後、`git status` で `All conflicts fixed but you are still merging.` と表示された。
- マージコミット `059c5a7` を作成した。
- 変更をプッシュすると、PR #4のコンフリクト表示が消えた。
- PR #4をマージした（マージコミット：`4b17a59`）。
- 自分とチームメンバーの両方の `main` を最新にし、不要なローカルブランチを削除した。
- `git log --graph` で分岐と合流の履歴を確認した。

チームメンバー側で最後に確認した結果：

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean

4b17a59 (HEAD -> main, origin/main, origin/HEAD) Merge pull request #4 from Daewony/update-status
```

## 質問への回答

### Step 1 - 質問1：公開鍵と秘密鍵

作成された2つの鍵ファイルは、公開鍵（`id_ed25519.pub`）と秘密鍵（`id_ed25519`）です。

公開鍵はGitHubに登録してもよい鍵で、秘密鍵は自分だけが安全に保管する鍵です。

SSH認証では、秘密鍵を使って自分の身元を証明し、GitHubは登録された公開鍵を使って確認します。

### Step 1 - 質問2：秘密鍵のパーミッション

秘密鍵のパーミッションは `600`（`rw-------`）です。

`6` は所有者に読み取り（4）と書き込み（2）の権限があることを意味し、残りの `0` はグループとその他のユーザーに権限がないことを意味します。

秘密鍵は他の人に見られてはいけないため、自分だけが読み書きできるように設定されています。

### Step 6 - 質問6：コンフリクトマーカー

コンフリクトが発生したとき、README.mdには `<<<<<<< HEAD`、`=======`、`>>>>>>> origin/main` というマーカーが表示されました。

`<<<<<<< HEAD` から `=======` までが現在のブランチの内容で、`=======` から `>>>>>>> origin/main` までがマージしようとしているブランチの内容です。

Gitはどちらの変更を採用するか自動で判断できないため、両方の内容を確認して手動で修正しました。

### Step 7 - 質問1：ローカルとリモート、clone・push・pull

ローカルリポジトリは自分のPCなどで作業する場所で、リモートリポジトリはGitHubなどを使ってコードを保存・共有する場所です。

`git clone` はリモートリポジトリを履歴とともにローカルに複製するコマンドで、`git push` はローカルで作成したコミットをリモートに送るコマンドです。

`git pull` はリモートの変更を取得し、現在のローカルブランチに取り込むコマンドです。

### Step 7 - 質問2：ブランチ

ブランチとは、特定のコミットを指すもので、作業を分けて開発するために使います。

`main` ブランチに直接コミットせず、新しいブランチを作ることで、既存のコードにすぐ影響を与えずに機能の追加や修正ができます。

また、プルリクエストを通して他のメンバーに変更内容を確認してもらい、安全に `main` にマージするためにも役立ちます。

### Step 7 - 質問3：プルリクエスト

プルリクエストとは、自分のブランチで行った変更を、別のブランチにマージしてもらうためのリクエストです。

プルリクエストを作成すると、変更したファイルやコードの差分を他のメンバーと共有し、コメントやレビューを受けることができます。

そのため、問題を見つけやすくなり、変更内容を確認してから `main` ブランチへマージできます。

### Step 7 - 質問4：GitHub Flow

GitHub Flowとは、ブランチとプルリクエストを使って、変更を取り込むための開発フローです。

まず、最新の `main` から新しいブランチを作り、ファイルを変更してコミットした後、GitHubにプッシュしてプルリクエストを作成します。

その後、レビューを受けて必要な修正を行い、問題がなければ `main` にマージし、不要になったブランチを削除します。

参考：https://docs.github.com/ja/get-started/using-github/github-flow

### Step 7 - 質問5：コンフリクト

コンフリクトとは、複数のブランチで同じ部分を異なる内容に変更した場合などに、Gitが自動でマージできなくなることです。

コンフリクトを減らすためには、チームメンバーと作業範囲を事前に分担し、`git fetch` などで最新の変更をこまめに確認することが大切です。

コンフリクトが発生した場合は、両方の変更内容を確認し、必要に応じてチームメンバーと相談しながら手動で修正します。
