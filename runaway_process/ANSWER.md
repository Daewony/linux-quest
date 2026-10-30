# 「暴走プロセスを止めろ」QUEST

## ステップ1：原因を突き止める

### 実行したコマンドと結果

**1. プロセスの調査**

```bash
ps -ef
ps aux
top
```

`ps -ef` の実行結果（問題のあるプロセスを抜粋）：

```text
UID        PID  PPID  C STIME TTY          TIME CMD
root        40     1 99 14:32 pts/1    00:04:27 /bin/bash ./penguin_calc.sh
root        41     1  0 14:32 pts/1    00:00:00 /bin/bash ./penguin_logger.sh
```

`ps aux` の実行結果（抜粋）：

```text
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root        40 99.9  0.0   4344  2868 pts/1    R    14:32   4:41 /bin/bash ./penguin_calc.sh
root        41  0.0  0.0   5664  3184 pts/1    S    14:32   0:00 /bin/bash ./penguin_logger.sh
```

`top` でも、PID 40 の `penguin_calc.sh` が CPU を約 100% 使用していることを確認しました。

```text
PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
 40 root      20   0    4344   2868   2740 R 100.0   0.0   4:53.64 penguin_calc.sh
```

**2. ディスク使用量とファイルの調査**

```bash
df -h
find / -name "penguin_calc.sh"
du -sh /root/runaway/penguin_calc.sh
du -h /root/runaway
cd /root/runaway/logs
ls -al
cat debug.log | tail -n 10
```

`find` でスクリプトの場所を確認しました。

```text
/root/runaway/penguin_calc.sh
```

スクリプトファイル自体は小さいことが分かりました。

```text
4.0K    /root/runaway/penguin_calc.sh
```

`du -h /root/runaway` の実行結果：

```text
300M    /root/runaway/logs
300M    /root/runaway
```

`ls -al` の実行結果（ファイルを抜粋）：

```text
-rw-r--r-- 1 root root        19 Oct 22 14:32 app_1.log
-rw-r--r-- 1 root root        19 Oct 22 14:32 app_2.log
-rw-r--r-- 1 root root        19 Oct 22 14:32 app_3.log
-rw-r--r-- 1 root root 313740000 Oct 21 07:33 debug.log
```

`debug.log` の末尾には、次のようなメッセージが繰り返し記録されていました。

```text
[DEBUG] 2026-10-21 07:33:59 penguin_logger: something happened
```

ログの生成方法を確認するため、`penguin_logger.sh` の内容も調べました。

```bash
cat /root/runaway/penguin_logger.sh
```

```bash
#!/bin/bash
trap '' TERM INT HUP
log="$HOME/runaway/logs/debug.log"
while true; do
  size=$(du -m "$log" 2>/dev/null | cut -f1)
  if [ "${size:-0}" -lt 300 ]; then
    yes "[DEBUG] $(date '+%F %T') penguin_logger: something happened" | head -n 20000 >> "$log"
  fi
  sleep 1
done
```

### 調査して分かったこと

- CPU を大量に使用していたプロセスは `penguin_calc.sh`（PID 40）で、CPU 使用率は約 100% でした。
- `penguin_logger.sh`（PID 41）は CPU 使用率がほぼ 0% でしたが、`debug.log` にログを書き込むスクリプトでした。
- `debug.log` のファイルサイズは約300MiBで、/root/runaway ディレクトリの使用量の大部分を占めていました。
- `penguin_logger.sh` は、ログの使用量が 300 MiB 未満のときにログを追記します。300 MiB 以上になると追記はしなくなりますが、`while true` と `sleep 1` によりプロセス自体は動き続けます。

## ステップ2：プロセスを止める

### 実行したコマンドと結果

```bash
kill 40
kill 41
ps aux
```

`kill 40` の後、`penguin_calc.sh` は一覧から消えましたが、`penguin_logger.sh` は残っていました。

