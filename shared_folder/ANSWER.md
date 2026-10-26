# 「チームの共有フォルダ」QUEST

## Step 1：自分は何者か

### 1. ログインしているユーザー

```bash
$ whoami
root
```

### 2. ユーザーIDと所属グループ

```bash
$ id
uid=0(root) gid=0(root) groups=0(root)
```

### 3. スーパーユーザーについて

現在ログインしているユーザーは `root` です。スーパーユーザーは、ユーザーの作成、ファイルの所有者や権限の変更など、システム管理に必要な強い権限を持つユーザーです。通常のユーザーでは許可されない操作も行えます。

## Step 2：メンバーを迎える

### 1〜3. ユーザー・グループの作成と登録

```bash
$ sudo useradd -m alice
$ sudo useradd -m bob
$ sudo useradd -m carol
$ sudo groupadd devteam
$ sudo usermod -aG devteam alice
$ sudo usermod -aG devteam bob
```

`/etc/passwd` を確認しました。

```text
$ cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/run/ircd:/usr/sbin/nologin
_apt:x:42:65534::/nonexistent:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
ubuntu:x:1000:1000:Ubuntu:/home/ubuntu:/bin/bash
alice:x:1001:1001::/home/alice:/bin/sh
bob:x:1002:1002::/home/bob:/bin/sh
carol:x:1003:1003::/home/carol:/bin/sh
```

上記の最後の3行から、3人のユーザーが登録され、それぞれのホームディレクトリが `/home/alice`、`/home/bob`、`/home/carol` に設定されていることを確認しました。

グループの登録についても確認しました。

```text
$ cat /etc/group | grep "devteam"
devteam:x:1004:alice,bob
```

### 4. 各ユーザーの所属グループ

```text
$ groups alice
alice : alice devteam

$ groups bob
bob : bob devteam

$ groups carol
carol : carol
```

## Step 3：共有フォルダを作る

### 共有フォルダの設定

```bash
$ mkdir /srv/devteam
$ chown alice:devteam /srv/devteam
```

`/srv` で権限を設定しました。

```bash
$ chmod 770 devteam
```

```text
$ ls -ld /srv/devteam
drwxrwx--- 2 alice devteam 4096 Oct 20 17:30 /srv/devteam
```

### 各ユーザーでの動作確認

`alice` として `alice.txt` を作成しました。

```text
$ touch alice.txt
$ ls -al
total 16
drwxrwx--- 2 alice devteam 4096 Oct 21 09:05 .
drwxr-xr-x 1 root  root    4096 Oct 20 16:20 ..
-rw-rw-r-- 1 alice alice      0 Oct 21 09:05 alice.txt
-rwxr-x--- 1 alice devteam   66 Oct 20 17:06 deploy.sh
-rw------- 1 alice alice      5 Oct 21 08:41 secret.txt
```

続いて `bob` として `bob.txt` を作成しました。

```text
$ su bob
$ cd /srv/devteam
$ touch bob.txt
$ ls -al
total 16
drwxrwx--- 2 alice devteam 4096 Oct 21 09:05 .
drwxr-xr-x 1 root  root    4096 Oct 20 16:20 ..
-rw-rw-r-- 1 alice alice      0 Oct 21 09:05 alice.txt
-rw-rw-r-- 1 bob   bob        0 Oct 21 09:05 bob.txt
-rwxr-x--- 1 alice devteam   66 Oct 20 17:06 deploy.sh
-rw------- 1 alice alice      5 Oct 21 08:41 secret.txt
```

`ls -al` の結果から、`alice.txt` の所有者は `alice`、`bob.txt` の所有者は `bob` であることを確認しました。

`carol` は共有フォルダにアクセスできませんでした。

```text
$ su carol
$ id
uid=1003(carol) gid=1003(carol) groups=1003(carol)
$ pwd
/srv
$ ls
devteam
$ cd devteam
sh: 4: cd: can't cd to devteam
$ ls /srv/devteam
ls: cannot open directory '/srv/devteam': Permission denied
```

### パーミッション `drwxrwx---` の説明

- `d`：ディレクトリであることを示す。
- 最初の `rwx`：所有者 `alice` に、一覧表示（`r`）、項目の作成・削除（`w`）、ディレクトリ内へのアクセス（`x`）を許可する。
- 次の `rwx`：グループ `devteam` のユーザーにも同じ権限を許可する。
- 最後の `---`：その他のユーザーには権限を与えない。

