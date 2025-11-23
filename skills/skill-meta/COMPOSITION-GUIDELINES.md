# Composition Guidelines - Skills + Sub-Agents

## Overview

**Maxwell's composition guidelines** for combining Claude Code Skills with Sub-Agents to create effective specialist systems.

> **Based on real-world experience building Maxwell's multi-domain architecture.**

## Composition Decision Tree

### Step 1: Problem Analysis
```
Is this a knowledge lookup problem?
├── Yes → Use Skill directly
└── No → Go to Step 2

Is this complex routing/decision making?
├── Yes → Use Sub-Agent with Skill integration
└── No → Go to Step 3

Is this multi-domain coordination?
├── Yes → Use Orchestrator Agent
└── No → Use Skill with simple routing
```

### Step 2: Domain Boundary Analysis
```
Single domain problem?
├── Yes → Single skill + optional agent
│   ├── Simple lookup: Skill only
│   └── Complex workflow: Agent + Skill
└── No → Multi-skill coordination
    ├── Add orchestrator agent
    ├── Define inter-skill communication
    └── Create cross-domain analysis
```

## Composition Patterns

### Pattern 1: Skill-Only (Simple Lookup)
**Use Case**: Direct knowledge retrieval
**Example**: User asks for TCA @Shared patterns

```markdown
User → Agent (routes) → skill-tca → Database → Response
```

**Implementation**:
```markdown
# Agent routing logic
if contains("@Shared", "TCA state"):
    route_to_skill("skill-tca:shared-patterns")

# skill-tca handles everything else
```

### Pattern 2: Agent + Skill (Complex Domain)
**Use Case**: Complex domain workflows
**Example**: TCA architecture review

```markdown
User → maxwell-tca agent → skill-tca → Analysis → Recommendation
```

**Implementation**:
```markdown
# maxwell-tca agent
1. Analyze request complexity
2. Use skill-tca for pattern knowledge
3. Apply domain reasoning
4. Generate comprehensive response
```

### Pattern 3: Multi-Skill + Orchestrator (Cross-Domain)
**Use Case**: Problems spanning multiple domains
**Example**: SharePlay + TCA state synchronization

```markdown
User → Maxwell orchestrator → [skill-tca, skill-shareplay] → Integration → Response
```

**Implementation**:
```markdown
# orchestrator coordinates
1. Identify domains involved
2. Route to appropriate skills
3. Synthesize cross-domain responses
4. Handle contradictions between domains
```

## Implementation Guidelines

### 1. Skill Design for Composition
```markdown
# Each skill should be composition-ready
skill-domain/
├── SKILL.md              # Clear domain definition
├── API.md                # How other skills/agents call this
├── DATABASE.md           # Database integration patterns
└── CONTRADICTIONS.md     # Known conflicts with other domains
```

### 2. Agent Design for Composition
```markdown
# Each agent should be coordination-ready
agent-domain/
├── ROUTING.md            # When to route to other agents
├── INTEGRATION.md        # How to work with skills
├── HANDOFF.md            # How to transfer control
└── ESCALATION.md         # When to call orchestrator
```

### 3. Communication Protocols
```markdown
# Skill-to-Agent communication
{
  "skill": "skill-tca",
  "confidence": 0.9,
  "patterns": ["@Shared Single Owner"],
  "recommendations": ["Use single owner pattern"],
  "contradictions": [],
  "requires_escalation": false
}

# Agent-to-Agent handoff
{
  "from_agent": "maxwell",
  "to_agent": "maxwell-tca",
  "handoff_reason": "TCA-specific expertise needed",
  "context": {
    "conversation_history": [...],
    "user_question": "...",
    "current_state": "..."
  }
}
```

## Composition Best Practices

