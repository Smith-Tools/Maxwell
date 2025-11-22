# Maxwell Knowledge Layer - Maintenance & Extension Guide

This guide explains how to add, update, and maintain patterns, integrations, and discoveries in the unified Maxwell knowledge layer.

---

## Quick Reference: What Goes Where?

| Content | Table | When to Add | Example |
|---------|-------|------------|---------|
| Single-domain pattern | `patterns` | New best practice discovered | "TCA @Shared single-owner pattern" |
| Cross-domain solution | `integrations` | Connecting 2+ frameworks | "TCA-SharePlay state sync" |
| Common mistake | `anti_patterns` | Bug with clear root cause | "@Shared race condition - multiple writers" |
| Real bug found | `discoveries` | Production issue solved | "RealityKit entity sync drops on network switch" |

---

## Adding a Pattern

A **pattern** solves a single-domain problem. Add to the `patterns` table.

### Example: "TCA @Shared Single-Owner Pattern"

**When to add:**
- You've seen this pattern used correctly multiple times
- There's a clear problem it solves
- It has validation criteria

**What to include:**

```sql
INSERT INTO patterns (
    domain,
    pattern_name,
    problem,
    solution,
    code_example,
    references,
    validation_checklist
) VALUES (
    'TCA',
    'Single Owner Pattern for @Shared',
    'Multiple features mutating @Shared causes race conditions and inconsistent state',
    'One feature owns and mutates @Shared state; others observe via @SharedReader',
    '-- Feature A: Owner
@ObservableState
class AuthFeature {
    @Shared var authState: AuthState

    func logout() {
        authState = .loggedOut  // Owner can mutate
    }
}

-- Feature B: Observer
@ObservableState
class SettingsFeature {
    @SharedReader var authState: AuthState
    // Can only read, not mutate
}',
    'TCA 1.23.0+ documentation, real production apps, GitHub issue #1234',
    'Feature owns @Shared var | Only owner can mutate | Other features use @SharedReader | No simultaneous writes | Testing: use fixture for ownership'
);
```

**Validation Checklist (included):**
- [ ] Feature owns `@Shared` var
- [ ] Only owner can mutate the var
- [ ] Other features use `@SharedReader`
- [ ] No simultaneous writes to @Shared
- [ ] Testing verifies ownership isolation

---

## Adding an Integration Pattern

An **integration** connects two or more domains. Add to the `integrations` table.

### Example: "TCA-SharePlay State Bridge"

**When to add:**
- You've solved the problem of connecting two frameworks
- There are trade-offs worth documenting
- It has working code

**What to include:**

```sql
INSERT INTO integrations (
    domain_a,
    domain_b,
    integration_pattern,
    problem,
    solution,
    code_example,
    tradeoffs
) VALUES (
    'TCA',
    'SharePlay',
    'TCA-SharePlay State Bridge',
    'How to keep TCA @Shared state in sync with SharePlay participants? @Shared is local-first; GroupSessionMessenger is network-first. They have different concurrency models and update frequencies.',
    '1. Use @Shared for local state only
2. Use GroupSessionMessenger for network sync
3. When local @Shared changes, send via messenger
4. When messenger receives update, update @Shared
5. Use messageIndex to prevent race conditions',
    '// TCA Reducer with SharePlay integration
@Reducer
struct GameFeature {
    @ObservableState
    struct State {
        @Shared var gameState: GameState  // Local TCA state
        var messenger: GroupSessionMessenger?
    }

    enum Action {
        case localGameMove(Move)          // User action
        case remoteGameMove(Move)         // From SharePlay
        case configureMessenger(GroupSessionMessenger)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .localGameMove(let move):
                // Update local state first
                state.gameState.applyMove(move)

                // Then broadcast via messenger
                return .run { @MainActor in
                    try? await state.messenger?.send(move)
                }

            case .remoteGameMove(let move):
                // Receive from SharePlay, update local state
                state.gameState.applyMove(move)
                return .none

            case .configureMessenger(let messenger):
                state.messenger = messenger
                // Start listening for updates
                return .run { send in
                    for await move in messenger.messages(of: Move.self) {
                        await send(.remoteGameMove(move))
                    }
                }
            }
        }
    }
}',
    'Trade-off 1: Update order - Local state first (immediate UI) vs messenger send (eventual consistency). Solution: Update local immediately, accept brief desync.
Trade-off 2: Message ordering - GroupSessionMessenger has no ordering guarantees. Solution: Use messageIndex in GameState to detect and ignore out-of-order updates.
Trade-off 3: Offline handling - @Shared works offline; messenger doesn't. Solution: Queue local changes, replay when reconnected.'
);
```

