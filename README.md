<p align="center">
  <h1 align="center">Agent Memory Skill</h1>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Bash-4.0+-black.svg" alt="Bash"/>
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"/>
</p>

2層メモリシステムを持つAgentスキル。日次ログと長期メモリの管理、キーワード検索機能が実装されています。

## 📖 概要

会話の中で得られた重要な情報を記憶し、後のセッションで検索・活用できます。

## 🧠 2層メモリシステム

| 層 | ファイル | 用途 |
|---|---------|------|
| **Layer 1** | `memory/YYYY-MM-DD.md` | 日次ログ - その日の作業、発見、一時的な記録 |
| **Layer 2** | `MEMORY.md` | 長期メモリ - 永続的な事実、ユーザー設定、重要な意思決定 |

### Layer 1: Daily Logs (`memory/YYYY-MM-DD.md`)

追記型の日次ログ。その日の出来事を時系列で記録します。

```markdown
# 2026-01-28

## 10:30 - API設計議論
REST vs GraphQLについて検討。結論: シンプルさを優先しRESTを採用。

## 14:15 - デプロイ
v2.3.0を本番環境にデプロイ完了。

## 16:00 - ユーザー設定
ユーザーはTypeScriptをJavaScriptより好む。
```

### Layer 2: Long-term Memory (`MEMORY.md`)

キュレーションされた永続的な知識ベース。

```markdown
# Long-term Memory

## User Preferences
- Prefers TypeScript over JavaScript
- Likes concise explanations

## Important Decisions
- 2026-01-15: Chose PostgreSQL for database
- 2026-01-20: Adopted REST over GraphQL
```

## 📁 ディレクトリ構造

```
├── SKILL.md          # スキル定義
├── README.md         # 本ファイル
├── scripts/
│   ├── daily_log.sh      # 日次ログスクリプト
│   ├── long_term.sh      # 長期メモリスクリプト
│   └── search.sh         # 検索スクリプト
└── memory/
    ├── MEMORY.md         # 長期メモリ
    └── 2026-01-28.md     # 日次ログ
```

## 🚀 使用方法

### Claude Code/Codex から使用

```
# 日次ログに記録
/agent-memory API設計でRESTを採用

# 長期メモリに保存
/agent-memory ユーザー設定: TypeScriptを好む

# 記憶を検索
/agent-memory TypeScriptで何か決めたっけ？
```

### スクリプトを直接実行

#### 日次ログ (daily_log.sh)

```bash
~/.claude/skills/agent-memory/scripts/daily_log.sh "記録内容"
```

例:
```bash
~/.claude/skills/agent-memory/scripts/daily_log.sh "API設計でRESTを採用することを決定"
```

#### 長期メモリ (long_term.sh)

```bash
# 追加
~/.claude/skills/agent-memory/scripts/long_term.sh add "User Preferences" "TypeScript派" "TypeScriptを好む"

# 読み取り
~/.claude/skills/agent-memory/scripts/long_term.sh read

# 検索
~/.claude/skills/agent-memory/scripts/long_term.sh search "キーワード"

# 見出しツリー
~/.claude/skills/agent-memory/scripts/long_term.sh tree

# セクション抽出
~/.claude/skills/agent-memory/scripts/long_term.sh section "User Preferences"
```

例:
```bash
# 追加
~/.claude/skills/agent-memory/scripts/long_term.sh add "User Preferences" "TypeScript派" "ユーザーはTypeScriptをJavaScriptより好む"

# 読み取り
~/.claude/skills/agent-memory/scripts/long_term.sh read

# 検索
~/.claude/skills/agent-memory/scripts/long_term.sh search "TypeScript"
```

#### 検索 (search.sh)

```bash
# 全体検索
~/.claude/skills/agent-memory/scripts/search.sh "キーワード"

# 日次ログのみ
~/.claude/skills/agent-memory/scripts/search.sh "キーワード" --daily

# 長期メモリのみ
~/.claude/skills/agent-memory/scripts/search.sh "キーワード" --long
```

## 📋 プロアクティブ使用ガイド

メモリは以下の場合にプロアクティブに使用してください：

**保存すべきケース**:
- 重要な発見やソリューション
- ユーザーの明示的な設定・偏好（「これを覚えておいて」）
- アーキテクチャ上の意思決定とその理由
- トラブルシューティングの結果
- 非自明なパターンや落とし穴

**検索すべきケース**:
- 関連する作業を開始する前
- 同じ問題領域を調査する際
- セッション再開時のコンテキスト復元
- ユーザーが「以前何か話したよね」と言ったとき

## 📑 主要セクション（長期メモリ）

- `User Preferences` - ユーザーの設定・偏好
- `Important Decisions` - 重要な意思決定
- `Key Contacts` - 重要な連絡先
- `Project Context` - プロジェクトのコンテキスト
- `Troubleshooting` - トラブルシューティングの記録

## 🔧 インストール

claude codeの例:
```bash
git clone http://github.com/Tomatio13/agent-memory.git
mv ./agent-memory  ~/.claude/skills/agent-memory
```

codexの例:
```bash
git clone http://github.com/Tomatio13/agent-memory.git
mv ./agent-memory  ~/.codex/skills/agent-memory
```

Claude Codeから直接`/agent-memory`コマンドで使用できます。

## 📦 依存関係

- Bash 4.0+
- ripgrep (rg) - 検索用
- 基本的なUnixコマンド (date, mkdir, cat, etc.)

## 🚀 将来的な拡張

| 機能 | 説明 | ステータス |
|------|------|-----------|
| SessionStart フック | セッション開始時に今日/昨日のログを自動読込 | 検討中 |
| SessionEnd フック | セッション終了時に要約を自動保存 | 検討中 |
| PreCompact フック | コンパクション前に重要情報を自動フラッシュ | 検討中 |
| セマンティック検索 | MCPサーバー統合によるベクトル検索 | 検討中 |

## ⚖️ ライセンス

MIT