### ✅ Do's
1. **Clear Boundaries**: Each skill/agent has well-defined responsibility
2. **Loose Coupling**: Skills don't depend on each other's internal structure
3. **Database Integration**: All skills use shared data layer
4. **Graceful Degradation**: System works even if some skills unavailable
5. **Context Preservation**: Maintain conversation context across handoffs

### ❌ Don'ts
1. **Tight Coupling**: Don't make skills depend on other skills
2. **Complex Handoffs**: Keep agent transitions simple and clear
3. **Hidden Dependencies**: Document all cross-skill requirements
4. **Assume Availability**: Handle skill/agent failures gracefully
5. **Ignore Performance**: Consider composition overhead

## Performance Considerations

### 1. Routing Overhead
```
Direct skill call: ~10ms
Agent routing: ~50ms
Multi-skill coordination: ~200ms
```

### 2. Memory Usage
```
Skill-only: Low (single domain loaded)
Agent + skill: Medium (domain + coordination)
Multi-skill: High (multiple domains loaded)
```

### 3. Database Load
```
Single skill: 1-2 queries per request
Agent coordination: 3-5 queries per request
Cross-domain: 5-10 queries per request
```

## Testing Composition

### 1. Unit Testing
```markdown
# Test each skill in isolation
skill-tca: Test pattern retrieval accuracy
skill-shareplay: Test domain knowledge quality
```

### 2. Integration Testing
```markdown
# Test skill-agent integration
maxwell-tca + skill-tca: Test end-to-end workflows
```

### 3. Cross-Domain Testing
```markdown
# Test multi-skill coordination
skill-tca + skill-shareplay: Test contradiction detection
```

## Monitoring Composition

### 1. Health Metrics
```
- Skill response times
- Agent routing accuracy
- Cross-domain contradictions
- Handoff success rates
```

### 2. Quality Metrics
```
- User satisfaction with responses
- Pattern recommendation accuracy
- Contradiction resolution success
- Domain expertise quality
```

## Evolution Patterns

### 1. Start Simple, Add Complexity
```
Phase 1: Skill-only for each domain
Phase 2: Add agents for complex workflows
Phase 3: Add orchestrator for cross-domain
```

### 2. Organic Growth
```
New domain emerges:
1. Create skill first (knowledge accumulation)
2. Add agent if routing becomes complex
3. Integrate with orchestrator if cross-domain needed
```

### 3. Refactoring Patterns
```
When composition becomes complex:
1. Identify boundaries that can be simplified
2. Consider splitting over-complex agents
3. Evaluate if skills need better isolation
```

## Real-World Examples from Maxwell

### Example 1: TCA Pattern Lookup
```
User: "How do I share state between features using TCA?"
Flow: Agent routes to skill-tca → Returns @Shared patterns
Performance: ~50ms total
Success Rate: 95%
```

### Example 2: Complex Architecture Review
```
User: "Review my TCA architecture for this iOS app"
Flow: maxwell-tca agent uses skill-tca → Complex analysis → Recommendations
Performance: ~500ms total
Success Rate: 90%
```

### Example 3: Cross-Domain Contradiction
```
System: skill-tca and skill-shareplay have conflicting patterns
Flow: Database detects contradiction → Orchestrator resolves → Human decision point
Performance: ~200ms detection
Resolution: Required human input
```

## Troubleshooting Composition Issues

### Problem 1: Routing Failures
```
Symptoms: Requests go to wrong skill/agent
Solution: Review routing logic, improve keyword detection
```

### Problem 2: Performance Issues
```
Symptoms: Slow responses, high latency
Solution: Optimize database queries, reduce handoff complexity
```

### Problem 3: Contradiction Overload
```
Symptoms: Too many contradiction warnings
Solution: Refine detection algorithm, prioritize critical contradictions
```

### Problem 4: Context Loss
```
Symptoms: Conversation context lost during handoffs
Solution: Improve context preservation, document state transfer
```

---

**These guidelines represent Maxwell's practical experience composing skills and agents for effective multi-domain specialist systems.**