**Key sections:**
1. **Problem**: Why is this hard? What are the constraints?
2. **Solution**: The approach at a high level (numbered steps)
3. **Code Example**: Real, working code showing the pattern
4. **Trade-offs**: Be honest about what this approach sacrifices

---

## Adding an Anti-Pattern

An **anti-pattern** documents a common mistake with root cause. Add to the `anti_patterns` table.

### Example: "@Shared with Multiple Writers"

**When to add:**
- You've seen this bug in real code (yours or others')
- You understand exactly WHY it's wrong
- You have a fix

**What to include:**

```sql
INSERT INTO anti_patterns (
    domain,
    symptom,
    root_cause,
    fix,
    discovery_source,
    example_code
) VALUES (
    'TCA',
    'State inconsistency: @Shared value differs between devices in SharePlay session',
    'Multiple TCA features mutating the same @Shared var simultaneously. When Feature A and Feature B both call `state.value = x` in rapid succession, one write can be lost because they dont coordinate. Race condition between reducer actions.',
    '1. Identify the @Shared var being mutated
2. Trace all features that call .send(action) that mutates it
3. Choose ONE feature as owner
4. Change other features to use @SharedReader (read-only)
5. If other features need to change state, they send a delegate action to owner
6. Owner handles all mutations in its reducer',
    'Real bug found in production SharePlay chess game (PersonaChess analysis)',
    '// ❌ WRONG - Race condition
Feature A:
  @Shared var gameState: GameState
  func moveA() { gameState.lastMove = moveA }  // Write 1

Feature B:
  @Shared var gameState: GameState
  func moveB() { gameState.lastMove = moveB }  // Write 2

// Both writes happen nearly simultaneously
// Whichever write wins, one move is lost

// ✅ CORRECT - Single owner
Feature A (owner):
  @Shared var gameState: GameState
  func applyMove(_ move: Move) {
    gameState.lastMove = move  // Only owner writes
  }

Feature B (observer):
  @SharedReader var gameState: GameState
  func moveB() {
    // Cannot write directly
    // Instead, delegate to Feature A
    send(.delegate(.playerBMoved(moveB)))
  }'
);
```

---

## Adding a Discovery

A **discovery** documents a real bug from production with its root cause and solution. Add to the `discoveries` table.

### Example: "RealityKit Entities Sync Loss During Network Transition"

**When to add:**
- You've encountered and fixed a real bug
- The root cause is non-obvious
- It took investigation to understand
- Other developers will face the same issue

**What to include:**

```sql
INSERT INTO discoveries (
    title,
    domains,
    symptom,
    investigation,
    solution,
    code_fix,
    validation_status,
    discovered_date
) VALUES (
    'RealityKit Entities Lose Sync During Network Transition in SharePlay Session',
    '["RealityKit", "SharePlay"]',
    'During a SharePlay session, when the local device switches networks (WiFi → cellular), RealityKit entities become invisible/unresponsive for 5-10 seconds. Spatial content briefly disappears.',
    'Investigation steps:
1. Enabled detailed logging in GroupSessionMessenger
2. Found: Entity updates stop being sent for ~8 seconds during network switch
3. Root cause: GroupSessionMessenger internally reconnects on network change
4. During reconnection window: Messages are queued but entities arent rendered
5. Real issue: RealityView subscription to entity updates gets cancelled
6. The messenger reconnects, but RealityView doesnt know to re-subscribe',
    'When network reconnection is detected, force-resubscribe the RealityView to entity update streams. Add explicit connectivity monitoring.',
    '// Add network monitoring
@MainActor
class NetworkMonitor: NSObject, ObservableObject {
    @Published var isConnected = true

    override init() {
        super.init()
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
}

// In RealityView subscription
.onChange(of: networkMonitor.isConnected) { _, _ in
    // Force RealityView to re-subscribe on network change
    updateTask?.cancel()
    updateTask = Task {
        // Re-subscribe to entity updates
        for await entities in groupSession.entityUpdates() {
            await updateRealityView(with: entities)
        }
    }
}',
    'Validated in production - fixes observed visibility drops',
    '2025-11-15'
);
```

---

## Updating Existing Records

