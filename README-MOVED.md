# ⚠️ Maxwell Has Moved

**As of November 22, 2025**: Maxwell has been restructured and relocated to:

```
/Volumes/Plutonian/_Developer/Smith Tools/Maxwell
```

This location reflects Maxwell's new architecture:
- **One unified Maxwell subagent** (no "maxwell-unified")
- **One Maxwell skill** with auto-triggered routing logic
- **Unified knowledge layer** shared by both
- **Organized by skill**: skill-tca/, skill-shareplay/, etc.
- **Lives within Smith Tools** ecosystem

---

## What Changed

### Old Structure
```
/Volumes/Plutonian/_Developer/Maxwells/
├── TCA/
│   ├── agent/maxwell-tca.md
│   ├── skill/
│   └── validation/
├── SharePlay/
│   ├── agent/maxwell-shareplay.md
│   ├── skill/
│   └── ...
└── PointFree/
```

### New Structure
```
/Volumes/Plutonian/_Developer/Smith Tools/Maxwell/
├── skill-tca/
│   └── skill/
├── skill-shareplay/
│   └── skill/
├── skill-maxwell/
│   └── SKILL.md (auto-trigger + routing)
├── subagent/
│   └── maxwell.md (unified, handles cross-domain)
└── documentation/
```

---

## Key Points

1. **Single subagent**: maxwell.md handles both simple and complex questions
   - Single-domain? Queries patterns table
   - Cross-domain? Reads code, synthesizes solution

2. **Single skill**: maxwell skill auto-triggers with routing logic
   - Quick patterns? Answered instantly
   - Complex problems? Recommends subagent invocation

3. **Same knowledge**: Both share unified SQLite knowledge layer
   - patterns table
   - integrations table (cross-domain)
   - anti_patterns table
   - discoveries table

---

## Where to Find Things

### Documentation
- **`ARCHITECTURE-DECISION.md`** → Why Maxwell exists, architectural rationale
- **`KNOWLEDGE-MAINTENANCE.md`** → How to extend Maxwell with patterns
- **`START-HERE.md`** → First-time orientation guide
- **`README.md`** → Project overview

All located in: `/Volumes/Plutonian/_Developer/Smith Tools/Maxwell/`

### Skills & Subagent
- **skill-maxwell/SKILL.md** → Auto-triggered skill with routing logic
- **subagent/maxwell.md** → Unified subagent for complex problems
- **skill-tca/, skill-shareplay/, etc.** → Specialized skills

All located in: `/Volumes/Plutonian/_Developer/Smith Tools/Maxwell/`

---

## Old Location

This directory (`/Volumes/Plutonian/_Developer/Maxwells/`) is being kept for reference only and is now **deprecated**.

The original files are preserved here for historical reference and git history, but all active development happens in the new location.

---

## Next Steps

1. Update any scripts/configurations pointing to `/Volumes/Plutonian/_Developer/Maxwells/` to use `/Volumes/Plutonian/_Developer/Smith Tools/Maxwell/`
2. Register the new Maxwell skill and subagent in your Claude Code configuration
3. Refer to `START-HERE.md` in the new location for orientation

---

**Questions?** See `/Volumes/Plutonian/_Developer/Smith Tools/Maxwell/START-HERE.md`

**Questions about why Maxwell was restructured?** See `/Volumes/Plutonian/_Developer/Smith Tools/Maxwell/ARCHITECTURE-DECISION.md`
