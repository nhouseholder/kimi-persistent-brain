# Memory Protocol Enforcement

## Description

Always-on skill that enforces the Engram Memory Protocol. This skill is loaded at the start of every Kimi CLI session (via `merge_all_available_skills = true`). It ensures the agent never forgets to save memories, search past work, or close sessions properly.

## When This Skill Activates

This skill is **always active**. It fires at these specific moments:

1. **At session start** — before the first reply to the user
2. **After significant work** — bugfixes, decisions, discoveries, config changes, patterns, user preferences
3. **Before saying "done"** — end-of-session compliance check
4. **After compaction** — recovery from context reset

## Protocol Enforcement

### START OF SESSION (before first reply)

You MUST do this BEFORE your first response to the user. The user does not ask for this. You do it automatically.

```
1. Call mem_session_start(id=SESSION_ID, project=PROJECT_NAME, directory=PWD)
2. Check for existing codebase diagram:
   mem_search(query="codebase diagram", topic_key="codebase/diagram/{PROJECT_NAME}")
3. If NO diagram found (new project):
   - Call discover_codegraph_contexts → switch_context → get_repository_stats
   - If repo not indexed: add_code_to_graph(path=PWD, is_dependency=false)
   - Call find_most_complex_functions(limit=10) and find_dead_code()
   - Synthesize into codebase diagram
   - Save diagram to Engram with topic_key="codebase/diagram/{PROJECT_NAME}"
4. If diagram FOUND (existing project):
   - Load diagram via mem_get_observation
   - Verify CGC context is current: discover_codegraph_contexts → switch_context
5. Call mem_context to load recent session history
6. Call mem_search for the current task topic (proactive search)
7. Then reply to the user
```

**CRITICAL: Prevent duplicate observations.** Before creating a NEW observation, always SEARCH first:
```
# Before saving a diagram:
mem_search(query="codebase diagram", topic_key="codebase/diagram/{PROJECT_NAME}")
# If results found → use mem_update(id=existing_id) instead of mem_save

# Before saving a decision:
mem_search(query="your decision topic")
# If results found → use mem_suggest_topic_key → reuse topic_key for upsert
```

Over-saving is safe (Engram deduplicates), but creating multiple observations for the same topic wastes memory and creates confusion. Search first, update if exists.

If you skip steps 1–5, you are flying blind. The codebase diagram is your map. Past session context is your compass.

### DURING SESSION (after significant work)

After ANY of these events, call `mem_save` IMMEDIATELY — do not wait, do not batch:

- Bug fix completed
- Architecture or design decision made
- Non-obvious discovery about the codebase
- Configuration change or environment setup
- Pattern established (naming, structure, convention)
- User preference or constraint learned

**Template:**
```
mem_save(
  title="Verb + what — short, searchable",
  type="bugfix|decision|architecture|discovery|pattern|config|preference",
  scope="project",
  content="""
**What**: One sentence — what was done
**Why**: What motivated it
**Where**: Files or paths affected
**Learned**: Gotchas, edge cases (omit if none)
"""
)
```

**For evolving topics:**
```
1. Call mem_suggest_topic_key(title="Your topic", type="decision")
2. Reuse that topic_key in all subsequent mem_save calls on that topic
```

### END OF SESSION (before saying "done")

You MUST run this checklist BEFORE saying "done" / "that's it" / "finished":

```
□ mem_session_start called at session beginning
□ mem_context checked for relevant past work
□ mem_save called after every bugfix / decision / discovery / config change / pattern / user preference
□ User prompts saved with mem_save_prompt (if user asked something significant)
□ mem_session_summary called with complete Goal/Instructions/Discoveries/Accomplished/Next Steps/Relevant Files
□ mem_session_end called to formally close session
```

If ANY box is unchecked, complete it NOW. Do not end the session with unchecked boxes.

**Session Summary Template:**
```
mem_session_summary(
  content="""
## Goal
[What we were working on this session]

## Instructions
[User preferences or constraints discovered — skip if none]

## Discoveries
- [Technical finding 1]
- [Technical finding 2]

## Accomplished
- ✅ [Completed task 1]
- ✅ [Completed task 2]

## Next Steps
- [What remains to be done — for the next session]

## Relevant Files
- path/to/file — [what it does or what changed]
"""
)
```

### AFTER COMPACTION

If you see a message about compaction or context reset:

1. IMMEDIATELY call `mem_session_summary` with the compacted summary content
2. Then call `mem_context` to recover additional context from previous sessions
3. Only THEN continue working

Do not skip step 1. Without it, everything done before compaction is lost from memory.

## Passive Capture

At the end of significant responses, include:

```
## Key Learnings:
1. [Learning 1]
2. [Learning 2]
```

Or call `mem_capture_passive(content)` directly.

## Recovery (When You Messed Up)

1. **Missed mem_session_start**: Call it now. Then mem_context.
2. **Missed saves**: Retrospective mem_save with "RETROSPECTIVE" in title.
3. **Missed mem_session_summary**: Call it now with "RETROSPECTIVE" in Goal.
4. **After compaction without summary**: mem_session_summary(compacted_content) → mem_context → continue.
5. **Duplicate saves**: Engram deduplicates automatically. Over-save is safe. Under-save is not.

## Anti-Patterns (NEVER DO THESE)

- ❌ Batch multiple saves into one — call mem_save immediately after each event
- ❌ Wait until the end of the session to save — memories decay, details get lost
- ❌ Skip mem_session_summary because "it was a small session" — small sessions contain critical context
- ❌ Create a new observation for a correction — use mem_update with the observation ID
- ❌ Use the same topic_key for unrelated topics — different topics must not overwrite each other
- ❌ Ignore compaction messages — always recover with mem_session_summary + mem_context

## Why This Matters

The next session starts blind without your memories. Every save is a gift to your future self. Every skipped save is a hole in your brain that the next agent will fall into.

Save early. Save often. Save completely.
