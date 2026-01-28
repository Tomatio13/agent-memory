---
name: agent-memory
description: "日次ログと長期メモリを管理し、記憶の保存・検索を行います。使用タイミング: '覚えておいて''記録して''検索して'など"
metadata:
  short-description: "agent-style persistent memory system"
---

# Agent Memory

2層メモリシステム。会話の中で得られた重要な情報を記憶し、後のセッションで検索・活用できます。

**Location:** `~/.agents/skills/agent-memory/memory/`

## 2-Layer Memory System

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

## Proactive Usage

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

## Operations

### /log - 日次ログに記録

日次ログ（`memory/YYYY-MM-DD.md`）に時刻付きで記録します。

**使用例:**
- `/log API設計でRESTを採用することに決定`
- `/log ユーザーはTypeScriptを好む`
- `/log デプロイ時は必ずバックアップを作成`

**実行方法:**
```bash
~/.agents/skills/agent-memory/scripts/daily_log.sh "記録内容"
```

### /remember - 長期メモリに保存

長期メモリ（`MEMORY.md`）に構造化された情報を保存します。

**使用例:**
- `/remember ユーザー設定: TypeScriptを好む、簡潔な説明を好む`
- `/remember 重要決定: データベースはPostgreSQLを採用`
- `/remember 連絡先: Alice (alice@acme.com) - デザインリード`

**実行方法:**
```bash
~/.agents/skills/agent-memory/scripts/long_term.sh add "セクション名" "内容"
```

**主要セクション例:**
- `User Preferences` - ユーザーの設定・偏好
- `Important Decisions` - 重要な意思決定
- `Key Contacts` - 重要な連絡先
- `Project Context` - プロジェクトのコンテキスト
- `Troubleshooting` - トラブルシューティングの記録

### /recall - 記憶を検索

メモリ全体からキーワード検索します。

**使用例:**
- `/recall TypeScript で何か決めたっけ？`
- `/recall データベースの件`
- `/recall APIのエンドポイント`

**実行方法:**
```bash
# 全体検索
~/.agents/skills/agent-memory/scripts/search.sh "キーワード"

# 日次ログのみ
~/.agents/skills/agent-memory/scripts/search.sh "キーワード" --daily

# 長期メモリのみ
~/.agents/skills/agent-memory/scripts/search.sh "キーワード" --long
```

### /organize - メモリの整理

長期メモリを読み取り、必要に応じて整理・編集します。

**実行方法:**
```bash
~/.agents/skills/agent-memory/scripts/long_term.sh read
```

## Search Workflow

効率的な検索のためのワークフロー：

```bash
# 1. 今日と昨日の日次ログを確認
~/.agents/skills/agent-memory/scripts/search.sh "キーワード" --daily

# 2. 長期メモリを検索
~/.agents/skills/agent-memory/scripts/search.sh "キーワード" --long

# 3. 全体検索（上記で見つからない場合）
~/.agents/skills/agent-memory/scripts/search.sh "キーワード" --all
```

## Guidelines

1. **日次ログ**: その日のうちに記録。追記のみで編集しない
2. **長期メモリ**: 重要な情報のみを保存。定期的に整理
3. **検索**: まず日次ログ、次に長期メモリを検索
4. **自己完結**: メモリ単体で理解できるように記述

## Folder Structure

```
~/.agents/skills/agent-memory/
├── SKILL.md          # 本ファイル
├── design.md         # 設計書
├── scripts/
│   ├── daily_log.sh      # 日次ログスクリプト
│   ├── long_term.sh      # 長期メモリスクリプト
│   └── search.sh         # 検索スクリプト
└── memory/
    ├── MEMORY.md         # 長期メモリ
    └── 2026-01-28.md     # 今日の日次ログ
```

## Examples

### 例1: ユーザー設定を記憶

```
User: 「僕はTypeScript派なんだよね」
Agent: 了解しました。記録します。
[実行] daily_log.sh "ユーザーはTypeScriptを好む"
[実行] long_term.sh add "User Preferences" "Prefers TypeScript over JavaScript"
```

### 例2: 意思決定を記録

```
User: 「APIはRESTで行こう」
Agent: 了解しました。記録します。
[実行] daily_log.sh "API設計: RESTを採用決定"
[実行] long_term.sh add "Important Decisions" "2026-01-28: Adopted REST over GraphQL for API"
```

### 例3: 過去の記憶を検索

```
User: 「前にデータベース何にするって話した？」
Agent: 記憶を検索します。
[実行] search.sh "database" --all
[結果] PostgreSQLを選択
```

