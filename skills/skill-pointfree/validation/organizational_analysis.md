# Smith Tools + Maxwells: Organizational Dependency Analysis

## Current Organizational Structure

```
/Volumes/Plutonian/_Developer/
├── Smith Tools/           ← Git repo (smith-tools)
│   ├── smith-validation/ ← Core framework (needs to be extracted)
│   ├── smith-skill/      ← Infrastructure skill
│   ├── sosumi/           ← Documentation gateway
│   └── smith-cli/        ← Tool orchestration
│
└── Maxwells/             ← Git repo? (independent)
    ├── TCA/
    │   ├── skill/        ← Domain expertise
    │   └── validation/   ← Domain rules (NEW)
    ├── SharePlay/
    ├── RealityKit/
    └── SwiftUI/
```

## Dependency Requirements for Framework Approach

### 1. Maxwells Depends On Smith Framework

**Required Dependencies:**
```swift
// Maxwells rules need smith-validation framework:
import SmithValidationFramework
```

**What Maxwells needs from smith-validation:**
- `SourceFileContext` - File context utilities
- `SourceFileSyntax.findTCAReducers()` - AST operations
- `StructInfo/EnumInfo` - Semantic models
- `ArchitecturalViolation` - Reporting structure
- `ViolationCollection` - Result container

### 2. Smith Validation Depends On Maxwells Rules

**Required Dependencies:**
- Rule discovery from Maxwells directories
- Rule loading and compilation
- Rule execution orchestration

## Organizational Models

### Model A: Independent Organizations (Current)

**Pros:**
- ✅ Maxwells can evolve independently
- ✅ Different release cycles
- ✅ Separate ownership/teams
- ✅ Clear domain boundaries

**Cons:**
- ❌ Complex dependency management
- ❌ Version compatibility issues
- ❌ Release coordination required
- ❌ Installation complexity

### Model B: Smith Tools Umbrella

**Structure:**
```
Smith Tools/
├── Framework/
│   ├── smith-validation-core/     ← AST framework
│   └── smith-validation-engine/   ← Rule loading
├── Skills/
│   ├── smith-skill/              ← Infrastructure skill
│   ├── maxwell-tca/              ← Moved here
│   ├── maxwell-shareplay/        ← Moved here
│   └── maxwell-realitykit/       ← Moved here
└── Tools/
    ├── smith-cli/                ← Orchestration
    └── sosumi/                   ← Documentation
```

**Pros:**
- ✅ Single dependency management
- ✅ Coordinated releases
- ✅ Simplified installation
- ✅ Version compatibility guaranteed

**Cons:**
- ❌ Maxwells loses independence
- ❌ Larger, slower release cycles
- ❌ Mixed ownership complexity
- ❌ Scope creep risk

### Model C: Framework-First Separation

**Structure:**
```
/Volumes/Plutonian/_Developer/
├── Smith Framework/              ← Core infrastructure org
│   ├── SmithValidationCore/      ← AST framework
│   ├── SmithValidationEngine/    ← Rule engine
│   └── SmithIntegration/         ├── CLI/Tool integration
│
├── Smith Tools/                  ← Tool implementation org
│   ├── smith-skill/              ← Infrastructure skill
│   ├── smith-cli/                ← Tool orchestration
│   └── sosumi/                   ← Documentation
│
└── Maxwells/                     ← Domain specialist org (INDEPENDENT)
    ├── TCA/                      ← Domain expertise only
    ├── SharePlay/                ← Domain expertise only
    └── RealityKit/               ← Domain expertise only
```

**Dependency Flow:**
- Maxwells depends on Smith Framework (dependency)
- Smith Tools depends on Smith Framework (core)
- Smith Tools integrates with Maxwells (optional)

## Recommended Approach: Model C

### Why Model C Works Best:

1. **Clear Separation of Concerns:**
   - **Smith Framework**: Pure infrastructure, no domain rules
   - **Smith Tools**: Tools that use framework
   - **Maxwells**: Domain expertise only

2. **Managed Dependencies:**
   - Smith Framework provides stable APIs
   - Semantic versioning for compatibility
   - Independent evolution possible

3. **Scalability:**
   - Add new Maxwells specialists without affecting Smith
   - Smith can add new tools without breaking Maxwells
   - Framework can evolve with backward compatibility

4. **Release Independence:**
   - Maxwells can release when domain patterns change
   - Smith Framework can release when infrastructure evolves
   - Smith Tools can release when tooling needs change

### Implementation Plan:

#### Phase 1: Extract Framework
```bash
# Move framework components to dedicated org
smith-validation → SmithValidationCore
rule engine → SmithValidationEngine
```

#### Phase 2: Update Dependencies
```swift
// Maxwells uses framework as dependency
import SmithValidationCore

// Smith Tools uses framework as dependency
import SmithValidationEngine
```

#### Phase 3: Integration Layer
```swift
// Smith Tools discovers and loads Maxwells rules
let maxwellsRules = SmithValidationEngine.loadRules(
    from: ["~/.claude/skills/maxwell-tca/validation/"]
)
```

### Installation Workflow:
```bash
# 1. Install Smith Framework (once)
git clone https://github.com/SmithFramework/SmithValidationCore

# 2. Install Smith Tools (once)
git clone https://github.com/SmithTools/smith-cli

# 3. Install Maxwells specialists (as needed)
git clone https://github.com/Maxwells/maxwell-tca
git clone https://github.com/Maxwells/maxwell-shareplay

# 4. smith-validation automatically discovers and uses Maxwells rules
smith-validation --validate
```

### Benefits:
- ✅ Maxwells stays independent
- ✅ Smith provides stable framework
- ✅ Clear dependency management
- ✅ Scalable architecture
- ✅ Independent release cycles
- ✅ Minimal integration complexity