`770` は、所有者とグループに `7 = 4 + 2 + 1`（`rwx`）、その他のユーザーに `0`（権限なし）を設定することを意味します。

## Step 4：秘密のファイル

`alice` として文字列を書き込み、所有者だけが読み書きできる権限を確認しました。

```text
$ su alice
$ id
uid=1001(alice) gid=1001(alice) groups=1001(alice),1004(devteam)
$ cd /srv/devteam
$ ls
alice.txt  bob.txt  deploy.sh  secret.txt
$ vim secret.txt
$ cat secret.txt
test
$ ls -al
total 16
drwxrwx--- 2 alice devteam 4096 Oct 21 08:21 .
drwxr-xr-x 1 root  root    4096 Oct 20 16:20 ..
-rw-rw-r-- 1 alice alice      0 Oct 20 16:33 alice.txt
-rw-rw-r-- 1 bob   bob        0 Oct 20 16:36 bob.txt
-rwxr-x--- 1 alice devteam   66 Oct 20 17:06 deploy.sh
-rw------- 1 alice alice      5 Oct 21 08:21 secret.txt
```

`bob` としてファイルの読み取りを試しました。

```text
$ su bob
$ id
uid=1002(bob) gid=1002(bob) groups=1002(bob),1004(devteam)
$ cd /srv/devteam
$ cat secret.txt
cat: secret.txt: Permission denied
```

`secret.txt` の権限は `-rw-------`（`600`）で、所有者の `alice` だけが読み書きできる状態でした。

## Step 5：デプロイスクリプト

課題で指定されたスクリプトの内容は次のとおりです。

```bash
#!/bin/bash
echo "$(whoami) がデプロイを実行しました"
```

権限を設定して確認しました。

```bash
$ chmod 750 deploy.sh
```

```text
$ ls -al
total 16
drwxrwx--- 2 alice devteam 4096 Oct 21 08:21 .
drwxr-xr-x 1 root  root    4096 Oct 20 16:20 ..
-rw-rw-r-- 1 alice alice      0 Oct 20 16:33 alice.txt
-rw-rw-r-- 1 bob   bob        0 Oct 20 16:36 bob.txt
-rwxr-x--- 1 alice devteam   66 Oct 20 17:06 deploy.sh
-rw------- 1 alice alice      5 Oct 21 08:21 secret.txt
```

`bob` として実行すると、正常に動作しました。

```text
$ ./deploy.sh
bob がデプロイを実行しました
```

`bob` がファイルに追記しようとすると、書き込み権限がないため失敗しました。

```text
$ ls >> deploy.sh
sh: 12: cannot create deploy.sh: Permission denied
```

## Step 6：謎の挙動を調べる

### 1. `bob` が `secret.txt` を削除する

`bob` として削除を試しました。

```text
$ su bob
$ ls
devteam
$ cd devteam
$ ls
alice.txt  bob.txt  deploy.sh  secret.txt
$ rm secret.txt
rm: remove write-protected regular file 'secret.txt'? y
$ ls -al
total 12
drwxrwx--- 2 alice devteam 4096 Oct 21 08:39 .
drwxr-xr-x 1 root  root    4096 Oct 20 16:20 ..
-rw-rw-r-- 1 alice alice      0 Oct 20 16:33 alice.txt
-rw-rw-r-- 1 bob   bob        0 Oct 20 16:36 bob.txt
-rwxr-x--- 1 alice devteam   66 Oct 20 17:06 deploy.sh
```

**結果と理由：** `bob` はファイル自体の読み取り・書き込み権限を持っていませんが、親ディレクトリ `/srv/devteam` に対して `devteam` グループの書き込み（`w`）と実行（`x`）の権限を持っています。ファイルの削除は基本的に親ディレクトリの権限によって決まるため、ファイルの中身を読めなくても削除できました。

削除後、`alice` としてファイルを作り直しました。

```text
$ su alice
$ cd devteam
$ touch secret.txt
$ chmod 600 secret.txt
$ ls -al
total 12
drwxrwx--- 2 alice devteam 4096 Oct 21 08:41 .
drwxr-xr-x 1 root  root    4096 Oct 20 16:20 ..
-rw-rw-r-- 1 alice alice      0 Oct 20 16:33 alice.txt
-rw-rw-r-- 1 bob   bob        0 Oct 20 16:36 bob.txt
-rwxr-x--- 1 alice devteam   66 Oct 20 17:06 deploy.sh
-rw------- 1 alice alice      0 Oct 21 08:41 secret.txt
$ echo "test" > secret.txt
$ cat secret.txt
test
```

