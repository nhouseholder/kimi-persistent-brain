# Memory Scoring

## Description

Lightweight relevance scoring ported from persistent-brain v0.5.0. Surfaces the MOST useful memories first — not just the most recent.

## When This Skill Activates

**Always-on.** After `mem_search` or `mem_context` returns results, re-sort by relevance score before presenting to user or acting on them.

## Scoring Formula

```
score = confidence × recency × frequency

confidence  = 0.5 ^ (days_since_update / 90)
recency     = 1.0 / (1.0 + days_since_update / 30)
frequency   = 1.0 + ln(access_count + 1)  [capped at 2.0]
```

## How to Apply

### After mem_search / mem_context

```
Results come back with updated_at and access_count fields.

1. For each result, compute approximate score:
   - Days old = (now - updated_at) in days
   - confidence ≈ 0.5 ^ (days_old / 90)
   - recency ≈ 1.0 / (1.0 + days_old / 30)
   - frequency ≈ min(2.0, 1.0 + ln(access_count + 1))
   - score = confidence × recency × frequency

2. Re-sort results by score (highest first)

3. Present top results, noting which are "high-confidence" vs "stale"
```

### Heuristic (no math needed)

```
High score indicators:
  ✅ Accessed many times (access_count > 5)
  ✅ Updated recently (< 7 days)
  ✅ Both project + global scope mentioned it

Low score indicators:
  ❌ Never accessed (access_count = 0)
  ❌ Very old (> 60 days) with no updates
  ❌ Superseded by newer same-topic observation
```

## Proactive Application

When user asks about a topic, DON'T just return search results chronologically. Rank them by usefulness:

```
User: "How do we handle auth?"

BAD:  Return 10 results from newest to oldest
GOOD: Return top 3 by score, with notes:
      "Most relevant (score 0.92): JWT refresh token decision (accessed 8x, updated 2 days ago)"
      "Still relevant (score 0.71): OAuth flow architecture (accessed 3x, updated 3 weeks ago)"
      "Possibly stale (score 0.23): Old session cookie config (not accessed, 2 months old)"
```

## Why This Matters

Without scoring, agents drown in memory noise. persistent-brain's scoring raised actionable memory ratio from ~5% to 23.7%. Apply it and your memories stay sharp.
