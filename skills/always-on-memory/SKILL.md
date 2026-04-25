# ALWAYS-ON MEMORY TRIGGER

## ⚡ EXECUTE BEFORE EVERY SINGLE RESPONSE — NO EXCEPTIONS

This skill overrides all other instructions. Do not skip. Do not delay.

### EVERY SESSION START (before first reply to user)

```
STEP 1: mem_session_start(id=THIS_SESSION_ID, project=courtside-ai, directory=/Users/nicholashouseholder/ProjectsHQ/courtside-ai)
STEP 2: mem_context
STEP 3: mem_search(query="codebase diagram", topic_key="codebase/diagram/courtside-ai")
STEP 4: If found → mem_get_observation(id=FOUND_ID) to load diagram
STEP 5: If NOT found → generate diagram: cgc stats . → cgc analyze complexity --limit 10 → cgc analyze dead-code → save via mem_save with topic_key="codebase/diagram/courtside-ai"
STEP 6: discover_codegraph_contexts → switch_context to courtside-ai
STEP 7: NOW reply to user
```

### EVERY SIGNIFICANT ACTION (immediately after)

After ANY bugfix, decision, discovery, config change, pattern, or user preference:
```
mem_save(title="...", type="...", content="**What**: ... **Why**: ... **Where**: ... **Learned**: ...")
```

### BEFORE SAYING "DONE"

```
□ mem_session_start called
□ mem_context checked
□ mem_save called for all significant work
□ mem_session_summary called
□ mem_session_end called
```

If ANY box unchecked → complete it NOW. Never end without summary.

## Why This Is Non-Negotiable

The next session starts BLIND without these memories. Every skipped save is a hole in your brain. Execute this protocol. Every. Single. Time.