### 2. `box` の所有者の実行権限（`x`）を外す

`/home/alice/box` の所有者の `x` を外した状態で、`alice` として動作を確認しました。

```text
$ su alice
$ cd /home/alice
$ pwd
/home/alice
$ ls
box
$ ls -al
total 28
drwxr-x--- 3 alice alice 4096 Oct 21 08:21 .
drwxr-xr-x 1 root  root  4096 Oct 20 16:15 ..
-rw-r--r-- 1 alice alice  220 Feb 13  2026 .bash_logout
-rw-r--r-- 1 alice alice 3771 Feb 13  2026 .bashrc
-rw-r--r-- 1 alice alice  807 Feb 13  2026 .profile
-rw------- 1 alice alice 1509 Oct 21 08:21 .viminfo
drw-rwxr-x 2 alice alice 4096 Oct 20 17:34 box
$ ls box
item.txt
$ cd box
sh: 6: cd: can't cd to box
$ cat box/item.txt
cat: box/item.txt: Permission denied
```

**結果と理由：** `box` の権限は `drw-rwxr-x` で、所有者 `alice` には `rw-` が設定されています。`r` があるため `ls box` でファイル名を表示できましたが、`x` がないため `cd box` や `cat box/item.txt` はできませんでした。

ディレクトリの `r` は中のファイル名の一覧を読む権限、`x` はディレクトリ内のパスをたどってアクセスする権限です。なお、所有者に該当する `alice` には所有者の `rw-` が適用され、グループの `rwx` と合算されません。

`root` は通常のアクセス権限チェックを回避できるため、同じ違いを確かめるには一般ユーザーの `alice` で実行する必要があります。

### 3. `chmod 777` が危険な理由

`chmod 777` は所有者・グループ・その他のユーザーすべてに読み取り・書き込み・実行権限を与えます。そのため、本来アクセスする必要のないユーザーがファイルを閲覧・変更したり、ディレクトリ内のファイルを削除したりする可能性があります。誤操作や情報漏えいを防ぐために、必要なユーザーに必要な権限だけを設定することが重要です。

## Step 7：振り返り

### 1. ファイルの所有者とグループとは何ですか

所有者は、そのファイルやディレクトリを所有するユーザーです。グループは複数のユーザーをまとめて権限を管理する仕組みです。Linux では所有者・グループ・その他のユーザーに対して、それぞれ別の権限を設定できます。

### 2. `r`・`w`・`x` と `chmod 640` の意味

通常のファイルでは、`r` は読み取り、`w` は書き込み、`x` は実行を意味します。ディレクトリでは、`r` は名前の一覧表示、`w` は項目の作成・削除、`x` はその中のパスにアクセスするための権限です。

`chmod 640` は次の設定です。

- `6`（所有者）：`4 + 2` で読み取りと書き込み（`rw-`）。
- `4`（グループ）：読み取りのみ（`r--`）。
- `0`（その他）：権限なし（`---`）。

### 3. `sudo` とは何ですか。なぜ普段から root で作業しない方がよいのですか

`sudo` は、許可されたユーザーが、通常は `root` など別のユーザーの権限でコマンドを実行する仕組みです。

`root` はシステム全体に影響する操作ができるため、普段から `root` で作業すると、コマンドを間違えたときに重要なファイルを変更・削除してしまう危険があります。そのため、通常は一般ユーザーで作業し、必要な操作だけ管理者権限で実行する方が安全です。

## 最終確認：`/srv/devteam` の所有者・グループ・パーミッション

`bob` として `/srv/devteam` に移動し、最後にディレクトリ内の状態を確認しました。

```text
$ cd /srv/devteam
$ ls -al
total 16
drwxrwx--- 2 alice devteam 4096 Oct 21 09:05 .
drwxr-xr-x 1 root  root    4096 Oct 20 16:20 ..
-rw-rw-r-- 1 alice alice      0 Oct 21 09:05 alice.txt
-rw-rw-r-- 1 bob   bob        0 Oct 21 09:05 bob.txt
-rwxr-x--- 1 alice devteam   66 Oct 20 17:06 deploy.sh
-rw------- 1 alice alice      5 Oct 21 08:41 secret.txt
```
