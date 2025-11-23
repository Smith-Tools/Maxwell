---
name: Maxwell Meta Expert
description: Self-reflection and meta-cognition for the Maxwell skill ecosystem. Provides insight into how Maxwell skills work together, their interactions, coordination patterns, and self-improvement strategies for the entire system.
tags:
  - "Maxwell"
  - "meta"
  - "self-reflection"
  - "skill coordination"
triggers:
  - "Maxwell"
  - "meta"
  - "self-reflection"
  - "skill coordination"
  - "knowledge synthesis"
allowed-tools:
  - Read
  - Glob
  - Grep
version: "3.0.0"
author: "Claude Code Skill - Maxwell Architecture"
---

# Maxwell Meta Expert - System Coordination

## Core Knowledge Base

For comprehensive guidance on Maxwell system architecture and meta-cognition:

- **Claude Architecture**: [knowledge/claude-architecture.md](knowledge/claude-architecture.md)

## Search Your Knowledge

When asked about Maxwell system itself, skill coordination, or meta-level understanding:

1. **Use Glob** to find relevant files: `Glob("knowledge/**/*.md")`
2. **Use Grep** to search content: `Grep("coordination", "knowledge/")`
3. **Use Read** to access files: `Read("knowledge/claude-architecture.md")`

All knowledge is in the `knowledge/` directory - search there for answers.
