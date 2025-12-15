---
name: maxwell
description: WWDC & Apple docs semantic search. Run `rag search` via Bash.
allowed-tools: Bash, Read
---

# Maxwell - Apple Developer Knowledge

## ⚠️ MANDATORY: Run RAG Search First

**Run this Bash command BEFORE anything else:**

```bash
rag search "<user's question>" --database ~/.smith/rag/sosumi.db --limit 10
```

This is a semantic search over 12,500+ WWDC transcript chunks (2014-2025). It understands meaning, not just keywords.

**Example - animations:**
```bash
rag search "Reality Composer Pro animation timeline" --database ~/.smith/rag/sosumi.db --limit 10
```

**Example - SwiftUI:**
```bash
rag search "Observable macro SwiftUI" --database ~/.smith/rag/sosumi.db --limit 10
```

**Example - RealityKit:**
```bash
rag search "RealityKit AnimationResource playback" --database ~/.smith/rag/sosumi.db --limit 10
```

## Topics Covered

- 🍎 Apple Frameworks (SwiftUI, RealityKit, visionOS, ARKit)
- 🎓 WWDC sessions (2014-2025)
- 🧩 Architectural patterns
- 📱 Platform-specific APIs

## Technical Details

- **Engine**: SmithRAG with MLX embeddings
- **Model**: Qwen3-Embedding-0.6B-4bit (1024d vectors)
- **Database**: ~/.smith/rag/sosumi.db (12,500+ chunks)
- **Runs**: Entirely offline on Apple Silicon GPU
