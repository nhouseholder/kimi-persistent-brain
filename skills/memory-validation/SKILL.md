# Memory Validation

## Description

Lightweight validation skill ported from persistent-brain v0.5.0. Validates memory saves before they hit Engram — prevents garbage-in, catches contradictions, enforces topic_key discipline.

## When This Skill Activates

**Always-on.** Before EVERY `mem_save` call, mentally run this checklist. Takes <1 second. Zero overhead.

## Validation Rules

### 1. Type Check

```
Valid types: bugfix, decision, architecture, discovery, pattern, config, preference

INVALID → fix before saving:
- "discovery" (reserved for auto-distill; use "manual" or "learning")
- Any typo like "bugfixes", "archtecture", etc.
```

### 2. topic_key Discipline

```
REQUIRED for: decision, architecture, bugfix, pattern, config
OPTIONAL for: discovery, preference
FORMAT: lowercase, hyphens, slashes only
  GOOD: "auth/jwt-strategy", "props/pipeline/grade", "deploy/cloudflare"
  BAD:  "JWT Strategy", "propsPipeline", "deploy_cloudflare"
```

### 3. Content Structure Check

```
Must contain at least ONE ** marker:
  **What**: ...
  **Why**: ...
  **Where**: ...
  **Learned**: ...

If no ** markers → add structure before saving.
```

### 4. Conflict Detection (Before Creating New)

```
BEFORE mem_save on a topic:
1. mem_search(query="your topic", topic_key="your/topic/key")
2. If results found AND content differs → this is a CONFLICT
3. Options:
   a. Use mem_update(id=existing_id) to update existing
   b. Use mem_save with SAME topic_key to supersede (Engram upserts)
   c. Use different topic_key if genuinely different topic
4. NEVER create duplicate observations for the same topic
```

## Quick Checklist (copy before every mem_save)

```
□ Type is valid
□ topic_key provided (if required for type)
□ topic_key format is lowercase-hyphens-slashes
□ Content has ** structure
□ No conflict with existing same-topic observation
□ Scope is correct (project vs personal)
```

## Why This Matters

persistent-brain v0.5.0 achieved 23.7% actionable data quality (up from ~5%) by enforcing these exact rules. Skip them and your memory rots.
