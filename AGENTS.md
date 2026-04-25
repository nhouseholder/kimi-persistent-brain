# ⚠️ STOP — EXECUTE THIS FIRST (Before Any Reply)

## Auto-Diagram Protocol — RUN NOW

You are in a NEW SESSION. Before typing a single word to the user, you MUST execute this protocol. This is not optional. This is not "if you remember." This is MANDATORY.

```
STEP 1: mem_session_start(id=THIS_SESSION_ID, project=PROJECT_NAME, directory=PWD)
STEP 2: mem_context
STEP 3: mem_search(query="codebase diagram", topic_key="codebase/diagram/{PROJECT_NAME}")
STEP 4: If found → mem_get_observation(id=FOUND_ID) → load the diagram
STEP 5: If NOT found → cgc stats . → cgc analyze complexity --limit 10 → cgc analyze dead-code → synthesize → mem_save(topic_key="codebase/diagram/{PROJECT_NAME}", type="architecture")
STEP 6: discover_codegraph_contexts → switch_context to current project
STEP 7: NOW respond to user WITH codebase context already loaded
```

**If you skip steps 1-6, you are flying blind. The diagram is your map. Past context is your compass. Execute the protocol. NOW.**

---

# Project Agent Instructions

## Memory — Engram Protocol

This project uses **Engram** persistent memory via MCP. Follow the official protocol from https://github.com/Gentleman-Programming/engram/blob/main/DOCS.md#memory-protocol.

### Session Lifecycle

1. **START** — Call `mem_session_start` + run Auto-Diagram Protocol (above) BEFORE first reply.
2. **DURING** — Call `mem_save` IMMEDIATELY after any significant work. Do not batch. Do not wait.
3. **END** — Call `mem_session_summary` BEFORE saying "done" / "that's it" / "finished" / ending.
4. **FORMAL CLOSE** — Call `mem_session_end` to formally close the session.

### Validation Before Save (MANDATORY)

Before EVERY `mem_save`:

```
□ Type is valid: bugfix, decision, architecture, discovery, pattern, config, preference
□ topic_key provided (required for: decision, architecture, bugfix, pattern, config)
□ topic_key format: lowercase-hyphens-slashes (e.g., "auth/jwt-strategy")
□ Content has **What** / **Why** / **Where** / **Learned** structure
□ No conflict with existing same-topic observation (search first)
□ Scope is correct: project (default) or personal
```

### Relevance Scoring (After Search)

After `mem_search` or `mem_context`, rank results by usefulness:

```
High score: accessed many times (>5), updated recently (<7 days)
Low score: never accessed, very old (>60 days), superseded
```

Present top results with confidence notes, not just chronologically.

### Memory Protocol Compliance Checklist (BEFORE ENDING)

```
□ mem_session_start called at session beginning
□ mem_context checked for relevant past work
□ mem_save called after every bugfix / decision / discovery / config / pattern / preference
□ User prompts saved with mem_save_prompt (if significant)
□ mem_session_summary called with complete Goal/Instructions/Discoveries/Accomplished/Next Steps/Relevant Files
□ mem_session_end called to formally close session
```

## Codebase Memory — Two-Layer Architecture

### Decision Tree

```
Question about...
├─ Code structure? → CGC (analyze_code_relationships, find_code)
├─ Past work? → Engram (mem_search, mem_context)
└─ Both? → CGC first, then Engram
```

### CGC Pre-Flight Checklist (before reindex)

```
□ .cgcignore excludes ALL venv variants
□ .cgcignore excludes node_modules/, dist/, build/, .git/
□ cgc stats . shows ~350 files (not 1000+)
□ If contaminated → delete → reindex → verify
```

## Deployment Rules

On every commit that changes production code:
1. Bump `package.json` version (semantic)
2. Include `Deployed: YYYY-MM-DD at HH:MM AM/PM TZ` in commit body
