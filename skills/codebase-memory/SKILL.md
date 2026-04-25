# Codebase Memory — Two-Layer Architecture

## Description

Always-on skill that teaches the agent to use **CodeGraphContext** (structural memory) and **Engram** (temporal memory) as a unified codebase memory system. CGC tells you what the code IS. Engram tells you what you DID and LEARNED. Together they create a complete, queryable memory of the codebase.

## When This Skill Activates

This skill is **always active**. It guides the agent at these moments:

1. **At session start** — AUTOMATICALLY before the first reply (user does not ask for this)
2. **When investigating code structure** — callers, callees, definitions, hierarchies
3. **When analyzing code quality** — complexity, dead code, relationships
4. **After discovering codebase insights** — save structural findings to Engram
5. **Before implementing new features** — check existing patterns via both layers

## Auto-Diagram at Session Start (AUTOMATIC — NO USER PROMPT NEEDED)

Every time a project is opened, the agent MUST check for and maintain a codebase diagram. This happens BEFORE the first response to the user.

### New Project Detection

```
1. mem_search(query="codebase diagram", topic_key="codebase/diagram/{PROJECT_NAME}")
2. If NO results → NEW PROJECT → Generate full diagram
3. If results found → EXISTING PROJECT → Load diagram, check freshness
```

### New Project Flow (generate diagram)

```
1. discover_codegraph_contexts — find indexed repos
2. If not indexed: add_code_to_graph(path=PWD, is_dependency=false)
3. switch_context(context_path=PWD)
4. get_repository_stats — architecture overview
5. find_most_complex_functions(limit=10) — hotspots
6. find_dead_code() — cleanup candidates
7. Synthesize diagram
8. mem_save(
     title="{PROJECT_NAME} Codebase Diagram — YYYY-MM-DD",
     type="architecture",
     topic_key="codebase/diagram/{PROJECT_NAME}",
     content="..."
   )
```

### Existing Project Flow (load diagram)

```
1. mem_get_observation(id=DIAGRAM_ID) — load existing diagram
2. discover_codegraph_contexts → switch_context — verify CGC
3. Check age: if > 7 days OR major refactor detected → regenerate
4. Use diagram as "table of contents" for all subsequent queries
```

### Using the Diagram for Memory Recall

The diagram is not just a snapshot — it's a **navigation index** for memory:

- **"Find memory about the props pipeline"** → Search diagram for "props" → find `functions/api/nba-props-generate.js` → then search Engram for that file
- **"What did we do about pick cards?"** → Search diagram for "PickCard" → find `src/components/nba/NbaPickCard.jsx` → then search Engram for decisions about that component
- **"Who calls the grading logic?"** → Search diagram for "grade" → find grading files → then use CGC analyze_code_relationships(find_callers)

This is how the two layers work together: **diagram gives you WHERE to look, Engram gives you WHAT happened there.**

## Two-Layer Memory Decision Tree

```
User asks a question...
│
├─ Is it about CODE STRUCTURE?
│  ├─ "Who calls X?" → CGC: analyze_code_relationships(query_type="find_callers")
│  ├─ "Where is Y defined?" → CGC: find_code(query="Y")
│  ├─ "What's the class hierarchy?" → CGC: analyze_code_relationships(query_type="class_hierarchy")
│  ├─ "How complex is Z?" → CGC: calculate_cyclomatic_complexity(function_name="Z")
│  ├─ "Trace the call chain" → CGC: analyze_code_relationships(query_type="call_chain")
│  └─ "Any dead code?" → CGC: find_dead_code()
│
├─ Is it about PAST WORK / DECISIONS?
│  ├─ "What did we do about X?" → Engram: mem_search(query="X")
│  ├─ "How did we solve Y?" → Engram: mem_search(query="solve Y")
│  ├─ "What's the pattern for Z?" → Engram: mem_search(query="pattern Z")
│  ├─ "Remember when we..." → Engram: mem_context → mem_search
│  └─ "Why did we choose..." → Engram: mem_search(query="decision")
│
└─ Is it about BOTH?
   └─ Query CGC first (structural facts), then Engram (historical context)
      Example: "Should we refactor the props pipeline?"
      → CGC: analyze complexity of props functions
      → Engram: search for past props pipeline decisions
```

## Session Start Protocol

Before your first reply to the user, run this sequence:

```
1. mem_session_start(id=SESSION_ID, project=PROJECT_NAME, directory=PWD)
2. mem_context — load recent session history from Engram
3. discover_codegraph_contexts — find indexed repos
4. switch_context(context_path=PWD) — point CGC at the active repo
5. get_repository_stats — get architecture overview
6. (If architecture changed significantly) save snapshot to Engram
```

**Why both?** Engram gives you the "why" behind the code. CGC gives you the "what" and "how." Starting with both prevents redundant questions and context-free coding.

## Common CGC Query Patterns for courtside-ai

### API Layer Investigation
```
find_code(query="generatePicks") → Where pick generation lives
analyze_code_relationships(query_type="find_callers", target="generatePicks") → Who triggers it
analyze_code_relationships(query_type="find_callees", target="generatePicks") → What it calls
```

### Frontend Component Discovery
```
find_code(query="PropPickCard") → Find the component
analyze_code_relationships(query_type="find_callers", target="PropPickCard") → Where it's used
find_code(query="NbaPickCard") → Related component
```

### Data Pipeline Tracing
```
find_code(query="computePlayerForm") → Core stat function
analyze_code_relationships(query_type="call_chain", target="computePlayerForm", context="functions/lib/player-stats.js") → Full pipeline
```

