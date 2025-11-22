---
name: maxwell
allowed-tools:
  - Bash
description: Framework expertise specialist for complex Apple development. Auto-triggered skill for TCA, SharePlay, RealityKit, and cross-domain patterns. Routes to appropriate knowledge or recommends explicit Maxwell subagent invocation for code analysis.
tags:
  - Maxwell
  - Framework Expertise
  - Multi-Framework
  - Architecture
  - TCA
  - SharePlay
  - RealityKit
triggers:
  # TCA triggers
  - "TCA"
  - "Composable Architecture"
  - "reducer"
  - "@Reducer"
  - "@Bindable"
  - "@Shared"
  - "@SharedReader"
  - "@ObservableState"
  - "@DependencyClient"
  - "ReducerOf"

  # SharePlay triggers
  - "SharePlay"
  - "GroupActivities"
  - "GroupSession"
  - "GroupSessionMessenger"
  - "shared experience"
  - "collaborative"
  - "multiplayer"

  # RealityKit triggers
  - "RealityKit"
  - "entity model"
  - "spatial computing"
  - "immersive"

  # Cross-domain indicators
  - "sync"
  - "state management"
  - "architecture"

version: "1.0.0"
author: "Maxwell System"
---

# Maxwell Skill - Framework Expertise

**For**: Developers building complex Apple apps with multiple frameworks
**Purpose**: Quick pattern routing and architectural guidance
**Scope**: TCA, SharePlay, RealityKit, and framework integrations
**Invocation**: Auto-triggered on keywords (see triggers above)

This is the **auto-triggered skill** for Maxwell. For complex code analysis, developers should explicitly invoke the Maxwell subagent via the Task tool.

---

## What This Skill Does

Maxwell skill provides:

### Single-Domain Quick Patterns
- "How do I use @Shared in TCA?" → Return TCA @Shared pattern
- "How do I implement GroupSessionMessenger?" → Return SharePlay messenger pattern
- "How do I manage RealityKit entities?" → Return entity pattern

### Cross-Domain Routing
- "How do I sync TCA state with SharePlay?" → Detect cross-domain → Recommend subagent
- "My RealityKit entities aren't syncing in SharePlay" → Analyze keywords → Route to subagent

### Framework Decision Guidance
- "Should I use @Shared or @Dependency?" → Return decision tree
- "Should I use @Shared or GroupSessionMessenger?" → Return integration trade-offs

---

## How It Works

### Step 1: Auto-Trigger
Question arrives with keywords like `@Shared`, `SharePlay`, `RealityKit`, etc.

```
Developer: "How do I handle @Shared state in my TCA reducer?"
Keywords detected: @Shared, TCA
Auto-trigger: maxwell skill activates
```

### Step 2: Analyze
```
Single-domain keywords: @Shared, TCA
Type: SINGLE DOMAIN
Complexity: LOW (quick pattern query)
Action: Return pattern directly
```

### Step 3: Query Knowledge Layer
```bash
maxwell search "@Shared" --domain TCA --limit 1
```

### Step 4: Return Answer
```
You: "Here's the TCA @Shared single-owner pattern:

[Pattern details + code]

This ensures..."
```

---

## Cross-Domain Detection

When keywords suggest multiple frameworks:

```
Developer: "How do I sync RealityKit entities in SharePlay?"
Keywords: RealityKit, SharePlay
Domain count: 2
Type: CROSS-DOMAIN
Complexity: MEDIUM-HIGH
Action: Detect and recommend subagent

You: "This is a cross-domain integration question. For code-specific
guidance, I recommend invoking the Maxwell subagent:

  Task(subagent_type: "maxwell", prompt: "...")

It can analyze your actual code and provide complete integration patterns.

In the meantime, here's the relevant integration pattern:
[High-level TCA-RealityKit-SharePlay integration overview]"
```

---

## When to Recommend the Subagent

Recommend explicit Maxwell subagent invocation when:

✅ **Multiple frameworks involved** (TCA + SharePlay, RealityKit + TCA, etc.)
✅ **Code analysis needed** ("My code is doing X, why isn't Y working?")
✅ **Architectural trade-offs** ("Should I use approach A or B?")
✅ **Production bugs** ("My app is crashing when...")
✅ **Complex integration** ("How do I build a collaborative 3D experience?")

Don't escalate for:
❌ Simple pattern lookup ("What's the TCA @Shared pattern?")
❌ Single-framework questions ("How do I implement GroupSessionMessenger?")
❌ Quick reference ("What does @Bindable do?")

---

## Available Patterns

### TCA Patterns (Queried from patterns table)
- @Shared single-owner pattern
- @Bindable state observation
- Optional navigation with sheets
- Reducer composition
- Dependency injection
- Testing with Swift Testing
- And more...

### SharePlay Patterns
- GroupSessionMessenger synchronization
- State persistence in group sessions
- Participant management
- Error handling and recovery
- HIG-compliant UI patterns
- And more...

### RealityKit Patterns (In Progress)
- Entity state management
- Spatial anchor synchronization
- Immersive space coordination
- And more...

