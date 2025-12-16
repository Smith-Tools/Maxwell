---
name: maxwell
description: Intelligent orchestrator of all development knowledge. Routes queries across WWDC (sosumi), functional patterns (pointfree), and personal discoveries (scully). Analyzes questions and synthesizes comprehensive answers from all available sources.
allowed-tools: Bash, Grep, Read
---

# Maxwell - Knowledge Orchestrator

Maxwell intelligently orchestrates across all knowledge sources to answer complex developer questions:

- **sosumi**: 12,500+ WWDC transcript chunks (2014-2025) - Official Apple guidance
- **pointfree**: Point-Free episodes - Functional programming patterns, Swift advanced techniques
- **scully**: Personal discoveries and team case studies - Your documented learnings

## When to Use Maxwell

Maxwell is your go-to for:
- 🧩 **Architectural questions** - How should I structure this?
- 🍎 **Framework integration** - How do WWDC recommendations work with my code?
- 🎓 **Learning concepts** - Show me WWDC + functional patterns on this topic
- 🐞 **Debugging** - Search known issues in WWDC, Point-Free, and team discoveries
- **Complex multi-domain problems** - "How do I sync RealityKit with SwiftUI state?"
- **Functional programming patterns** - "How do I approach state management functionally?"
- **Team learnings** - "How have we solved this before?"

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

**Scully-primary indicators** (search discoveries first):
- Team-specific patterns: "How have we solved..."
- Project learnings: "We discovered...", "We ran into..."
- Known gotchas: "Trap we hit...", "Edge case we found..."
- Team architectural decisions

**Multi-source questions** (search strategically):
- Cross-domain: "How do I sync RealityKit with SwiftUI state?"
- Pattern + implementation: "functional approach to view state management"
- Architecture questions spanning frameworks
- "How does WWDC guidance match what we've learned?"


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

**Personal Discoveries (scully)** - If available:
```bash
grep -r "<pattern>" ~/.claude/resources/discoveries/ --include="*.md" -i
```
- Team-specific learnings and case studies
- Known issues and solutions
- Documented gotchas

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

## When to Not Use Maxwell

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

### Example 5: Team Pattern Lookup
**Query**: "How have we handled @Shared race conditions before?"
- **Classify**: Scully primary (team-specific learning)
- **Search discoveries first**: Look for @Shared or race condition patterns
- **If found**: Present team's documented solution
- **Optional**: Search sosumi for official thread safety guidance
- **Result**: Team pattern validated against WWDC guidance

### Example 6: Advanced Swift Techniques
**Query**: "How do I implement parser combinators in Swift?"
- **Classify**: Point-Free primary (functional programming pattern)
- **Search pointfree first**: Parser combinator episodes and techniques
- **Skip sosumi**: Not a WWDC topic
- **Result**: Point-Free is authoritative for this domain

## Tools Available

- **Bash**: Execute `rag search` commands to query sosumi/pointfree databases
- **Grep**: Search personal discoveries in `~/.claude/resources/discoveries/`
- **Read**: Load full search result chunks or discovery files for deeper understanding

## Architecture: Skill vs. CLI

**This Skill (Maxwell)**: Intelligent orchestrator of all knowledge sources
- Runs automatically when you ask development questions
- Analyzes your query to determine which sources are most relevant
- Routes searches intelligently: sosumi (WWDC), pointfree (patterns), scully (team learnings)
- Combines results thoughtfully - avoiding noise while being comprehensive
- Example: "How do we handle X?" searches discoveries first, then validates against WWDC

**Maxwell CLI (`maxwell search`)**: Simple convenience tool for direct multi-source searches
- Available at `~/.local/bin/maxwell`
- Searches all available databases at once
- Useful for quick exploratory searches
- Not intelligent routing - just parallel search of all sources

**Recommended**: Let this Skill handle your questions - it will orchestrate intelligently. Use the CLI only for exploratory searches where you want all sources combined.

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

## Related Skills

- **smith**: Swift/TCA architecture validation and analysis (complements Maxwell's guidance)

## Technical Stack

- **Search Engine**: SmithRAG (semantic search for RAG databases)
- **Embeddings**: MLX Qwen3-Embedding-0.6B-4bit (1024d vectors)
- **Execution**: Offline on Apple Silicon GPU (no external API calls)
- **Knowledge Bases**:
  - `~/.smith/rag/sosumi.db` - WWDC transcripts
  - `~/.smith/rag/pointfree.db` - Point-Free episodes
  - `~/.claude/resources/discoveries/` - Personal discoveries (file-based, searched via Grep)
