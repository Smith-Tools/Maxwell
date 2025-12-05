# Claude Architecture Knowledge Base

## Claude Sub-Agents System

### Core Architecture
Sub-agents are specialized AI assistants with the following characteristics:

#### **Isolated Context Windows**
- Each sub-agent has its own dedicated context window
- Context is completely isolated from the main conversation
- Prevents context bleeding between different agent types
- Allows specialized focus without interference

#### **Custom System Prompts**
- Each agent has a custom system prompt defining its expertise
- System prompts dictate behavior, capabilities, and constraints
- Fine-tuned for specific domains and tasks
- Can include examples, patterns, and specialized knowledge

#### **Granular Tool Access Permissions**
- Tool access is carefully controlled per agent
- Prevents unauthorized access to sensitive capabilities
- Ensures agents only use tools relevant to their domain
- Security and safety through controlled permissions

#### **Separate Context Management**
- Independent context management per agent
- State isolation prevents cross-contamination
- Each agent maintains its own conversation history
- Enables parallel processing without interference

### Agent Storage Hierarchy

#### **Project-Level Agents (Highest Priority)**
- Location: `.claude/agents/`
- Priority: Highest in the hierarchy
- Scope: Project-specific agents
- Override: Takes precedence over user-level agents
- Version Control: Should be checked into project git

#### **User-Level Agents (Lower Priority)**
- Location: `~/.claude/agents/`
- Priority: Lower than project agents
- Scope: User-wide agents
- Fallback: Used when project agents aren't available
- Personal: User's personal agent collection

#### **Plugin Agents**
- Source: Bundled with installed plugins
- Integration: Seamlessly integrated into the system
- Discovery: Automatically detected and available
- Maintenance: Managed by plugin updates
- Distribution: Through plugin ecosystem

#### **CLI-Defined Agents (Temporary)**
- Method: Defined via `--agents` flag
- Scope: Temporary session-based agents
- Lifetime: Exists only for the current session
- Use Case: One-off specialized agents
- Persistence: Not saved between sessions

#### **Built-In Agents**
- Example: "Plan" subagent for plan mode research
- System: Core Claude functionality
- Integration: Deeply integrated with Claude
- Maintenance: Managed by Claude team
- Reliability: High availability and stability

### Agent Configuration Format

#### **Standard Configuration Structure**
```yaml
---
name: unique-agent-name
description: Clear description of agent specialization and capabilities
tools: read,grep,grep,write,bash  # Comma-separated list
model: inherit|sonnet|opus|haiku  # Model selection
permissionMode: default|acceptEdits|bypassPermissions
skills: skill1,skill2,skill3  # Comma-separated skills
---
```

#### **System Prompt Requirements**
- Clear definition of agent behavior and expertise
- Specific constraints and examples
- Domain knowledge and capabilities
- Interaction patterns and workflows
- Error handling and edge cases

### Agent Invocation Patterns

#### **Automatic Delegation**
- Triggered by task description matching
- Claude autonomously decides delegation
- Pattern matching against agent descriptions
- Context-aware selection process
- Efficiency: Reduces manual routing

#### **Explicit Invocation**
- Syntax: `> Use [agent-name]`
- Manual override of automatic selection
- Specific agent choice by user
- Forced delegation when needed
- Control: User maintains choice

#### **Resumable Conversations**
- Agent conversations can be resumed
- Maintains state and context across invocations
- Agent IDs used for session persistence
- Enables long-running workflows
- Continuity: Preserves conversation history

#### **Chained Workflows**
- Agents can pass work to other agents
- Sequential processing through multiple specialists
- Handoff patterns with context preservation
- Complex multi-step workflows
- Orchestration: Multi-agent coordination

#### **Model Selection**
- `inherit`: Use same model as main conversation
- `sonnet`: Force Claude Sonnet model
- `opus`: Force Claude Opus model
- `haiku`: Force Claude Haiku model
- Optimization: Balance cost vs. capability

### Best Practices for Agent Development

#### **Single Responsibility Principle**
- One clear specialization per agent
- Focused domain expertise
- Avoid overlapping responsibilities
- Clear boundary definition
- Maintainability: Easier to update and debug

#### **Generation and Customization**
- Generate initial agents with Claude
- Customize for specific use cases
- Iterative refinement process
- Testing and validation
- Evolution: Continuous improvement

