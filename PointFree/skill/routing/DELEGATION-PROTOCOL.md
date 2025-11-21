# Delegation Protocol for maxwell-pointfree

**Purpose**: Define how the coordinating expert delegates to specialists and synthesizes their responses.

## Delegation Flow

### Step 1: Analysis Phase
```python
async def handle_user_query(query, context=None):
    # 1.1 Detect needed frameworks
    frameworks = detect_needed_frameworks(query, context)

    # 1.2 Determine delegation strategy
    if len(frameworks) == 1:
        return await route_to_single_specialist(frameworks[0], query)
    elif len(frameworks) <= 3:
        return await coordinate_multiple_specialists(frameworks, query)
    else:
        return await handle_complex_integration(frameworks, query)
```

### Step 2: Single Specialist Delegation
```python
async def route_to_single_specialist(framework, query):
    specialist = get_specialist(framework)

    # Enhanced context for specialist
    enhanced_query = f"""
    Original Query: {query}

    Context from maxwell-pointfree:
    - This is a {framework} focused question
    - No integration with other Point-Free frameworks is needed
    - User expects {framework} best practices only
    """

    return await specialist.process(enhanced_query)
```

### Step 3: Multiple Specialist Coordination
```python
async def coordinate_multiple_specialists(frameworks, query):
    specialist_tasks = []

    # Prepare context for each specialist
    for framework in frameworks:
        specialist = get_specialist(framework)
        specialist_context = prepare_specialist_context(framework, query, frameworks)
        specialist_tasks.append(
            specialist.process(specialist_context)
        )

    # Execute specialists in parallel
    specialist_responses = await asyncio.gather(*specialist_tasks)

    # Synthesize responses
    return await synthesize_responses(frameworks, specialist_responses, query)
```

## Context Preparation

### TCA Specialist Context
```
Original Query: {query}

Integration Context:
- Working with: [other frameworks detected]
- TCA Scope: [specific TCA aspects needed]
- Dependencies: [what TCA needs from other frameworks]
- Integration Points: [how TCA should interface with others]

Focus on:
- State management patterns relevant to the integration
- Reducer architecture considerations
- Action handling for cross-framework communication
```

### Dependencies Specialist Context
```
Original Query: {query}

Integration Context:
- Supporting frameworks: [frameworks that need dependencies]
- Dependencies Scope: [what dependency patterns are relevant]
- Testing Needs: [test value requirements]
- Integration Points: [dependency interfaces needed]

Focus on:
- Dependency injection for the specific frameworks involved
- @DependencyClient patterns for the use case
- Test value and preview value requirements
```

## Synthesis Engine

### Response Synthesis Algorithm
```python
async def synthesize_responses(frameworks, responses, original_query):
    synthesis = {
        'introduction': '',
        'individual_guidance': {},
        'integration_guidance': {},
        'code_examples': [],
        'testing_strategy': '',
        'validation_checklist': []
    }

    # 1. Build individual framework guidance
    for framework, response in zip(frameworks, responses):
        synthesis['individual_guidance'][framework] = {
            'key_points': extract_key_points(response),
            'code_pattern': extract_code_pattern(response),
            'best_practices': extract_best_practices(response)
        }

    # 2. Create integration guidance
    synthesis['integration_guidance'] = await create_integration_patterns(
        frameworks, responses
    )

    # 3. Combine code examples
    synthesis['code_examples'] = await combine_code_examples(responses)

    # 4. Build testing strategy
    synthesis['testing_strategy'] = await create_testing_strategy(
        frameworks, responses
    )

    # 5. Create validation checklist
    synthesis['validation_checklist'] = await create_integration_checklist(
        frameworks, responses
    )

    return format_synthesized_response(synthesis, original_query)
```

## Communication Protocol

### Specialist → Coordinator API
```json
{
  "framework": "tca",
  "response_type": "implementation",
  "key_patterns": ["@Bindable usage", "State structure"],
  "code_example": {
    "pattern": "state_observation",
    "code": "// TCA state observation code",
    "dependencies": ["SwiftUI", "ComposableArchitecture"]
  },
  "integration_requirements": {
    "needs_from_dependencies": ["@Dependency for Date()"],
    "provides_to_navigation": ["State for navigation destinations"],
    "testing_considerations": ["TestStore usage with dependencies"]
  },
  "validation_points": ["No WithViewStore", "Proper @ObservableState"]
}
```

### Coordinator → User Output Format
```markdown
# Multi-Framework Solution

## Framework-Specific Guidance

### TCA Implementation
[... specialist guidance ...]

### Dependencies Integration
[... specialist guidance ...]

## Integration Patterns

### State + Dependencies Coordination
[... synthesized patterns ...]

## Complete Code Example
[... combined code from all specialists ...]

## Testing Strategy
[... coordinated testing approach ...]

## Validation Checklist
- [ ] TCA validation points
- [ ] Dependencies validation points
- [ ] Integration validation points
```

## Fallback Strategies

### Specialist Unavailable
- Use cached response patterns
- Fall back to integration guide documentation
- Provide general guidance with caveats

### Integration Conflicts
- Identify conflict points between specialist recommendations
- Provide alternative solutions
- Explain trade-offs clearly

### User Intent Unclear
- Ask clarifying questions
- Provide multiple approach options
- Offer to delegate to different specialist combinations