```text
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4672  3092 pts/0    Ss+  02:14   0:00 bash
root        12  0.0  0.0   5840  3728 pts/1    Ss   02:14   0:00 bash
root        41  0.0  0.0   5664  3184 pts/1    S    14:32   0:00 /bin/bash ./penguin_logger.sh
root     13227  0.0  0.0  17728  6380 pts/1    S    15:16   0:00 sleep 1
root     13228  0.0  0.0   7296  4652 pts/1    R+   15:16   0:00 ps aux
```

```bash
kill -9 41
ps aux
```

強制終了した後は、両方のプロセスが一覧から消えました。

```text
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4672  3092 pts/0    Ss+  02:14   0:00 bash
root        12  0.0  0.0   5840  3728 pts/1    Ss   02:14   0:00 bash
root     14824  0.0  0.0   6200  3312 pts/1    R+   15:21   0:00 ps aux
```

### 考察

**通常の `kill` と `kill -9` の違い**

通常の `kill` コマンドは、プロセスに SIGTERM（シグナル15）を送って終了を要求します。一方、`kill -9` は SIGKILL（シグナル9）を送り、プロセスを強制終了します。

基本的には、まず通常の `kill` で終了を試し、それでも終了しない場合に `kill -9` を使います。強制終了すると、プロセスが終了前の後処理を行えないためです。

**`penguin_logger.sh` が通常の `kill` では止まらなかった理由**

`penguin_logger.sh` には `trap '' TERM INT HUP` という設定があり、SIGTERM、SIGINT、SIGHUP を無視するようになっています。通常の `kill` コマンドは SIGTERM を送るため、このプロセスは終了しませんでした。一方、SIGKILL は無視できないため、`kill -9 41` で強制終了できました。

## ステップ3：ディスクを片付ける

### 実行したコマンドと結果

```bash
cd /root/runaway/logs
du -h
ls -al
```

削除前のディスク使用量：

```text
300M    .
```

不要なログファイルだけを削除し、再度確認しました。

```bash
rm debug.log
ls -al
du -h
```

削除後のファイル一覧：

```text
total 20
drwxr-xr-x 2 root root 4096 Oct 22 15:37 .
drwxr-xr-x 3 root root 4096 Oct 21 07:29 ..
-rw-r--r-- 1 root root   19 Oct 22 14:32 app_1.log
-rw-r--r-- 1 root root   19 Oct 22 14:32 app_2.log
-rw-r--r-- 1 root root   19 Oct 22 14:32 app_3.log
```

削除後のディスク使用量：

```text
16K     .
```

### 分かったこと

プロセスを終了しても、すでに作成されたログファイルは残ります。`debug.log` のみを削除した結果、`logs` ディレクトリの使用量は約 300 MiB から 16 KiB に減りました。他のログファイルはそのまま残しました。

## ステップ4：ジョブを操作する

### 実行した操作と結果

**1. フォアグラウンドの作業を終了・一時停止する**

```bash
sleep 300
# Ctrl+C で終了
sleep 300
# Ctrl+Z で一時停止
jobs
```

`Ctrl+Z` の後、次のように表示されました。

```text
^Z
[1]+  Stopped                    sleep 300
```

```text
[1]+  Stopped                    sleep 300
```

**2. バックグラウンドで再開・実行する**

```bash
bg %1
sleep 200 &
jobs
```

```text
[1]+ sleep 300 &
[2] 14863
[1]-  Running                    sleep 300 &
[2]+  Running                    sleep 200 &
```

**3. フォアグラウンドに戻し、作業を終了する**

```bash
fg %2
# Ctrl+C で sleep 200 を終了
jobs
jobs -l
kill 14862
jobs
jobs -l
```

`fg %2` で `sleep 200` をフォアグラウンドに戻し、`Ctrl+C` で終了しました。その後、`jobs -l` で `sleep 300` の PID を確認しました。

```text
[1]+ 14862 Running                    sleep 300 &
```

`kill 14862` の後：

```text
[1]+  Terminated                 sleep 300
```

最後に `jobs -l` を実行し、ジョブが残っていないことを確認しました。

### 考察

**`Ctrl+C` と `Ctrl+Z` の違い**

`Ctrl+C` は、実行中のプロセスに SIGINT を送って終了を要求します。一方、`Ctrl+Z` は SIGTSTP を送り、プロセスを終了させずに一時停止します。

