# Session Hooks (Kimi-Native)

## Description

Shell-less session lifecycle management for Kimi CLI. Replaces persistent-brain's `session-start.sh` and `session-end.sh` with Kimi-native skill enforcement.

## When This Skill Activates

**Always-on.** Fires at three moments:
1. **Session start** — before first reply to user
2. **During session** — after every significant action
3. **Session end** — before saying "done"

## Session Start Hook

```
BEFORE first reply:

1. mem_session_start(id=SESSION_ID, project=PROJECT_NAME, directory=PWD)
2. mem_context (load recent memories, rank by relevance score)
3. mem_search(query="codebase diagram", topic_key="codebase/diagram/{PROJECT_NAME}")
   ├─ Found → mem_get_observation(id) → load diagram
   └─ Not found → generate via CGC → mem_save(topic_key="codebase/diagram/{PROJECT_NAME}")
4. discover_codegraph_contexts → switch_context to current project
5. mem_search(query=current_task_topic) → proactive recall
6. NOW reply to user
```

## Mid-Session Hook

```
After EVERY bugfix / decision / discovery / config change / pattern / preference:

1. Run Memory Validation skill checklist
2. mem_save(title="...", type="...", topic_key="...", content="**What**: ...")
3. If conflict detected → mem_update existing or use same topic_key for upsert
```

## Session End Hook

```
BEFORE saying "done" / "finished" / "that's it":

□ mem_session_start called at beginning
□ mem_context checked
□ mem_save called for all significant work (validation passed)
□ mem_save_prompt called (if user asked something significant)
□ mem_session_summary called with Goal/Instructions/Discoveries/Accomplished/Next Steps/Files
□ mem_session_end called

If ANY unchecked → complete NOW. Never end without summary.
```

## Compaction Recovery Hook

```
If compaction/context reset message appears:

1. IMMEDIATELY mem_session_summary(content=compacted_summary)
2. mem_context → recover additional context
3. Continue working
```

## Why Shell Scripts Are Replaced

persistent-brain used shell hooks (`session-start.sh`, `session-end.sh`) because it supported 7 different agents with different hook mechanisms. Kimi CLI loads skills automatically via `merge_all_available_skills = true` — no shell scripts needed. The skill IS the hook.
