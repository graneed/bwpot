# Preparing for installation

OSセットアップや必要ソフトウェアのインストール手順です。  
Amazon EC2に`Ubuntu Server 18.04 LTS`のインスタンスを新規作成した場合を前提とした手順です。  

## 1. OSセットアップ 

### 1.1. パッケージ最新化
パッケージを最新化します。
```
$ sudo apt update && sudo apt -y upgrade && sudo apt -y dist-upgrade && sudo apt -y autoremove && sudo apt -y autoclean
```

### 1.2. OSユーザ変更
新規OSユーザを作成し、ubuntuユーザの使用を閉塞します。  
デフォルトユーザであるubuntuユーザを狙った攻撃に対する予防策の一つです。
```
OSユーザ作成
$ sudo adduser honey

sudoができる権限を付与
$ sudo gpasswd -a honey sudo

sshログインするための鍵をコピー
$ sudo mkdir /home/honey/.ssh
$ sudo cp /home/ubuntu/.ssh/authorized_keys /home/honey/.ssh/

オーナー、パーミッションを適切に設定
$ sudo chown honey:honey /home/honey/.ssh/
$ sudo chown honey:honey /home/honey/.ssh/authorized_keys
$ sudo chmod 700 /home/honey/.ssh/
$ sudo chmod 600 /home/honey/.ssh/authorized_keys

オーナー、パーミッションを確認
$ sudo ls -la /home/honey/
total 24
drwxr-xr-x 3 honey honey 4096 Jan  6 11:13 .
drwxr-xr-x 4 root  root  4096 Jan  6 11:13 ..
-rw-r--r-- 1 honey honey  220 Jan  6 11:13 .bash_logout
-rw-r--r-- 1 honey honey 3771 Jan  6 11:13 .bashrc
-rw-r--r-- 1 honey honey  807 Jan  6 11:13 .profile
drwx------ 2 honey honey 4096 Jan  6 11:14 .ssh

$ sudo ls -la /home/honey/.ssh/
total 12
drwx------ 2 honey honey 4096 Jan  6 11:14 .
drwxr-xr-x 3 honey honey 4096 Jan  6 11:13 ..
-rw------- 1 honey honey  390 Jan  6 11:14 authorized_keys
```

honeyユーザでsshログインし、ubuntuユーザのログインを閉塞します。
```
$ sudo usermod -s /usr/sbin/nologin ubuntu
```

### 1.3. タイムゾーンの変更
タイムゾーンを日本に変更します。
```
$ sudo timedatectl set-timezone Asia/Tokyo

$ timedatectl
                      Local time: Sun 2019-01-06 20:25:15 JST
                  Universal time: Sun 2019-01-06 11:25:15 UTC
                        RTC time: Sun 2019-01-06 11:25:16
                       Time zone: Asia/Tokyo (JST, +0900)
       System clock synchronized: yes
systemd-timesyncd.service active: yes
                 RTC in local TZ: no
```

### 1.4. ssh設定変更
ssh接続ポートを`60022`番ポートに変更と、rootユーザの直接ログインを閉塞します。  
`60022`番ポート以外のポート番号にする場合は、Install手順に記載しているiptablesの設定変更が必要です。

また、Amazon EC2上に構築する場合は、セキュリティグループのインバウンド設定を編集し、`マイIP`から`60022`番ポートへ接続を許可します。

```
設定ファイルをバックアップ
$ sudo cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.org

ポート番号の変更、rootユーザの直接ログインを閉塞。
$ sudo sed -i 's|#Port 22|Port 60022|' /etc/ssh/sshd_config
$ sudo sed -i 's|#PermitRootLogin prohibit-password|PermitRootLogin no|' /etc/ssh/sshd_config

変更結果を確認
$ diff -u /etc/ssh/sshd_config.org /etc/ssh/sshd_config
--- /etc/ssh/sshd_config.org    2018-09-13 00:59:27.529679607 +0900
+++ /etc/ssh/sshd_config        2019-01-06 20:36:29.691682382 +0900
@@ -10,7 +10,7 @@
 # possible, but leave them commented.  Uncommented options override the
 # default value.

-#Port 22
+Port 60022
 #AddressFamily any
 #ListenAddress 0.0.0.0
 #ListenAddress ::
@@ -29,7 +29,7 @@
 # Authentication:

 #LoginGraceTime 2m
-#PermitRootLogin prohibit-password
+PermitRootLogin no
 #StrictModes yes
 #MaxAuthTries 6
 #MaxSessions 10

sshサービスを再起動
$ sudo systemctl restart ssh
```

その後、60022番ポートでsshログインできることを確認します。

### 1.5. Swap領域確保
2GBのSWAP領域を確保します。

```
Swap領域の作成
$ sudo mkdir /var/swap
$ sudo dd if=/dev/zero of=/var/swap/swap0 bs=1M count=2048
$ sudo chmod 600 /var/swap/swap0
$ sudo mkswap /var/swap/swap0

Swap領域の有効化
$ sudo swapon /var/swap/swap0

Swap領域の自動マウント
$ sudo echo '/var/swap/swap0 swap swap defaults 0 0' >> /etc/fstab

Swap領域の確認
$ sudo swapon -s
Filename                                Type            Size    Used    Priority
/var/swap/swap0                         file            2097148 0       -2
```

## 2. 必要ソフトウェアのインストール
### 2.1. Dockerインストール
[公式のインストール手順](https://docs.docker.com/install/linux/docker-ce/ubuntu/)を参考にインストールします。

```
$ sudo apt-get remove docker docker-engine docker.io

$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

$ sudo apt-get update

$ sudo apt-get install docker-ce
```

### 2.2. Docker-Composeインストール
[公式のインストール手順](https://docs.docker.com/compose/install/)を参考にインストールします。

バージョンアップに伴い、URLのバージョン番号は変わるため、公式を参照してください。
```
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

$ sudo chmod +x /usr/local/bin/docker-compose

$ docker-compose --version
docker-compose version 1.23.2, build 1110ad01
```

### 2.3. logrotateインストール
最初からインストール済みのため、作業不要です。