#### **Tool Access Control**
- Limit tools to essential capabilities
- Security through minimal permissions
- Prevent unauthorized operations
- Audit trail for tool usage
- Safety: Risk mitigation

#### **Constraint Specification**
- Clear limits and boundaries
- Specific examples and patterns
- Error handling procedures
- Edge case coverage
- Reliability: Predictable behavior

### Limitations and Constraints

#### **No Nesting**
- Sub-agents cannot spawn other sub-agents
- Single level of hierarchy
- Prevents infinite recursion
- Simpler architecture
- Performance: Avoids complexity overhead

#### **Context Gathering Latency**
- Potential delay in context collection
- Network and filesystem overhead
- Impact on response time
- Mitigation through caching
- Optimization: Performance tuning

#### **Context vs. Overhead Tradeoff**
- Balance between context richness and performance
- Larger contexts increase capability but add latency
- Optimize for specific use cases
- Monitor performance metrics
- Efficiency: Resource management

## Claude Skills System

### Core Concepts

#### **Model-Invoked Capabilities**
- Skills extend Claude's functionality
- Automatically invoked based on request matching
- Directory-based architecture with `SKILL.md`
- Declarative capability definition
- Integration: Seamless with core Claude functionality

#### **Skill Storage Locations**

**Personal Skills:**
- Location: `~/.claude/skills/`
- Scope: User-wide skill availability
- Priority: Higher than plugin skills
- Management: User-controlled
- Persistence: Survives reinstallations

**Project Skills:**
- Location: `.claude/skills/`
- Scope: Project-specific capabilities
- Priority: Highest in hierarchy
- Version Control: Should be committed
- Collaboration: Team-shared skills

**Plugin Skills:**
- Source: Bundled with plugins
- Distribution: Through plugin ecosystem
- Maintenance: Plugin updates
- Discovery: Automatic detection
- Integration: Seamless with system

### Skill Structure and Configuration

#### **Standard Skill Format**
```yaml
---
name: lowercase-hyphens-max64-chars
description: Brief description with usage triggers (max 1024 chars)
allowed-tools: Read,Grep,Glob,Write,Bash  # Optional tool restrictions
version: "1.0.0"  # Version tracking
author: "Author Name"  # Attribution
tags:
  - "domain1"
  - "domain2"
triggers:
  - "keyword1"
  - "keyword2"
---
```

#### **Skill Description Best Practices**
- Clear, specific capability description
- Include trigger terms for auto-discovery
- Maximum 1024 characters for efficiency
- Use domain-specific terminology
- Examples: Specific usage scenarios

#### **Tool Access Control**
- `allowed-tools` restricts capabilities when active
- Security through controlled permissions
- Performance by loading only necessary tools
- Safety: Prevents unauthorized operations
- Auditability: Clear tool usage tracking

### Skill Discovery and Activation

#### **Autonomous Decision Process**
- Claude analyzes request against skill descriptions
- Pattern matching for keyword detection
- Semantic similarity assessment
- Context-aware activation
- Efficiency: Minimal overhead

#### **Trigger Mechanisms**
- Keyword matching in skill descriptions
- Semantic analysis of user requests
- Context-based activation
- Multi-skill coordination when needed
- Intelligence: Smart selection algorithm

### Skill Development Best Practices

#### **Focused Capability Design**
- One clear capability per skill
- Avoid feature bloat and complexity
- Clear boundaries and responsibilities
- Testing and validation requirements
- Maintainability: Simplified updates

#### **Specific Descriptions**
- Include trigger terms for auto-discovery
- Use domain-specific terminology
- Provide clear usage examples
- Define scope and limitations
- Clarity: Reduce ambiguity

#### **Team Testing**
- Test with actual team members
- Real-world usage scenarios
- Performance validation
- User experience optimization
- Collaboration: Team feedback integration

#### **Version Management**
- Document skill versions
- Track changes and improvements
- Backward compatibility considerations
- Update deployment strategies
- Evolution: Continuous improvement

### Debugging and Troubleshooting

#### **Common Issues**
- YAML syntax validation failures
- File path resolution problems
- Description specificity issues
- Tool permission conflicts
- Debugging: Systematic approach

#### **Debugging Tools**
- `claude --debug` for error visibility
- YAML validation tools
- Path resolution testing
- Tool access verification
- Diagnostics: Comprehensive error reporting

