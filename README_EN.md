<p align="center">
  <h1 align="center">Agent Memory Skill</h1>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Bash-4.0+-black.svg" alt="Bash"/>
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"/>
</p>

An agent skill with a two-layer memory system. It manages daily logs and long-term memory, and provides keyword search.

## 📖 Overview

It stores important information from conversations so you can search and reuse it in later sessions.

## 🧠 Two-layer Memory System

| Layer | File | Purpose |
|---|---|---|
| **Layer 1** | `memory/YYYY-MM-DD.md` | Daily logs - work, discoveries, and temporary notes for the day |
| **Layer 2** | `MEMORY.md` | Long-term memory - persistent facts, user preferences, key decisions |

### Layer 1: Daily Logs (`memory/YYYY-MM-DD.md`)

Append-only daily logs that record events in chronological order.

```markdown
# 2026-01-28

## 10:30 - API Design Discussion
Discussed REST vs GraphQL. Conclusion: choose REST for simplicity.

## 14:15 - Deploy
Deployed v2.3.0 to production.

## 16:00 - User Preference
User prefers TypeScript over JavaScript.
```

### Layer 2: Long-term Memory (`MEMORY.md`)

A curated, persistent knowledge base.

```markdown
# Long-term Memory

## User Preferences
- Prefers TypeScript over JavaScript
- Likes concise explanations

## Important Decisions
- 2026-01-15: Chose PostgreSQL for database
- 2026-01-20: Adopted REST over GraphQL
```

## 📁 Directory Structure

```
├── SKILL.md          # Skill definition
├── README.md         # This file (Japanese)
├── scripts/
│   ├── daily_log.sh      # Daily log script
│   ├── long_term.sh      # Long-term memory script
│   └── search.sh         # Search script
└── memory/
    ├── MEMORY.md         # Long-term memory
    └── 2026-01-28.md     # Daily log
```

## 🚀 Usage

### Use from Claude Code / Codex

```
# Write to daily log
/agent-memory Adopted REST in API design

# Save to long-term memory
/agent-memory User preference: prefers TypeScript

# Search memory
/agent-memory Did we decide anything about TypeScript?
```

### Run Scripts Directly

#### Daily Log (daily_log.sh)

```bash
~/.claude/skills/agent-memory/scripts/daily_log.sh "Log content"
```

Example:
```bash
~/.claude/skills/agent-memory/scripts/daily_log.sh "Decided to adopt REST for API design"
```

#### Long-term Memory (long_term.sh)

```bash
# Add
~/.claude/skills/agent-memory/scripts/long_term.sh add "Section Name" "Title" "Content"

# Read
~/.claude/skills/agent-memory/scripts/long_term.sh read

# Search
~/.claude/skills/agent-memory/scripts/long_term.sh search "keyword"

# Heading tree
~/.claude/skills/agent-memory/scripts/long_term.sh tree

# Extract section
~/.claude/skills/agent-memory/scripts/long_term.sh section "User Preferences"
```

Example:
```bash
# Add
~/.claude/skills/agent-memory/scripts/long_term.sh add "User Preferences" "TypeScript" "User prefers TypeScript over JavaScript"

# Read
~/.claude/skills/agent-memory/scripts/long_term.sh read

# Search
~/.claude/skills/agent-memory/scripts/long_term.sh search "TypeScript"

# Heading tree
~/.claude/skills/agent-memory/scripts/long_term.sh tree

# Extract section
~/.claude/skills/agent-memory/scripts/long_term.sh section "User Preferences"
```

#### Search (search.sh)

```bash
# Search all
~/.claude/skills/agent-memory/scripts/search.sh "keyword"

# Daily logs only
~/.claude/skills/agent-memory/scripts/search.sh "keyword" --daily

# Long-term memory only
~/.claude/skills/agent-memory/scripts/search.sh "keyword" --long
```

## 📋 Proactive Usage Guide

Use memory proactively in the following situations:

**When to save**:
- Important findings or solutions
- Explicit user settings/preferences ("Please remember this")
- Architectural decisions and their reasons
- Troubleshooting outcomes
- Non-obvious patterns or pitfalls

**When to search**:
- Before starting related work
- When investigating the same problem area
- To restore context when resuming a session
- When the user says "Did we talk about that before?"

## 📑 Key Sections (Long-term Memory)

- `User Preferences` - user settings/preferences
- `Important Decisions` - key decisions
- `Key Contacts` - important contacts
- `Project Context` - project context
- `Troubleshooting` - troubleshooting notes

## 🔧 Installation

Claude Code example:
```bash
git clone http://github.com/Tomatio13/agent-memory.git
mv ./agent-memory  ~/.claude/skills/agent-memory
```

Codex example:
```bash
git clone http://github.com/Tomatio13/agent-memory.git
mv ./agent-memory  ~/.codex/skills/agent-memory
```

You can use it directly from Claude Code with the `/agent-memory` command.

## 📦 Dependencies

- Bash 4.0+
- ripgrep (rg) - for searching
- Basic Unix commands (date, mkdir, cat, etc.)

## 🚀 Future Extensions

| Feature | Description | Status |
|---|---|---|
| SessionStart hook | Auto-load today/yesterday logs at session start | Under consideration |
| SessionEnd hook | Auto-save summary at session end | Under consideration |
| PreCompact hook | Auto-flush key info before compaction | Under consideration |
| Semantic search | Vector search via MCP server integration | Under consideration |

## ⚖️ License

MIT
