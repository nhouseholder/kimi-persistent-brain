# kimi-persistent-brain

> **Kimi CLI native. Two-layer memory. Zero overhead.**

A lightweight, Kimi-CLI-native persistent memory system combining **Engram** (temporal memory) and **CodeGraphContext** (structural memory). Evolved from [persistent-brain](https://github.com/nhouseholder/persistent-brain) v0.5.0 — ports only the highest-yield, lowest-overhead features.

## Why This Exists

[persistent-brain](https://github.com/nhouseholder/persistent-brain) is a 7-agent universal memory system. It's powerful but carries weight: Python router, shell hooks, multi-agent abstractions, install scripts. For Kimi CLI users who don't need cross-agent support, that's overhead without value.

**kimi-persistent-brain** strips it down to the essentials:
- ✅ Two-layer memory (CGC + Engram) — persistent-brain never had this
- ✅ Auto-diagram protocol — generates codebase map every session
- ✅ Conflict detection + validation — highest-yield feature from v0.5.0
- ✅ Relevance scoring — surfaces useful memories, not just recent ones
- ✅ Session lifecycle — Kimi-native skill hooks, no shell scripts
- ✅ Zero dependencies — uses Engram MCP + CGC MCP directly

## Architecture

```
┌─────────────────────────────────────────────┐
│              Kimi CLI Agent                 │
└──────────────┬──────────────────────────────┘
               │ merge_all_available_skills = true
    ┌──────────┴──────────┐
    ▼                     ▼
┌──────────┐      ┌──────────────┐
│  Engram  │      │      CGC     │
│(temporal)│      │ (structural) │
│SQLite+   │      │ FalkorDB     │
│FTS5      │      │ Graph        │
└──────────┘      └──────────────┘
```

**Two-layer decision tree:**
- "Who calls X?" → CGC
- "What did we do about X?" → Engram
- "Should we refactor X?" → CGC first, then Engram

## Skills (6 total)

| Skill | Purpose | Source |
|-------|---------|--------|
| `always-on-memory` | ⚡ **Session start/end enforcement** — impossible to miss trigger | New |
| `memory-protocol` | Engram protocol compliance — when to save, search, summarize | From Kimi setup |
| `codebase-memory` | Two-layer architecture — CGC + Engram decision tree | From Kimi setup |
| `memory-validation` | ✅ **Conflict detection + type validation** — highest yield from v0.5.0 | Ported from p-brain |
| `memory-scoring` | 📊 **Relevance scoring** — confidence × recency × frequency | Ported from p-brain |
| `session-hooks` | 🪝 **Kimi-native lifecycle** — replaces shell hooks | Ported from p-brain |

## Installation

### 1. Install Engram

```bash
brew tap gentleman-programming/tap
brew install engram
```

### 2. Install CodeGraphContext

```bash
uv tool install codegraphcontext
```

### 3. Install Skills

```bash
git clone https://github.com/nhouseholder/kimi-persistent-brain ~/.kimi/skills/kimi-persistent-brain
cp -r ~/.kimi/skills/kimi-persistent-brain/skills/* ~/.kimi/skills/
```

### 4. Configure MCP

Add to `~/.kimi/mcp.json`:

```json
{
  "mcpServers": {
    "engram": {
      "command": "engram",
      "args": ["mcp"]
    },
    "codegraphcontext": {
      "command": "cgc",
      "args": ["mcp", "start"],
      "env": {
        "CGC_PROJECT_ROOT": "/path/to/your/project"
      }
    }
  }
}
```

### 5. Enable Skill Loading

Ensure `~/.kimi/config.toml` has:

```toml
merge_all_available_skills = true
```

### 6. Drop AGENTS.md in Your Project

Copy `AGENTS.md` to your project root. It contains the auto-diagram protocol and compliance checklist.

## Session Lifecycle (Fully Automatic)

```
User opens project → types first message
    ↓
Agent reads AGENTS.md line 1: "STOP — EXECUTE THIS FIRST"
    ↓
mem_session_start → mem_context → mem_search(diagram) → load/generate
    ↓
CGC switch_context → verify graph is current
    ↓
Respond to user WITH codebase context already loaded
```

No user prompt needed. No shell scripts. The skills enforce it.

## What We Ported from persistent-brain v0.5.0

| Feature | persistent-brain | kimi-persistent-brain | Why Kept/Dropped |
|---------|-----------------|----------------------|------------------|
| Multi-agent (7 agents) | ✅ | ❌ | Kimi-only = no need |
| Python router (607 lines) | ✅ | ❌ | Direct MCP is simpler |
| Shell hooks | ✅ | ❌ | Kimi skills replace them |
| Install scripts | ✅ | ❌ | `brew install` + `git clone` |
| Conflict detection | ✅ | ✅ | **Highest yield feature** |
| Validation rules | ✅ | ✅ | **Prevents garbage-in** |
| Relevance scoring | ✅ | ✅ | **Surfaces useful memories** |
| Access tracking | ✅ | ✅ | **Feeds scoring** |
| Project mapping | ✅ | ❌ | Use engram merge_projects |
| Schema migration | ✅ | ❌ | Engram handles it |
| Two-layer memory | ❌ | ✅ | **CGC integration** |
| Auto-diagram | ❌ | ✅ | **Codebase map every session** |
| Always-on enforcement | ❌ | ✅ | **3-layer trigger system** |

## Differences from persistent-brain

| Aspect | persistent-brain | kimi-persistent-brain |
|--------|-----------------|----------------------|
| **Agents** | 7 (Claude, Codex, Cursor, OpenCode, Antigravity, Kimi, Continue) | Kimi CLI only |
| **Memory layers** | 1 (engram temporal) | 2 (engram temporal + CGC structural) |
| **Interface** | brain-router Python MCP server | Direct engram MCP + CGC MCP |
| **Hooks** | Shell scripts (session-start.sh, session-end.sh) | Kimi skills (always-on-memory, session-hooks) |
| **Diagram** | None | Auto-generated every session |
| **Validation** | Router-enforced | Skill-enforced (agent self-checks) |
| **Overhead** | ~607 lines Python + hooks | ~6 markdown skill files |

## When to Use Which

| Use Case | Use This |
|----------|----------|
| Kimi CLI only, one project | **kimi-persistent-brain** |
| Multiple agents (Claude, Codex, etc.) | [persistent-brain](https://github.com/nhouseholder/persistent-brain) |
| Need structural code analysis | **kimi-persistent-brain** (CGC) |
| Need universal cross-agent memory | [persistent-brain](https://github.com/nhouseholder/persistent-brain) |

## License

MIT. See [LICENSE](LICENSE).