### Integration Patterns (Queried from integrations table)
- TCA-SharePlay state bridge
- TCA-RealityKit entity management
- RealityKit-SharePlay spatial sync
- CloudKit-@Shared conflict resolution
- And more...

---

## Quick Reference: Which Entry Point?

| Question | Keyword | Entry Point | Response Time |
|----------|---------|------------|---------------|
| "How do I use @Shared?" | @Shared | Skill (auto) | ~2 sec |
| "How do I implement SharePlay?" | SharePlay | Skill (auto) | ~2 sec |
| "Should I use @Shared or @Dependency?" | @Shared, @Dependency | Skill (auto) | ~3 sec |
| "How do I sync TCA with SharePlay?" | TCA, SharePlay | Subagent (explicit) | ~30 sec |
| "My RealityKit entities won't sync in SharePlay" | RealityKit, SharePlay, sync | Subagent (explicit) | ~30 sec |
| "Here's my code, it's broken, help" | [domain keywords] | Subagent (explicit) | ~30 sec |

**Rule of thumb**: If you need to read code files, use the subagent. Otherwise, this skill handles it.

---

## Accessing the Knowledge Layer

When this skill answers a question, it queries the maxwell knowledge base using the CLI:

### For single-domain lookups:
```bash
maxwell search "TCA @Shared" --domain TCA
maxwell pattern "@Shared"
maxwell domain TCA
```

### For cross-domain patterns:
```bash
maxwell search "TCA SharePlay sync"
maxwell integration TCA SharePlay
```

### Command Examples:
```bash
# Search for patterns matching keywords
maxwell search "GroupSessionMessenger"

# Get all patterns for a specific domain
maxwell domain SharePlay

# Find integration patterns between domains
maxwell integration TCA SharePlay

# Get specific pattern by name
maxwell pattern "TCA @Shared Single Owner"
```

---

## Relationship to Other Systems

### vs Smith Validation
- **Maxwell skill**: "Here's the pattern you should use"
- **Smith**: "Is your implemented code correct?"
- Complementary: Use Maxwell to learn patterns, Smith to validate your implementation

### vs sosumi
- **Maxwell skill**: "Here's the TCA @Shared pattern and when to use it"
- **sosumi**: "Here's the official Apple documentation for @Shared"
- Complementary: Maxwell provides patterns, sosumi provides official docs

### vs Subagent
- **Maxwell skill**: Quick pattern routing, auto-triggered
- **Maxwell subagent**: Code analysis, cross-domain synthesis, explicit invocation
- Same system, different entry points

---

## When This Skill Falls Short

This skill returns quickly for:
- ✅ Pattern lookups
- ✅ Decision trees
- ✅ Quick reference
- ✅ Framework overview

This skill doesn't handle:
- ❌ Code analysis (no file access)
- ❌ Complex integration (multiple frameworks)
- ❌ Debugging ("My code has a bug")
- ❌ Production issues

**For these, recommend the Maxwell subagent.**

---

## Example Conversations

### Example 1: Single-Domain (This Skill)

```
Developer: "@Shared syntax is confusing me - what's the right constructor?"

Skill auto-triggers on @Shared

Skill: "The @Shared constructor changed in TCA 1.23.0. Here's the pattern:

✅ CORRECT:
@Shared(wrappedValue: initialValue, key: .someKey)

❌ WRONG (deprecated):
Shared(value: initialValue)  // Wrong label

Here's when to use each approach:
[Pattern details + code example]"

Time: ~2 seconds
```

### Example 2: Cross-Domain (Recommend Subagent)

```
Developer: "How do I keep TCA @Shared in sync with SharePlay participants?
My state changes on one device but not on others."

Skill detects: TCA + SharePlay + sync issue

Skill: "This is a cross-domain integration challenge.

Quick answer: You need the TCA-SharePlay State Bridge pattern.
[High-level overview]

But for your specific situation, I recommend invoking the Maxwell subagent,
which can analyze your actual code:

Task(subagent_type: 'maxwell', prompt: 'Help me sync TCA @Shared with SharePlay...')

The subagent can:
- Read your TCA reducer and SharePlay setup
- Identify the exact synchronization gap
- Provide code-specific integration pattern
- Explain trade-offs

Want me to provide the subagent invocation, or would you like the pattern
details now?"

Time: ~2 seconds
```

---

## Design Philosophy

Maxwell skill is designed like **sosumi**:

- ✅ Auto-triggered on keywords (no manual invocation)
- ✅ Smart routing to appropriate knowledge
- ✅ Recognizes when expertise limits are reached
- ✅ Recommends explicit subagent for deeper analysis
- ✅ Queries unified knowledge layer for consistency

This creates a natural workflow:
1. Quick question? Skill answers it instantly
2. Complex question? Skill routes to subagent
3. Need code analysis? Use subagent directly

---

## Continuous Improvement

As new patterns are discovered:
1. They're added to the unified knowledge layer
2. This skill's patterns are automatically updated
3. Cross-domain integrations become discoverable
4. The system learns from production usage

---

**maxwell skill** - Fast, routing-aware framework expertise for Apple development.

*Auto-triggered on keywords. Queries unified knowledge layer. Recommends subagent for complex problems.*