### When a Pattern Becomes Outdated

**Scenario**: TCA 1.25 releases and changes `@Shared` API

```sql
UPDATE patterns
SET problem = '(updated) ...',
    solution = '(updated) ...',
    code_example = '(updated) ...',
    references = references || ', TCA 1.25.0 release notes'
WHERE pattern_name = 'Single Owner Pattern for @Shared'
  AND domain = 'TCA';
```

### When a Better Integration Path is Found

```sql
UPDATE integrations
SET tradeoffs = '(original tradeoffs) ... (2025-11-22) UPDATED: Found better approach using AsyncThrowingSequence'
WHERE integration_pattern = 'TCA-SharePlay State Bridge';
```

---

## Searching the Knowledge Layer

### Finding a Pattern

**Query**: "I need TCA patterns for shared state"

```sql
SELECT pattern_name, problem, validation_checklist
FROM patterns
WHERE domain = 'TCA'
  AND problem LIKE '%shared%'
ORDER BY pattern_name;
```

**With FTS5**:

```sql
SELECT pattern_name, relevance
FROM maxwell_search
WHERE maxwell_search MATCH 'TCA shared state'
ORDER BY relevance;
```

### Finding an Integration

**Query**: "How do I connect TCA with SharePlay?"

```sql
SELECT integration_pattern, solution, code_example
FROM integrations
WHERE (domain_a = 'TCA' AND domain_b = 'SharePlay')
   OR (domain_a = 'SharePlay' AND domain_b = 'TCA')
LIMIT 1;
```

### Finding Bugs for a Domain Pair

**Query**: "What bugs have been found in RealityKit + SharePlay?"

```sql
SELECT title, symptom, solution
FROM discoveries
WHERE domains LIKE '%RealityKit%'
  AND domains LIKE '%SharePlay%'
ORDER BY discovered_date DESC;
```

---

## Review Checklist: Before Adding Content

### For Patterns
- [ ] Solves a real, single-domain problem
- [ ] Has working code example
- [ ] Includes validation checklist
- [ ] References official documentation or source
- [ ] Tested in real code (not theoretical)

### For Integrations
- [ ] Connects two or more frameworks
- [ ] Problem section explains constraints of each framework
- [ ] Solution section has numbered steps
- [ ] Code example is complete and working
- [ ] Trade-offs section is honest about what's sacrificed
- [ ] Tested with real multi-framework code

### For Anti-Patterns
- [ ] Root cause is clearly explained (not just "don't do this")
- [ ] Fix is concrete and actionable
- [ ] Example code shows both wrong and correct
- [ ] Discovery source is documented
- [ ] Applicable across multiple projects

### For Discoveries
- [ ] Real bug from production (not hypothetical)
- [ ] Investigation details show how it was discovered
- [ ] Root cause explains WHY it happened
- [ ] Solution is verified to work
- [ ] Validation status is documented

---

## Maintenance Cadence

### Weekly
- Review new issues/bugs reported
- Add any obvious anti-patterns
- Update code examples if APIs change

### Monthly
- Audit patterns for outdated references
- Test code examples compile/run
- Merge duplicate integrations
- Review discoveries for patterns

### Quarterly
- Review domain coverage (are we missing domains?)
- Update references to latest framework versions
- Consolidate lessons learned
- Plan new pattern documentation

---

## Common Maintenance Tasks

### "I found a new TCA+SharePlay integration pattern"

1. Add to `integrations` table with domain_a='TCA', domain_b='SharePlay'
2. Include complete code example
3. Document trade-offs explicitly
4. Test with real code
5. Add reference to any related anti-patterns

### "An API changed and some code examples broke"

1. Find affected patterns/integrations/discoveries
2. Update code examples
3. Add note: "(Updated for Framework X.Y.Z)"
4. Test examples compile
5. Keep old version in references if relevant

### "Two patterns are basically the same"

1. Keep the more specific/detailed version
2. In the other, add: "See also: [other-pattern-name]"
3. Merge their code examples into the best version
4. Ensure validation checklists are complete

### "A discovery reveals a systematic problem"

1. Document in `discoveries` table
2. Check if it should also be in `anti_patterns` (yes, usually)
3. Add both versions (discovery = specific real case; anti-pattern = general warning)
4. Create remediation pattern if solution is reusable

---

**This knowledge layer only works if it's actively maintained. Use it, improve it, share discoveries. That's how it becomes valuable.**

