# kanban-loader

[vibe-kanban](https://github.com/BloopAI/vibe-kanban)をベースに、開発に必要なツール(Claude Code、GitHub CLI、Node.jsなど)を統合したDocker環境です。

## 概要

このプロジェクトは、npmパッケージ版のvibe-kanbanに以下のツールを追加した開発環境を提供します：

- **vibe-kanban** - AI開発タスク管理ツール（npmパッケージ版）
- **Claude Code** - AI支援開発ツール
- **GitHub CLI (gh)** - GitHubコマンドラインツール
- **Git** - バージョン管理
- **Node.js 22** - JavaScriptランタイム
- **SSH Agent統合** - 1Password経由の認証
- **追加パッケージ** - カスタマイズ可能なaptパッケージ

## 前提条件

- Docker Desktop（Docker Compose対応）
- 1Password（SSH Agent機能を使用する場合）

## セットアップ

### 1. 設定ファイルの準備（オプション）

追加でインストールしたいパッケージがある場合は、`config/apt.txt`を作成します：

```bash
cp config/apt.txt.sample config/apt.txt
# 必要に応じてパッケージを追加・編集
```

### 2. コンテナの起動

```bash
docker compose up -d
```

### 3. コンテナへの接続

```bash
docker compose exec -u appuser app bash
```

## 初回セットアップ（Docker内で実行）

コンテナ起動後、**コンテナ内**で以下の初期化を行います。

### Claude Codeの初期化

コンテナ内で初回起動して認証を行います：

```bash
claude-code
# 画面の指示に従ってAPI keyの設定などを行う
```

### GitHub CLIの認証

コンテナ内でGitHub認証を行います：

```bash
gh auth login
# プロンプトに従って認証方法を選択
# - GitHub.com を選択
# - HTTPS または SSH を選択
# - 認証フローを完了
```

認証状態の確認：

```bash
gh auth status
```

### SSH Agentについて

1PasswordのSSH Agentソケットが`/ssh-agent`にマウントされています。これにより、ホストマシンの1Passwordに保存されたSSH鍵をコンテナ内から使用できます。特別な初期化作業は不要です。

### リポジトリのクローン

作業用リポジトリは`/repos`ディレクトリ内にクローンします：

```bash
cd /repos
git clone git@github.com:username/repository.git
```

**注意:** 初回のgit clone時にSSH fingerprintの確認プロンプトが表示されます。`yes`を入力して接続を許可してください。

```
The authenticity of host 'github.com (xx.xx.xx.xx)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```

## 使用方法

### vibe-kanbanサーバーへのアクセス

コンテナ起動後、以下のURLでアクセスできます：

```
http://localhost:4989
```

### コンテナ内での作業

通常の開発作業は`appuser`として実行します：

```bash
docker compose exec -u appuser app bash
```

rootが必要な場合：

```bash
docker compose exec app bash
```

### コンテナの停止・再起動

```bash
# 停止
docker compose down

# 再起動
docker compose restart

# ログ確認
docker compose logs -f app
```

## ディレクトリ構造

```
.
├── compose.yml              # Docker Compose設定
├── Dockerfile               # コンテナイメージ定義
├── entrypoint.sh            # コンテナ起動スクリプト
├── config/
│   ├── apt.txt.sample      # 追加パッケージのサンプル
│   └── apt.txt             # 追加パッケージリスト（任意）
└── data/
    └── vibe-kanban/        # vibe-kanban設定データ（オプション）
```

## ボリューム

永続化されるデータ：

- `repos-volume` - `/repos` - クローンしたリポジトリ
- `vibe-kanban-shared` - vibe-kanban共有データ
- `vibe-kanban-cache` - vibe-kanbanキャッシュ
- `vibe-kanban-tmp` - vibe-kanban一時ファイル
- `npm-global` - グローバルNode.jsモジュール
- `npm-bin` - Node.jsバイナリ
- `claude-config` - Claude設定
- `gh-config` - GitHub CLI設定

ホストからマウントされるデータ：

- `~/.gitconfig` - Git設定（読み取り専用）
- `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock` - 1Password SSH Agent

## カスタマイズ

### 追加パッケージのインストール

`config/apt.txt`にパッケージ名を追加して、コンテナを再ビルドします：

```bash
echo "your-package-name" >> config/apt.txt
docker compose up -d --build
```

### vibe-kanbanのアップデート

コンテナ内でvibe-kanbanを最新版に更新できます：

```bash
docker compose exec -u root app npm update -g vibe-kanban
docker compose restart
```

### ポート番号の変更

`compose.override.yml`を作成してポートを変更します：

```yaml
# compose.override.yml
services:
  app:
    ports:
      - "8080:3000"  # 例：8080番ポートに変更
```

変更後、コンテナを再起動：

```bash
docker compose up -d
```

## トラブルシューティング

### SSH接続できない

1. 1PasswordのSSH Agent機能が有効になっているか確認
2. SSH鍵が1Passwordに登録されているか確認
3. コンテナ内で`echo $SSH_AUTH_SOCK`が`/ssh-agent`を指しているか確認

### Claude Codeが起動しない

コンテナ内で設定ファイルのパーミッションを確認：

```bash
ls -la ~/.claude.json
```

### GitHub CLIの認証が切れた

コンテナ内で再認証：

```bash
gh auth login
```

## ライセンス

このプロジェクトの設定ファイル群は自由に使用できます。ベースとなるvibe-kanbanおよび各ツールのライセンスについては、それぞれのプロジェクトを参照してください。
