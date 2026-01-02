# Maxwell Skill - Knowledge Orchestrator

Maxwell routes developer questions to the right knowledge sources and uses the `maxwell` CLI as the single search entry point. Do not call `smith-rag` directly from the skill surface.

## Knowledge Sources

- **sosumi**: WWDC transcripts and Apple guidance (semantic search with exact-term fallback)
- **deadbeef**: Point-Free episodes (TCA and functional programming, semantic search)
- **scully**: Team discoveries in `scully/discoveries/`

## How Agents Use Maxwell

1. **Run a search**
   ```bash
   maxwell search "<query>" --limit 5
   ```
   - Use `--sosumi-only` for Apple/WWDC questions
   - Use `--deadbeef-only` for Point-Free/TCA questions
   - Use `--exact` for symbols/API names/errors, `--semantic` for broad concepts

2. **Read relevant sections**
   - Focus on the sosumi or deadbeef section in the output, based on the query

3. **Check scully when needed**
   ```bash
   grep -r "<pattern>" scully/discoveries --include="*.md" -i
   ```

4. **Use DocC when you need API detail**
   ```bash
   maxwell docc-search "glassEffect" --limit 5
   maxwell docc-search "View" --symbol
   maxwell docc-fetch "https://developer.apple.com/documentation/swiftui/view" --format text
   ```
   - `docc-search` is Apple-only (sosumi)
   - `docc-fetch` is generic DocC (smith-doc-inspector, `--format text|json`)
   - Use `smith-doc-inspector examples <repo|url>` for repo example discovery

## Quick Examples

```bash
maxwell search "RealityKit animation playback" --sosumi-only --limit 5
maxwell search "@Shared" --deadbeef-only --limit 5
maxwell search "AnimationPlaybackController" --exact --sosumi-only --limit 5
maxwell docc-search "glassEffect" --limit 5
maxwell docc-search "View" --symbol
maxwell docc-fetch "swiftui/view"
```

## Local Paths

- RAG databases: `~/.smith/rag/sosumi.db`, `~/.smith/rag/deadbeef.db`
- Discoveries: `scully/discoveries/`