**`jobs`、`fg`、`bg` の役割**

- `jobs`：現在のシェルが管理しているジョブの一覧を表示します。
- `fg`：指定したジョブをフォアグラウンドに移し、停止中なら実行を再開します。
- `bg`：一時停止しているジョブをバックグラウンドで再開します。

**`sleep 200 &` と `bg %1` の違い**

`sleep 200 &` は、新しい `sleep 200` を最初からバックグラウンドで実行します。一方、`bg %1` は、すでに存在するジョブ番号1の停止中の作業を、バックグラウンドで再開します。

## ステップ5：ターミナルを閉じても動き続けるプロセス

### 1. 準備スクリプトでプロセスを起動している行と、それぞれの意味

準備スクリプト `setup_runaway.sh` で確認した起動部分：

```bash
nohup ./penguin_calc.sh > /dev/null 2>&1 &
nohup ./penguin_logger.sh > /dev/null 2>&1 &
```

- `nohup`：ターミナルの接続が切れて SIGHUP を受けても、そのシグナルを無視してプロセスを実行し続けられるようにします。
- `./penguin_calc.sh` / `./penguin_logger.sh`：カレントディレクトリにある、それぞれのスクリプトを実行します。
- `> /dev/null`：標準出力（stdout）を `/dev/null` に送り、出力内容を破棄します。
- `2>&1`：標準エラー出力（stderr）を標準出力と同じ出力先（この場合は `/dev/null`）に送ります。
- `&`：コマンドをバックグラウンドで実行します。

つまり、二つのスクリプトをバックグラウンドで起動し、標準出力と標準エラー出力を破棄し、ターミナルが切断されても SIGHUP によって終了しないようにしています。

### 2. 通常のバックグラウンド実行と、準備スクリプトの方法の違い

通常の `&` によるバックグラウンド実行では、ターミナルを閉じたりログアウトしたりしたときに、SIGHUP を受けてプロセスが終了する場合があります。一方、`nohup` を使って実行した場合は SIGHUP を無視するため、ターミナルを閉じたりログアウトしたりしても、プロセスを実行し続けることができます。

ただし、通常のバックグラウンドジョブもシェルの設定や終了方法によっては残る場合があります。また、`nohup` でもプロセスの強制終了やコンテナ自体の停止を防ぐことはできません。

## ステップ6：まとめ

### 1. プロセスとは何か。プログラムとの違いは何か

プログラムは、命令やデータなどで構成され、ファイルとして保存されているものです。一方、プロセスは、プログラムを実行したもので、OS によって管理される実行単位です。

### 2. ジョブとは何か。プロセスとの違いは何か

ジョブは、シェルが管理する一つの作業単位です。一方、プロセスは、OS が管理する個別の実行単位です。

例えば、`sleep 100 | cat` を実行すると、`sleep` と `cat` の二つのプロセスが動きますが、Bash では一つのジョブとして管理されます。つまり、一つのジョブには一つまたは複数のプロセスが含まれます。

### 3. フォアグラウンドとバックグラウンドの違いは何か

フォアグラウンドは、ターミナルの制御権を持って実行される作業です。実行中は、基本的にその作業が終わるか一時停止するまで、同じシェルで別のコマンドを実行できません。

一方、バックグラウンドは、ターミナルの制御権を持たずに実行される作業です。そのため、作業を実行しながら、同じターミナルで別のコマンドを入力できます。バックグラウンドの作業でも画面への出力は可能なので、画面に見えるかどうかが主な違いではありません。

### 4. サーバーの様子がおかしいとき、どの順番で何を調べるか

サーバーの様子がおかしいときは、まず CPU やメモリ、ディスクなどのリソースの使用状況を確認します。

`ps aux` や `top` を使って、どのプロセスが CPU やメモリを多く使用しているのかを調べます。また、`df -h` や `du` を使って、ディスクの使用状況や容量を多く使っているファイルを確認します。

その後、調査した結果から問題の原因を考え、必要な対処を行います。最後に、もう一度リソースの使用状況を確認し、問題が解決したかどうかを確かめます。
