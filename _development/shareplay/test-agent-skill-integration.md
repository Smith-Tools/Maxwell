# Test: Agent-Skill Integration

## How to Verify the Agent is Using the Skill

### Test 1: Ask the Agent to Reference Specific Skill Files

Ask the agent:
> "Can you read the basic-shareplay-setup.swift file from your skill knowledge base and explain the CodableValue implementation?"

**Expected Response**: The agent should be able to read `~/.claude/skills/maxwell-shareplay/snippets/basic-shareplay-setup.swift` and explain the specific CodableValue implementation that we fixed.

### Test 2: Ask for HIG Compliance Information

Ask the agent:
> "What are the key HIG principles for SharePlay participant lists? Reference your skill's hig-principles.md file."

**Expected Response**: The agent should access `~/.claude/skills/maxwell-shareplay/hig-principles.md` and provide specific HIG guidelines.

### Test 3: Request a Specific Pattern

Ask the agent:
> "Show me the backpressure control pattern from your advanced-concurrency-patterns.swift file."

**Expected Response**: The agent should read the specific Swift file and show the BackpressureController actor implementation.

### Test 4: Ask for visionOS-Specific Guidance

Ask the agent:
> "What are the spatial persona patterns mentioned in your guides/visionos26-features.md file?"

**Expected Response**: The agent should access the visionOS guide and explain spatial persona templates.

## Verification Checklist

If the agent can do these things, the integration is working:

- [ ] Read specific files from `~/.claude/skills/maxwell-shareplay/`
- [ ] Reference exact file paths and content
- [ ] Provide code snippets from the skill
- [ ] Explain specific implementations we created
- [ ] Cross-reference multiple skill files

## Signs It's NOT Working

- Agent gives generic SharePlay advice without specific references
- Agent cannot access or quote from specific skill files
- Agent provides theoretical examples instead of our verified implementations
- Agent doesn't mention the skill knowledge base

## Test It Now

Try asking: `/maxwell-shareplay Read the basic-shareplay-setup.swift file and explain how the CodableValue.encodeToCodableValue() method works.`

If the agent reads and explains our actual implementation (not a generic one), the integration is working!