### Skill Distribution and Sharing

#### **Plugin Distribution**
- Bundle skills with plugins
- Automatic installation and updates
- Dependency management
- Version compatibility
- Ecosystem: Plugin marketplace

#### **Git Repository Distribution**
- Commit skills to project repositories
- Team collaboration and sharing
- Version control integration
- Branch and merge workflows
- Collaboration: Team-based development

## Maxwell Meta-Applications

### Multi-Skill Orchestration Patterns

#### **Claude Architecture Leveraging**
- Maxwell skills follow Claude's skill patterns
- Maxwell agent follows Claude's sub-agent patterns
- Leverages established best practices
- Integration: Compatible with existing ecosystem
- Standards: Follows Claude's conventions

#### **Skill Coordination Strategies**
- Use Claude's autonomous discovery for individual skills
- Use Maxwell agent for multi-skill orchestration
- Leverage resumable conversations for complex workflows
- Apply tool access control patterns for security
- Architecture: Consistent with Claude design

#### **Performance Optimization**
- Context isolation between skills
- Tool access control for efficiency
- Priority-based skill activation (project > user > plugin)
- Caching strategies for repeated access
- Optimization: Claude-provided patterns

#### **Scalability Considerations**
- Single-level skill hierarchy (no nesting)
- Modular skill design for maintainability
- Plugin-like architecture for extensibility
- Version management for updates
- Growth: Designed for expansion

## Maxwell Discoveries: Practical Lessons from Multi-Skill Implementation

### The Tool Access Control Discovery

#### **The Problem**
When building Maxwell v3.0 (a multi-skill system with embedded knowledge), individual skills were configured with both local file tools (Read, Glob, Grep) AND web tools (WebSearch, WebFetch).

**Observed Behavior**: Skills would prefer to use WebFetch/WebSearch rather than read embedded knowledge files, even when the knowledge was available locally. This defeated the purpose of having embedded knowledge.

#### **Root Cause Analysis**
Claude agents/skills optimize for:
1. **Minimal effort**: Generating answers from training data is easier than reading files
2. **Freshness**: Web searches provide current information vs. embedded knowledge that might be outdated
3. **Speed**: Web API calls can be faster than file I/O in some cases

**Key Insight**: When given a choice between multiple tools, Claude will naturally prefer web search over local file operations, regardless of instructions in the SKILL.md file.

#### **The Solution: Tool Restriction Pattern**
**Critical Discovery**: The way to force skills to use embedded knowledge is to **restrict `allowed-tools` to ONLY local file tools**.

```yaml
allowed-tools:
  - Read
  - Glob
  - Grep
```

**Why This Works**:
- Skills cannot use tools that aren't listed in `allowed-tools`
- Without WebFetch/WebSearch available, the skill MUST read local files
- Forces actual utilization of embedded knowledge
- Verifiable through "tool uses" count (should be > 0)

### The Agent Preloading Discovery

#### **How Agent-Skill Coordination Actually Works**
After extensive testing, we discovered the actual mechanism:

**NOT This** (what we initially expected):
```yaml
# Agents do NOT dynamically call/invoke skills
Agent:
  - Invoke skill-pointfree
  - Invoke skill-shareplay
  - Synthesize responses
```

**Actually This** (what Claude implements):
```yaml
# Agents have skills PRELOADED in their context
Agent:
  skills: skill1,skill2,skill3
  # All skill knowledge is loaded into agent context at startup
  # Agent references preloaded knowledge directly
  # No runtime invocation needed
```

#### **Zero Tool Uses Is Expected for Agents**
When testing the Maxwell agent with `skills:` field:
- Agent shows `0 tool uses` despite coordinating multiple skills
- This is **correct behavior**, not a failure
- Skills are preloaded in agent context
- Agent has immediate access to all skill knowledge
- No need to call Read/Glob/Grep - knowledge is already there

#### **Verification Pattern**
To confirm agent-skill coordination is working:
1. Ask a question requiring multiple domains
2. Check if response synthesizes content from multiple domains
3. If synthesis is sophisticated, the agent is coordinating
4. Zero tool uses doesn't mean failure - it means knowledge was preloaded

### The Relative Paths Discovery

#### **File Reference Pattern**
From official Claude documentation:

