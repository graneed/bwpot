# Specification

## 1. Web applications and Routing Rules
HTTP(S)リクエストを受け付けると、以下のWebアプリケーションのいずれかがレスポンスを返します。
- [WordPress](https://wordpress.org/)
- [phpMyAdmin](https://www.phpmyadmin.net/)
- [Apache Tomcat](http://tomcat.apache.org/)
- PHP WebShell
- [WOWHoneypot](https://github.com/morihisa/WOWHoneypot)

nginxがリバースプロキシとして動作し、各Webアプリケーションはバックエンドで動作します。nginxは、URLを条件にバックエンドへリクエストをルーティングします。

ルーティングのルールを下表に示します。詳しくは[docker/nginx/dist/default.conf](../docker/nginx/dist/default.conf)を参照してください。

条件(case insensitive)|ルーティング先
--|--
`/wp-`から始まる|WordPress
`phpMyAdmin\|pma\|mysql`を含む|phpMyAdmin
`/manager/`から始まる|Apache Tomcat
`.jsp`を含む|Apache Tomcat
`.php`を含む|PHP WebShell
その他|WOWHoneypot

## 2. Port and Protocol
Port|Protocol
--|--
80|HTTP
443|HTTPS
8080|HTTP

HTTPSの場合は、nginxが自己署名証明書を使用して受け付けし、HTTPでバックエンドの各Webアプリケーションへ転送します。

Listenするポートを追加する場合は、以下のファイルを変更する必要があります。
- [docker/nginx/dist/default.conf](../docker/nginx/dist/default.conf)
- [docker/tshark/Dockerfile](../docker/tshark/Dockerfile)
- [etc/bwpot/docker-compose.yml](../etc/bwpot/docker-compose.yml)
- [etc/bwpot/setIptables.sh](../etc/bwpot/setIptables.sh)

## 3. Log file list
ログ種類|保存先|ファイル名|保存期間
--|--|--|--
access log|`/data/nginx/log/`|`access.json-yyyymmdd.gz`|180日間
error log|`/data/nginx/log/`|`error.log-yyyymmdd.gz`|180日間
pcap file|`/data/tshark/dump/`|`tcp.pcap-yyyymmdd-hhmmss.gz`|約180日間
tcp log|`/data/tshark/log/`|`tcp.json`|0日間

当日分のログのファイル名には、`-yyyymmdd(-hhmmss)`と`.gz`は付きません。

## 4. Log file description
### 4.1. access Log
nginxのアクセスログです。JSON形式で保存します。

ログフォーマットを下表に示します。

項目|説明|例
--|--|--
time|ISO 8601フォーマットのアクセス日時。|2019-02-01T12:34:56+09:00
src_ip|リクエスト元のIPアドレス。|5.40.XX.XX
src_port|リクエスト元のPort番号。|46970
dst_ip|リクエスト先のIPアドレス。サーバのグローバルIPアドレスではなくDockerコンテナの内部IPアドレス。|172.20.0.7
dst_port|リクエスト先のポート番号。|80
request_length|リクエストのヘッダー部とボディ部のサイズ。|184
response_length|レスポンスのヘッダー部とボディ部のサイズ。|224
scheme|URLスキーマ。|http
method|リクエストメソッド。|GET
uri|リクエストURI。|/manager/html
protocol|HTTPプロトコル。|HTTP/1.1
host|Hostヘッダー。|13.231.XXX.XXX
http_referer|リファラー。|hxxp://13.231.XXX.XXX/test.php
http_user_agent|ユーザーエージェント。|Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36 SE 2.X MetaSr 1.0
request_header|リクエストのヘッダー部。|Host: 13.231.XXX.XXX\r\nUser-Agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36 SE 2.X MetaSr 1.0\r\nContent-Length: 0\r\n\r\n
request_body|リクエストのボディ部。|hoge=fuga&aaa=bbb
status|ステータスコード|200
size|レスポンスのボディ部のサイズ。|12

### 4.2. error log
nginxの標準のエラーログです。エラーログのレベルは`warn`です。

### 4.3. pcap file
tsharkが保存するネットワークキャプチャファイルです。
[2. Port and Protocol](#2-Port-and-Protocol)に記載しているPort番号がキャプチャの対象です。

ホストOSのネットワークインターフェースからキャプチャします。

### 4.4. tcp log
tsharkが出力するJSON形式のネットワークキャプチャログです。  
ログフォーマットはElasticsearch用のフォーマットです。(tsharkの`-T ek`オプションで出力)

ホストOSのネットワークインターフェースからキャプチャします。

## 5. Log Rotation
BW-Potのサービス起動前に、logrotateコマンドによるローテーションおよびログ削除を行います。

詳しくは[etc/logrotate/](../etc/logrotate/)を参照してください。

### 5.1. access log
[etc/logrotate/logrotate_nginx.conf](../etc/logrotate/logrotate_nginx.conf)の定義に基づいてローテーションします。

### 5.2. error log
[etc/logrotate/logrotate_nginx.conf](../etc/logrotate/logrotate_nginx.conf)の定義に基づいてローテーションします。

### 5.3. pcap file
[etc/logrotate/logrotate_tshark.conf](../etc/logrotate/logrotate_tshark.conf)の定義に基づいてローテーションします。

既にpcapファイルが存在する場合に上書きしないように、ファイル名に`-hhmmss`を付けて強制ローテーションを行います。
サーバ再起動およびサービス再起動を週に8回実行するため、ローテーションするファイルの最大数を`200`にすることで、保存期間が`180日間`になるよう調整しています。
よって、手動でサービス再起動した場合は保存期間が短縮されます。

### 5.4. tcp log
Fluentdへの連携を目的としたファイルであるため、ローテーションせずに日次でログファイルをクリアします。

## 6. Log forwarder
Fluentdを使用して、access Logとtcp logをGoogle BigQueryに転送します。

指定したdatasetにテーブルが存在しない場合は、自動でテーブルを作成します。
ただし、自動でテーブルを作成すると分割テーブルになりません。
コスト削減等を目的に分割テーブルを使用したい場合は、あらかじめWeb UIやbqコマンドでテーブルを作成し、分割する列に`time`列を指定することを推奨します。
手順は[Install](INSTALL.md)を参照してください。

## 7. Job schedule
cronを使用して以下の定期ジョブを実行します。

- 毎日03:27にサーバを再起動します。Dockerコンテナも再起動しますのでクリーンな状態が保たれます。また、再起動後にログローテーションを実行します。
- 毎週日曜16:27にパッケージを更新してサーバを再起動します。

## 8. Firewall
iptablesを使用して、[2. Port and Protocol](#2-Port-and-Protocol)以外のPort番号への通信を禁止しています。

詳しくは[etc/bwpot/setIptables.sh](../etc/bwpot/setIptables.sh)を参照してください。

## 9. Directories
各ディレクトリの役割を下表に示します。

ディレクトリ|役割
--|--
./docker/|各DockerコンテナのDockerfileとコンテナ内に配備するファイルを格納するディレクトリ
./etc/|ホストOSのサービスが参照するファイルを格納するディレクトリ
./host/|ホストOSへのインストール時に使用するファイルを格納するディレクトリ
/data/|各種ログファイルの格納ディレクトリ
