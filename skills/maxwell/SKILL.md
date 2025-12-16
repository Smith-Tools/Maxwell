---
name: maxwell
description: WWDC & Apple docs semantic search. Run `maxwell search` or `rag search` via Bash.
allowed-tools: Bash, Read
---

# Maxwell - Apple Developer Knowledge Search

Maxwell provides semantic search over 12,500+ WWDC transcript chunks (2014-2025), understanding meaning not just keywords.

## Quick Start

You have two options to search:

### Option 1: Maxwell CLI (Recommended)
```bash
maxwell search "RealityKit animation playback"
maxwell search "SwiftUI Observable macro" --limit 10
maxwell search "visionOS immersive spaces"
```

### Option 2: Direct RAG Search
```bash
rag search "your question" --database ~/.smith/rag/sosumi.db --limit 10
```

Both commands search the same WWDC transcript database and return identical results.

## Usage Examples

### Animations & Composition
```bash
maxwell search "Reality Composer Pro animation timeline"
maxwell search "AnimationPlaybackController blend shape"
maxwell search "animation state synchronization" --limit 5
```

### SwiftUI State Management
```bash
maxwell search "Observable macro SwiftUI"
maxwell search "SwiftUI state management patterns"
maxwell search "Bindable Observable"
```

### RealityKit
```bash
maxwell search "RealityKit AnimationResource playback"
maxwell search "RealityKit entity synchronization"
maxwell search "Model3D animation controller"
```

### visionOS
```bash
maxwell search "visionOS immersive space integration"
maxwell search "spatial computing state management"
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
