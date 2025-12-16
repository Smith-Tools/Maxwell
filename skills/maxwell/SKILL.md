---
name: maxwell
description: Intelligent orchestrator of Apple development knowledge. Routes queries across WWDC (sosumi), functional patterns (pointfree), and personal discoveries. Analyzes questions and synthesizes comprehensive answers from multiple sources.
allowed-tools: Bash, Grep, Read
---

# Maxwell - Knowledge Orchestrator

Maxwell intelligently synthesizes knowledge from multiple sources to answer complex developer questions:

- **sosumi**: 12,500+ WWDC transcript chunks (2014-2025) - Official Apple guidance
- **pointfree**: Point-Free episodes - Functional programming patterns, Swift advanced techniques
- **discoveries**: 50+ personal case studies and team patterns

## When to Use Maxwell

Maxwell is your go-to for:
- 🧩 **Architectural questions** - How should I structure this?
- 🍎 **Framework integration** - How do WWDC recommendations work with my code?
- 🎓 **Learning concepts** - Show me WWDC + functional patterns on this topic
- 🐞 **Debugging** - Search known issues and personal discoveries
- **Complex multi-domain problems** - "How do I sync RealityKit with SwiftUI state?"
- **Team patterns** - "How have we solved this before?"

## Orchestration Strategy

### Step 1: Analyze the Query

Classify the question to determine which knowledge sources are relevant:

**WWDC-primary indicators** (search sosumi first):
- Framework APIs: "How do I use RealityKit?", "SwiftUI state management"
- Apple technologies: "visionOS", "ARKit", "CloudKit", "SharePlay"
- Official guidance: "best practices", "WWDC session about..."
- Spatial computing, AR/VR features
- iOS/macOS/watchOS platform-specific features

**Point-Free-primary indicators** (search pointfree first):
- Functional programming patterns: "functional composition", "monads", "pure functions"
- Advanced Swift techniques: "type erasure", "opaque types", "generics constraints"
- Parser combinators, functional design patterns
- Swift language deep dives
- Abstract mathematics in Swift

**Multi-source questions** (search both strategically):
- Cross-domain: "How do I sync RealityKit with SwiftUI state?"
- Pattern + implementation: "functional approach to view state management"
- Architecture questions spanning frameworks

**Personal discovery indicators** (check discoveries):
- Team-specific patterns: "How have we solved..."
- Project learnings: "Past issues with..."
- Known gotchas: "Trap we found..."

### Step 2: Route Intelligently

**Single-source queries**: Search only the primary source
- Fast, focused results
- No irrelevant noise
- Example: "RealityKit animation" → search sosumi only

**Multi-source queries**: Search primary first, then secondary if primary is weak
- Primary source: full results
- Secondary source: Only if primary has <3 high-quality results (score >0.65)
- Example: "How do I structure state in complex RealityKit+SwiftUI app?"
  1. Search sosumi for architecture patterns
  2. If weak results, search pointfree for functional state patterns

**Comparative questions**: Search both, compare approaches
- "What's the difference between..." → Both databases
- Present results side-by-side with source context
- Help user see different approaches

### Step 3: Search Execution

**WWDC/Apple (sosumi)**:
```bash
rag search "<query>" --database ~/.smith/rag/sosumi.db --limit 5
```
- Start with limit=5 to avoid noise
- Look for score >= 0.70 as "good relevance"
- Increase limit only if first results are weak

**Point-Free (pointfree)**:
```bash
rag search "<query>" --database ~/.smith/rag/pointfree.db --limit 5
```
- Functional programming, advanced Swift techniques
- Swift design patterns
- Language-level features

**Personal Discoveries**:
```bash
grep -r "<pattern>" ~/.claude/resources/discoveries/ --include="*.md"
```
- Team-specific learnings
- Documented gotchas and solutions

### Step 4: Combine and Interpret

**When combining results**:
1. **Source context matters** - Lead with the most authoritative source for the question
2. **Relevance > quantity** - Prefer 2 high-quality results from the right source over 10 mediocre ones
3. **Cross-reference insights** - Show how WWDC guidance differs from functional patterns
4. **Address gaps** - If sources contradict, explore why (pragmatism vs. theory)

**Example combination**:
- User: "How should I manage state in a complex RealityKit experience?"
- Search sosumi → Returns WWDC sessions on RealityKit architecture
- Combine with pointfree insights on functional state management
- Result: "WWDC recommends X for RealityKit, but here's how to make it composable with functional patterns..."

## How to Search Personal Discoveries

Personal discoveries are your team's documented learnings. Here's how to access them:

### Search All Discoveries by Topic
```bash
grep -r "nested reducer" ~/.claude/resources/discoveries/ --include="*.md" -i
grep -r "RealityKit" ~/.claude/resources/discoveries/ --include="*.md" -i
grep -r "visionOS" ~/.claude/resources/discoveries/ --include="*.md" -i
```

### List All Discoveries
```bash
ls -1 ~/.claude/resources/discoveries/DISCOVERY-*.md | sort
```

