# Sub-Agent Patterns - Maxwell's Architecture

## What Are Sub-Agents?

**Sub-Agents** are autonomous Claude agents that can be invoked to handle complex tasks or specialized domains.

> **Based on:** [https://code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents)

## Maxwell's Sub-Agent Architecture

### Current Sub-Agents
```
agent/                    # Main Maxwell orchestrator
├── maxwell-tca          # TCA specialist agent
├── maxwell-shareplay    # SharePlay specialist agent
└── maxwell-architectural # Architecture specialist agent
```

### Sub-Agent Interaction Model
```
User Request → Maxwell Orchestrator → Specialist Sub-Agent → Domain Skill → Response
```

## Sub-Agent vs Skills Decision Matrix

### Use Sub-Agents When:
- ✅ **Complex routing**: Multi-step decision trees
- ✅ **Autonomous behavior**: Independent problem solving
- ✅ **State management**: Maintaining conversation context
- ✅ **Complex workflows**: Multiple domain expertise needed

### Use Skills When:
- ✅ **Domain expertise**: TCA, SharePlay patterns
- ✅ **Reusable logic**: Pattern detection, database operations
- ✅ **Simple lookup**: Knowledge retrieval
- ✅ **Clear boundaries**: Well-defined problem spaces

## Sub-Agent Design Patterns

### Pattern 1: Specialist Agent
**Purpose**: Deep domain expertise with complex routing

**Example**: `maxwell-tca`
- **Scope**: The Composable Architecture expertise
- **Routing Logic**: Complex TCA decision trees
- **State Management**: Track TCA context across conversations
- **Skill Integration**: Uses `skill-tca` for knowledge base

**Agent Structure**:
```
agent/maxwell-tca/
├── ROUTING.md            # Decision tree logic
├── DOMAIN-BOUNDARY.md    # What this agent handles
├── SKILL-INTEGRATION.md  # How to use skill-tca
└── ESCALATION.md         # When to call other agents
```

### Pattern 2: Orchestrator Agent
**Purpose**: Coordinate multiple specialists

**Example**: Main Maxwell Agent
- **Scope**: Route to appropriate specialist
- **Routing Logic**: User request analysis
- **State Management**: Track conversation domain
- **Escalation**: Hand off to specialists when needed

**Routing Logic**:
```
User Request Analysis:
├── Contains "@Shared"? → maxwell-tca
├── Contains "SharePlay"? → maxwell-shareplay
├── Architecture question? → maxwell-architectural
└── General query? → Handle directly
```

### Pattern 3: Coordination Agent
**Purpose**: Handle cross-domain interactions

**Example**: `maxwell-architectural`
- **Scope**: Cross-domain pattern analysis
- **Routing Logic**: Multi-domain problem solving
- **Coordination**: Resolve conflicts between specialists
- **Integration**: Access all skills for contradiction detection

## Sub-Agent Communication Patterns

### 1. Agent-to-Agent Handoff
```markdown
# Maxwell detects TCA question
Maxwell: "This requires TCA expertise. Invoking maxwell-tca..."
maxwell-tca: [Takes over conversation]
```

### 2. Agent-to-Skill Integration
```markdown
# maxwell-tca needs pattern information
maxwell-tca: "Use skill-tca:@Shared-state patterns"
skill-tca: [Returns pattern data]
maxwell-tca: [Processes pattern data → response]
```

### 3. Cross-Agent Coordination
```markdown
# Contradiction detected across domains
maxwell-architectural: "Pattern contradiction detected between TCA and SharePlay"
maxwell-tca: [Provides TCA perspective]
maxwell-shareplay: [Provides SharePlay perspective]
maxwell-architectural: [Coordinates resolution]
```

## Sub-Agent State Management

### 1. Conversation Context
```markdown
# Track what specialist is active
{
  "active_agent": "maxwell-tca",
  "conversation_domain": "TCA",
  "context": "@Shared state management",
  "previous_interactions": [...]
}
```

### 2. Domain State
```markdown
# Maintain domain-specific context
maxwell-tca: {
  "current_pattern": "@Shared Single Owner",
  "user_expertise": "intermediate",
  "project_context": "iOS app with authentication"
}
```

### 3. Handoff State
```markdown
# Preserve context during agent handoff
{
  "from_agent": "maxwell",
  "to_agent": "maxwell-tca",
  "handoff_reason": "TCA-specific question detected",
  "preserved_context": {...}
}
```

## Sub-Agent Routing Logic

### 1. Keyword-Based Routing
```markdown
# Simple keyword detection
if contains("@Shared", "Reducer", "TCA"):
    route_to("maxwell-tca")
elif contains("SharePlay", "GroupSession"):
    route_to("maxwell-shareplay")
elif contains("architecture", "pattern", "design"):
    route_to("maxwell-architectural")
```

### 2. Context-Based Routing
```markdown
# Understand conversation context
if previous_messages_domain == "TCA":
    stay_with("maxwell-tca")
elif new_domain_detected:
    consider_handoff()
```

### 3. Complexity-Based Routing
```markdown
# Route based on question complexity
if simple_lookup():
    use_skill_directly()
elif complex_workflow():
    route_to_specialist()
elif cross_domain():
    route_to_coordinator()
```

## Sub-Agent Lifecycle

### 1. Initialization
```
Sub-agent starts → Load domain knowledge → Initialize routing logic → Ready for requests
```

### 2. Request Processing
```
Receive request → Analyze domain → Route internally → Use skills → Generate response
```

### 3. Handoff
```
Detect domain change → Preserve context → Transfer to appropriate agent → New agent takes over
```

### 4. Termination
```
Conversation ends → Save learned patterns → Update knowledge base → Cleanup state
```

## Sub-Agent Best Practices

### 1. Clear Boundaries
```markdown
✅ Each agent has well-defined domain
✅ Minimal overlap between agents
✅ Clear escalation paths
✅ Documented handoff criteria
```

### 2. Efficient Handoffs
```markdown
✅ Preserve conversation context
✅ Explain handoff to user
✅ Transfer relevant state
✅ Maintain conversation flow
```

### 3. Skill Integration
```markdown
✅ Agents use skills for knowledge
✅ Skills remain domain-focused
✅ Clear agent-skill interfaces
✅ Efficient skill communication
```

## Common Sub-Agent Pitfalls

### ❌ Agent Overlap
```
Bad: Two agents handle same domain
Good: Clear domain separation
```

### ❌ Complex Handoffs
```
Bad: Confusing agent transitions
Good: Clear handoff with context preservation
```

### ❌ Poor State Management
```
Bad: Lost context during handoff
Good: Seamless conversation flow
```

## Future Sub-Agent Directions

### 1. Adaptive Routing
- Learn from conversation patterns
- Improve domain detection
- Optimize handoff timing

### 2. Collaborative Problem Solving
- Multiple agents work together
- Shared problem spaces
- Collaborative decision making

### 3. Self-Improving Agents
- Learn from interactions
- Improve routing accuracy
- Optimize domain knowledge

---

**This documents Maxwell's real-world experience with Claude Code sub-agents and specialist coordination.**