**NOT Recommended** (absolute paths):
```markdown
See [documentation](/Users/elkraneo/.claude/skills/maxwell-pointfree/knowledge/TCA-SHARED-STATE.md)
```

**Correct Approach** (relative paths):
```markdown
See [TCA patterns](knowledge/guides/TCA-SHARED-STATE.md)
```

#### **Why Relative Paths Matter**
- Claude expects relative paths from skill directory
- Progressive disclosure: files loaded contextually as needed
- Works with Claude's file loading mechanism
- Portable across different installations
- Tested and verified with Maxwell implementation

### Multi-Skill Architecture Proven Pattern

#### **Working Maxwell v3.0 Architecture**

**Individual Skills:**
```yaml
allowed-tools: Read,Glob,Grep  # Local files ONLY
knowledge/: 28+ files per skill
triggers: Domain-specific keywords
auto-trigger: Yes, on keyword match
result: Reads embedded knowledge files (verified by > 0 tool uses)
```

**Orchestrator Agent:**
```yaml
skills: maxwell-pointfree,maxwell-shareplay,maxwell-visionos,maxwell-meta,maxwell-swift
allowed-tools: Glob,Grep,Read,WebSearch,WebFetch  # Local + web fallback
context: All skill knowledge preloaded at startup
result: Synthesizes across domains (0 tool uses is normal)
```

#### **The Workflow**
1. User asks single-domain question → Skill auto-triggers with embedded knowledge
2. User asks multi-domain question → Agent references preloaded skill knowledge
3. Knowledge gap detected → Agent falls back to WebSearch
4. Result: Always provides answer (local first, web second)

### Critical Implementation Checklist

#### **For Skills to Work Correctly**
- [ ] Use `allowed-tools: Read,Glob,Grep` ONLY (no WebSearch/WebFetch)
- [ ] Reference knowledge files with relative paths: `knowledge/guides/FILE.md`
- [ ] Include direct markdown links to knowledge files in SKILL.md
- [ ] Strip all detailed knowledge descriptions from SKILL.md
- [ ] Minimal skill definition: metadata + tool instructions only
- [ ] Verify with test: expect > 0 tool uses on single-domain question

#### **For Agent to Work Correctly**
- [ ] Include `skills: skill1,skill2,skill3` field in YAML frontmatter
- [ ] Give agent access to web tools (WebSearch, WebFetch) as fallback
- [ ] Expect `0 tool uses` - this is normal when skills preloaded
- [ ] Verify by asking multi-domain question
- [ ] Check response synthesizes across domains

### Lessons for Future Multi-Skill Systems

#### **Tool Access Is Behavioral Control**
Skills don't read instructions to use local files. They choose the easiest path. **Tool restrictions are the mechanism for forcing desired behavior**, not instructions.

#### **Skill Knowledge Must Not Be In SKILL.md**
Any detailed knowledge in the SKILL.md itself becomes implicit knowledge the skill can use without reading files. Keep SKILL.md minimal:
- Metadata (name, description, triggers)
- Configuration (allowed-tools)
- File references to knowledge

#### **Agents Need Preloading, Not Invocation**
The `skills:` field in agent YAML preloads skill knowledge into agent context. This is fundamentally different from dynamically calling skills. Design orchestration with this model in mind.

#### **Zero Tool Uses for Agents Is Correct**
When an agent uses preloaded skills, it won't show tool uses. This is expected. Verify success by analyzing response quality and domain synthesis, not by tool use count.

### Future Agent Development Guidance

#### **Architecture Alignment**
- Follow Claude's sub-agent patterns
- Maintain compatibility with Claude ecosystem
- Use established configuration formats
- Apply security and permission models
- Standards: Consistent with Claude conventions

#### **Best Practice Integration**
- Single responsibility principle for new agents
- Focused tool access control
- Clear system prompts with constraints
- Version management and documentation
- Quality: Professional development standards

#### **Performance Patterns**
- Context window optimization
- Tool permission efficiency
- Latency management strategies
- Resource usage monitoring
- Efficiency: Performance-first design

#### **Security and Safety**
- Tool access restrictions
- Permission mode configuration
- Audit trail capabilities
- Error handling procedures
- Security: Defense-in-depth approach

This architecture knowledge provides the foundation for understanding how Maxwell fits into Claude's broader ecosystem and informs future development of agents and skills that maintain compatibility and leverage established patterns.