### Read a Specific Discovery
```bash
cat ~/.claude/resources/discoveries/DISCOVERY-14-NESTED-REDUCER-GOTCHAS.md
```

**Key Discoveries (Quick Reference)**:
- `DISCOVERY-12-MODULE-BOUNDARY-VIOLATION.md` - Architecture boundaries (850-line reducer anti-pattern)
- `DISCOVERY-14-NESTED-REDUCER-GOTCHAS.md` - TCA composition patterns
- `DISCOVERY-15-PRINT-OSLOG-PATTERNS.md` - Logging best practices
- Plus 45+ other documented case studies covering Swift, TCA, SwiftUI, visionOS, RealityKit

## When to Not Search

**Skip Maxwell entirely if**:
- Question is about API documentation (point them to Developer.apple.com)
- Needs specific implementation details (user should read source code)
- Outside scope: web development, non-Apple platforms
- Better served by other tools (profiling → Instruments, benchmarking → performance tools)

## Examples of Intelligent Routing

### Example 1: RealityKit Animation
**Query**: "How do I pause and resume animations in RealityKit?"
- **Classify**: WWDC-primary (Apple framework API)
- **Search**: sosumi only
- **Limit**: 5
- **Why**: Direct API question, sosumi is authoritative

### Example 2: State Management Architecture
**Query**: "How should I structure state for a complex app with multiple domains?"
- **Classify**: Multi-source (architecture + patterns)
- **Search sosumi first**: Architecture patterns from WWDC
- **Evaluate**: If results are strong (score >0.68), present those
- **Consider pointfree**: If asking for functional approach, add pointfree insights
- **Combine**: "WWDC recommends [X], here's how to make it more composable..."

### Example 3: SwiftUI + RealityKit Integration
**Query**: "I'm building a RealityKit experience controlled by SwiftUI"
- **Classify**: Cross-domain (sosumi for RealityKit, may need SwiftUI state patterns)
- **Search sosumi**: RealityKit + SwiftUI integration
- **If weak**: Search pointfree for functional state approaches
- **Combine**: Integration patterns from WWDC + functional state management theory

### Example 4: Parser Combinators
**Query**: "How do I implement parser combinators in Swift?"
- **Classify**: Point-Free primary (functional programming pattern)
- **Search pointfree first**: Parser combinator episodes
- **Skip sosumi**: Not an WWDC topic
- **Result**: Point-Free is authoritative, don't waste context on sosumi

### Example 5: Known Gotcha
**Query**: "We keep running into race conditions with @Shared state in our app"
- **Classify**: Personal discovery + sosumi validation
- **Search discoveries**: Look for "@Shared race condition" patterns
- **If found**: Present team's known solution
- **Validate**: Search sosumi for official guidance on @Shared thread safety
- **Combine**: "Here's how we've handled this, validated against WWDC guidance..."

## Tools Available

- **Bash**: Execute `rag search` commands to query databases
- **Read**: Load entire files from discoveries if needed
- **Grep**: Search personal discoveries when looking for known patterns

## Architecture: Skill vs. CLI

**This Skill (Maxwell)**: Provides intelligent guidance on orchestrating knowledge sources
- Runs automatically when you ask Apple development questions
- Analyzes your query to determine which sources are relevant
- Routes searches intelligently to avoid noise
- Combines results from multiple sources for comprehensive answers

**Maxwell CLI (`maxwell search`)**: Simple convenience tool for direct queries
- Available at `~/.local/bin/maxwell`
- Searches all available databases
- Useful for quick lookups
- Not a replacement for the intelligent Skill

**Recommended**: Let this Skill handle complex questions - it will orchestrate intelligently. Use the CLI only for quick searches where you already know which source you want.

## Knowledge Sources

### sosumi: WWDC & Apple Official
- **Content**: 12,500+ WWDC transcript chunks (2014-2025)
- **Coverage**: Official Apple guidance on frameworks, APIs, best practices
- **Use**: Framework questions, official recommendations, spatial computing
- **Engine**: MLX embeddings, Qwen3-0.6B model, entirely offline

### pointfree: Functional Programming & Advanced Swift
- **Content**: Point-Free episodes on functional programming
- **Coverage**: Parser combinators, type theory, advanced Swift patterns
- **Use**: Functional architecture, language deep dives, design patterns
- **Engine**: Same MLX + RAG system

### discoveries: Personal Case Studies
- **Content**: Team-documented patterns and gotchas
- **Coverage**: Lessons learned, known issues, solutions specific to your team
- **Use**: When looking for "how have we solved this before?"
- **Storage**: `~/.claude/resources/discoveries/`

## Technical Stack

- **Search Engine**: SmithRAG (semantic search)
- **Embeddings**: MLX Qwen3-Embedding-0.6B-4bit (1024d vectors)
- **Execution**: Offline on Apple Silicon GPU (no external API calls)
- **Databases**: `~/.smith/rag/sosumi.db`, `~/.smith/rag/pointfree.db`
