# Maxwell Agent - Startup Contradiction Check

## When This Runs

**Execute when Maxwell agent starts up** (single lightweight check):
- Before handling user requests
- After database initialization
- During agent health check

## Startup Check Logic

### Step 1: Quick Database Scan
```sql
-- Get recent patterns that might have contradictions
SELECT domain, COUNT(*) as pattern_count
FROM patterns
WHERE created_at > date('now', '-7 days')
GROUP BY domain
HAVING COUNT(*) > 1;
```

### Step 2: Cross-Domain Keyword Scan
```sql
-- Look for obvious contradictions across domains
SELECT p1.domain, p1.name, p1.recommendation,
       p2.domain, p2.name, p2.recommendation
FROM patterns p1, patterns p2
WHERE p1.id < p2.id
AND (p1.recommendation LIKE '%single%' AND p2.recommendation LIKE '%multiple%'
     OR p1.recommendation LIKE '%only%' AND p2.recommendation LIKE '%both%'
     OR p1.recommendation LIKE '%owner%' AND p2.recommendation LIKE '%shared%');
```

### Step 3: Report Status
If contradictions found: **⚠️ Warning**: Show summary
If no contradictions: **✅ Healthy**: Proceed normally

## Agent Integration

### Add to Agent Startup Sequence
```markdown
1. Initialize database connection
2. Run contradiction startup check
3. If critical contradictions found → Alert user
4. If no issues → Ready for requests
5. Route to appropriate domain skill
```

## Response Format

### Healthy Start
```
✅ Maxwell Agent Ready
📊 237 patterns across 3 domains
🔍 No critical contradictions detected
🎯 Route: TCA | SharePlay | VisionOS
```

### Contradiction Warning
```
⚠️ Maxwell Agent Ready (with warnings)
📊 237 patterns across 3 domains
🚨 1 critical contradiction found:
   • TCA: "@Shared Single Owner" vs "@Shared Multiple Writers"
💡 Use contradiction detection skill when adding new patterns
🎯 Route: TCA | SharePlay | VisionOS
```

## Performance Considerations

- **Lightweight**: Quick scan only, not deep analysis
- **Cached results**: Store check result for session
- **Scheduled**: Run at startup, not on every request

---

**This keeps contradiction detection lightweight at agent level while preserving domain expert systems!**