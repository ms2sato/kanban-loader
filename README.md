# kanban-loader

[vibe-kanban](https://github.com/BloopAI/vibe-kanban)をベースに、開発に必要なツール(Claude Code、GitHub CLI、Node.js など)を統合した Docker 環境です。

## 概要

このプロジェクトは、npm パッケージ版の vibe-kanban に以下のツールを追加した開発環境を提供します：

- **vibe-kanban** - AI 開発タスク管理ツール（npm パッケージ版）
- **Claude Code** - AI 支援開発ツール
- **GitHub CLI (gh)** - GitHub コマンドラインツール
- **Git** - バージョン管理
- **Node.js 22** - JavaScript ランタイム
- **SSH Agent 統合** - 1Password 経由の認証
- **追加パッケージ** - カスタマイズ可能な apt パッケージ

## 前提条件

- Docker Desktop（Docker Compose 対応）
- 1Password（SSH Agent 機能を使用する場合）

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
docker compose exec -u kanban app bash
```

## 初回セットアップ（Docker 内で実行）

コンテナ起動後、**コンテナ内**で以下の初期化を行います。

### Claude Code の初期化

コンテナ内で初回起動して認証を行います：

```bash
claude
# 画面の指示に従ってAPI keyの設定などを行う
```

### GitHub CLI の認証

コンテナ内で GitHub 認証を行います：

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

### SSH Agent について

1Password の SSH Agent ソケットが`/ssh-agent`にマウントされています。これにより、ホストマシンの 1Password に保存された SSH 鍵をコンテナ内から使用できます。特別な初期化作業は不要です。

### リポジトリのクローン

作業用リポジトリは`/repos`ディレクトリ内にクローンします：

```bash
cd /repos
git clone git@github.com:username/repository.git
```

**注意:** 初回の git clone 時に SSH fingerprint の確認プロンプトが表示されます。`yes`を入力して接続を許可してください。

```
The authenticity of host 'github.com (xx.xx.xx.xx)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```

## 使用方法

### vibe-kanban サーバーへのアクセス

コンテナ起動後、以下の URL でアクセスできます：

```
http://localhost:4989
```

システム起動直後は少し時間がかかるので、以下のようにログを確認して起動してからアクセスすると良いです。

```
$ docker-compose logs -f app
npm warn exec The following package was not found and will be installed: vibe-kanban@0.0.113
app-1  | 📦 Extracting vibe-kanban...
app-1  | 🚀 Launching vibe-kanban...
app-1  | 2025-10-30T00:49:03.438100Z  INFO services::services::config: No config file found, creating one
app-1  | 2025-10-30T00:49:03.467726Z  INFO executors::profile: No user profiles.json found, using defaults only
app-1  | 2025-10-30T00:49:04.998122Z  INFO local_deployment: Starting orphaned image cleanup...
app-1  | 2025-10-30T00:49:05.038877Z  INFO local_deployment::container: Starting periodic worktree cleanup...
app-1  | 2025-10-30T00:49:05.123203Z  INFO services::services::pr_monitor: Starting PR monitoring service with interval 60s
app-1  | 2025-10-30T00:49:05.253071Z  INFO services::services::file_search_cache: Starting file search cache warming...
app-1  | 2025-10-30T00:49:05.280433Z  INFO services::services::file_search_cache: No active projects found, skipping cache warming
app-1  | 2025-10-30T00:49:05.389750Z  INFO server: Server running on http://0.0.0.0:3000
app-1  | 2025-10-30T00:49:05.390068Z  INFO server: Opening browser...
app-1  | 2025-10-30T00:49:05.427068Z  WARN server: Failed to open browser automatically: No such file or directory (os error 2). Please open http://127.0.0.1:3000 manually.
```

### コンテナ内での作業

通常の開発作業は`kanban`として実行します：

```bash
docker compose exec -u kanban app bash
```

root が必要な場合：

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

- `repos-volume` - `/repos` - クローンしたリポジトリ（Named Volume）
- `./data/vibe-kanban-shared` - vibe-kanban 共有データ
- `./data/vibe-kanban-cache` - vibe-kanban キャッシュ
- `./data/vibe-kanban-tmp` - vibe-kanban 一時ファイル
- `./data/claude` - Claude 設定（`.claude.json`含む）
- `./data/gh` - GitHub CLI 設定

ホストからマウントされるデータ：

- `~/.gitconfig` - Git 設定（読み取り専用）
- `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock` - 1Password SSH Agent

**注意:** `./data`ディレクトリ内のファイルは永続化されます。`docker compose down`しても設定は保持されます。

## カスタマイズ

### 追加パッケージのインストール

`config/apt.txt`にパッケージ名を追加して、コンテナを再ビルドします：

```bash
echo "your-package-name" >> config/apt.txt
docker compose up -d --build
```

### vibe-kanban のアップデート

コンテナ内で vibe-kanban を最新版に更新できます：

```bash
docker compose exec app npm update -g vibe-kanban
docker compose restart
```

### ポート番号の変更

`compose.override.yml`を作成してポートを変更します：

```yaml
# compose.override.yml
services:
  app:
    ports:
      - "8080:3000" # 例：8080番ポートに変更
```

変更後、コンテナを再起動：

```bash
docker compose up -d
```

## トラブルシューティング

### SSH 接続できない

1. 1Password の SSH Agent 機能が有効になっているか確認
2. SSH 鍵が 1Password に登録されているか確認
3. コンテナ内で`echo $SSH_AUTH_SOCK`が`/ssh-agent`を指しているか確認

### Claude Code が起動しない

コンテナ内で設定ファイルのパーミッションを確認：

```bash
ls -la ~/.claude.json
```

### GitHub CLI の認証が切れた

コンテナ内で再認証：

```bash
gh auth login
```

## ライセンス

このプロジェクト（kanban-loader）は MIT ライセンスの下で公開されています。

なお、vibe-kanban、Claude Code、GitHub CLI、その他の統合ツールについては、それぞれのプロジェクトのライセンスを参照してください。