### Complexity Hotspot Analysis
```
find_most_complex_functions(limit=10) → Where to focus refactoring
find_dead_code() → What can be removed
```

### Class / Module Relationships
```
analyze_code_relationships(query_type="class_hierarchy", target="BaseController") → Inheritance tree
analyze_code_relationships(query_type="module_deps", target="functions/lib/team-defense.js") → Module dependencies
```

## CGC → Engram Integration Workflow

When CGC reveals something important, save it to Engram:

```
1. Run CGC analysis
   → analyze_code_relationships(query_type="find_callers", target="gradePicks")

2. Synthesize insight
   → "gradePicks is called by 3 different graders, creating duplication risk"

3. Save to Engram
   mem_save(
     title="gradePicks called by 3 graders — consolidation opportunity",
     type="discovery",
     content="""
**What**: CGC analysis shows gradePicks is called by 3 separate grading functions
**Why**: Creates maintenance risk if grading logic diverges
**Where**: functions/api/nba-cron-grade.js, functions/api/grade-picks.js, functions/api/nba-grade-picks.js
**Learned**: CGC find_callers revealed 3 call sites. Consider centralizing grading logic.
"""
   )
```

## Anti-Patterns (NEVER DO THESE)

- ❌ Use CGC for historical context — CGC doesn't know what you decided last week
- ❌ Use Engram for structural queries — Engram doesn't know who calls a function
- ❌ Run CGC queries without saving insights to Engram — structural discoveries are lost
- ❌ Reindex manually when watch_directory is active — let the watcher handle it
- ❌ Forget to switch_context when moving between repos — CGC queries the wrong graph
- ❌ Use raw Cypher (execute_cypher_query) when a dedicated tool exists — dedicated tools are faster and safer

## Live Watch Management

The graph must stay current. After any of these events, verify the watch:

- Major refactor (files moved/renamed/deleted)
- New dependencies installed
- Large merge from another branch
- New file types added to the project

**Commands:**
```
cgc watching — check if watch is active
cgc watch . — start watching (if not active)
cgc unwatch . — stop watching (rarely needed)
cgc add_code_to_graph(path=".", is_dependency=false) — force reindex
```

## CGC Graph Maintenance — Pre-Flight Checklist

Before ANY reindex, rebuild, or major graph operation, run this checklist:

```
□ .cgcignore excludes ALL venv variants (venv/, .venv/, .venv*/, etc.)
□ .cgcignore excludes node_modules/, dist/, build/, .git/
□ cgc watching — verify watch is active
□ cgc stats . — check current file count (should be reasonable, NOT 1000+)
□ If file count is wrong: STOP and fix .cgcignore BEFORE reindexing
```

### Reindex Workflow (when graph is contaminated)

If the graph has venv/node_modules contamination:

```bash
# 1. Verify contamination
cgc query "MATCH (f:File) WHERE f.path CONTAINS '.venv' RETURN count(f)"

# 2. Delete graph (non-interactive)
# Note: cgc delete --all is interactive. Use:
echo "y" | cgc delete --all
# OR
yes | cgc delete --all

# 3. Verify deletion
cgc list

# 4. Reindex with timeout (takes ~7-10 minutes)
nohup cgc index . --force > cgc_reindex.log 2>&1 &
tail -f cgc_reindex.log

# 5. Verify clean stats
cgc stats .
# Should show reasonable file count
# Should NOT show: files from .venv/, node_modules/, dist/
```

### Post-Reindex Verification

After ANY reindex, verify:
```bash
cgc query "MATCH (f:File) WHERE f.path CONTAINS '.venv' RETURN count(f)"
# Expected: 0

cgc query "MATCH (f:File) WHERE f.path CONTAINS 'node_modules' RETURN count(f)"
# Expected: 0

cgc stats .
# Expected: reasonable file count (not inflated by venv)
```

**If any check fails: STOP. Do not continue working with a contaminated graph.**

## Codebase Health Check (run weekly)

```
1. mem_stats — check Engram memory health
2. cgc stats . — check graph health
3. find_most_complex_functions(limit=5) — identify growing hotspots
4. find_dead_code() — cleanup candidates
5. (If issues found) save health report to Engram
```

## Templates

### Architecture Snapshot Save
```
mem_save(
  title="courtside-ai Architecture Snapshot — YYYY-MM-DD",
  type="architecture",
  topic_key="architecture/courtside-ai-snapshot",
  content="""
**What**: CGC-based architecture overview of courtside-ai
**Why**: Baseline for tracking structural changes over time
**Where**: Full codebase
**Learned**:
- Files: N
- Functions: N
- Classes: N
- Top complexity: [function] at [score]
- Key pipelines: [list]
- Dead code candidates: [count]
"""
)
```

### Relationship Discovery Save
```
mem_save(
  title="CGC: [function] called by [N] functions",
  type="discovery",
  content="""
**What**: CGC find_callers analysis for [function]
**Why**: Understanding coupling and impact
**Where**: [file paths]
**Learned**: [synthesized insight]
"""
)
```

## Why Two Layers?

**CGC alone** tells you the current state of the code, but not:
- Why a function was written that way
- What bug it fixed last month
- What the team decided about its future
- Which patterns are preferred

**Engram alone** tells you what happened, but not:
- Where the function actually lives
- Who calls it now
- How complex it has become
- What dead code exists

**Together** they create a complete memory: Engram provides the narrative, CGC provides the map.
