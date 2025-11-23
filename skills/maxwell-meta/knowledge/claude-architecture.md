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