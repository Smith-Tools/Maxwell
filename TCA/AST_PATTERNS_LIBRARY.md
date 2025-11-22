# AST Patterns Library for TCA Validation

## Overview

This library provides a comprehensive collection of SwiftSyntax AST patterns and utilities for detecting TCA architectural patterns and violations. It serves as the foundation for building sophisticated validation rules.

## Core AST Patterns

### TCA Reducer Detection

```swift
// Pattern: @Reducer attribute or : Reducer conformance
extension SourceFileSyntax {
    /// Find all structs that are TCA reducers
    func findTCAReducers() -> [StructDeclSyntax] {
        let visitor = TCAReducerVisitor()
        visitor.walk(self)
        return visitor.reducers
    }

    /// Find State structs within TCA reducers
    func findStatesInTCAReducers() -> [StructDeclSyntax] {
        return findTCAReducers().compactMap { reducer in
            reducer.memberBlock.members.compactMap { member in
                if let structDecl = member.decl.as(StructDeclSyntax.self),
                   structDecl.name.text == "State" {
                    return structDecl
                }
                return nil
            }
        }.first
    }
}

class TCAReducerVisitor: SyntaxVisitor {
    var reducers: [StructDeclSyntax] = []

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        let hasReducerAttribute = node.attributes.contains { attribute in
            attribute.as(AttributeSyntax.self)?.attributeName.text == "Reducer"
        }

        let conformsToReducer = node.inheritanceClause?.inheritedTypes.contains { type in
            type.type.as(IdentifierTypeSyntax.self)?.identifier.text == "Reducer"
        } ?? false

        if hasReducerAttribute || conformsToReducer {
            reducers.append(node)
        }

        return .skipChildren
    }
}
```

### State Property Analysis

```swift
extension StructDeclSyntax {
    /// Extract all properties from a State struct
    func extractStateProperties() -> [VariableDeclSyntax] {
        return memberBlock.members.compactMap { member in
            member.decl.as(VariableDeclSyntax.self)
        }
    }

    /// Count total properties
    var propertyCount: Int {
        return extractStateProperties().count
    }

    /// Detect large State structs (potential Rule 1.1 violations)
    func isMonolithicState(threshold: Int = 15) -> Bool {
        return propertyCount > threshold
    }
}
```

### Action Case Analysis

```swift
extension EnumDeclSyntax {
    /// Extract all cases from an Action enum
    func extractActionCases() -> [EnumCaseElementSyntax] {
        return memberBlock.members.compactMap { member in
            member.decl.as(EnumCaseDeclSyntax.self)?.elements
        }.flatMap { $0 }
    }

    /// Count total cases
    var caseCount: Int {
        return extractActionCases().count
    }

    /// Detect large Action enums (potential Rule 1.3 violations)
    func isMonolithicAction(threshold: Int = 40) -> Bool {
        return caseCount > threshold
    }

    /// Find duplicate case patterns
    func findDuplicateCases() -> [String: Int] {
        let cases = extractActionCases()
        let caseNames = cases.map { $0.name.text }
        return Dictionary(grouping: caseNames) { $0 }.mapValues { $0.count }
    }
}
```

### Dependency Injection Patterns

```swift
class DependencyInjectionVisitor: SyntaxVisitor {
    private var violations: [ArchitecturalViolation] = []
    private let filePath: String

    func analyze(_ node: FunctionDeclSyntax) -> [ArchitecturalViolation] {
        violations.removeAll()
        walk(node)
        return violations
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        // Detect direct client instantiation
        if let calledExpression = node.calledExpression.as(IdentifierTypeSyntax.self) {
            let clientName = calledExpression.name.text

            if clientName.contains("Client") && !clientName.contains("var") {
                violations.append(createViolation(
                    message: "Direct client instantiation detected",
                    line: node.position.line,
                    recommendation: "Use @Dependency(\.\.\.clientName) instead"
                ))
            }
        }

        return .skipChildren
    }

    override func visit(_ node: MemberAccessExprSyntax) -> SyntaxVisitorContinueKind {
        // Detect dependency usage without @Dependency
        if let base = node.base?.as(IdentifierExprSyntax.self)?.identifier.text,
           base.contains("client") || base.contains("Client") {
            violations.append(createViolation(
                message: "Dependency used without proper injection",
                line: node.position.line,
                recommendation: "Declare dependency with @Dependency(\.\.\.base)"
            ))
        }

        return .skipChildren
    }
}
```

## Advanced Pattern Detection

### Code Duplication Detection

```swift
class CodeDuplicationAnalyzer {
    func findDuplicatePatterns(in syntax: SourceFileSyntax) -> DuplicationReport {
        let visitor = CodePatternVisitor()
        visitor.walk(syntax)

        return DuplicationReport(
            duplicateMethods: visitor.duplicateMethods,
            duplicatePropertyDefinitions: visitor.duplicateProperties,
            similarSwitchCases: visitor.similarSwitchCases
        )
    }
}

class CodePatternVisitor: SyntaxVisitor {
    var duplicateMethods: [(name: String, line: Int)] = []
    var duplicateProperties: [(name: String, line: Int)] = []
    var similarSwitchCases: [(pattern: String, count: Int)] = []

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        if let name = node.name.text {
            duplicateMethods.append((name: name, line: node.position.line))
        }
        return .skipChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        if let name = node.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
            duplicateProperties.append((name: name, line: node.position.line))
        }
        return .skipChildren
    }
}

struct DuplicationReport {
    let duplicateMethods: [(name: String, line: Int)]
    let duplicateProperties: [(name: String, line: Int)]
    let similarSwitchCases: [(pattern: String, count: Int)]

    var hasMethodDuplication: Bool {
        let methodNames = Dictionary(grouping: duplicateMethods) { $0.name }.mapValues { $0.count }
        return methodNames.values.contains { $0 > 1 }
    }
}
```

### Naming Convention Validation

```swift
struct NamingConventionAnalyzer {
    private static let vagueNames = Set([
        "data", "stuff", "temp", "value", "item", "thing", "object",
        "result", "info", "details", "content", "payload"
    ])

    private static let genericVerbs = Set([
        "handle", "process", "manage", "do", "perform", "execute",
        "action", "event", "operation", "task", "activity"
    ])

    func analyzeVariable(_ node: VariableDeclSyntax) -> [NamingIssue] {
        var issues: [NamingIssue] = []

        if let identifier = node.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
            if vagueNames.contains(identifier) {
                issues.append(NamingIssue(
                    name: identifier,
                    type: .vague,
                    line: node.position.line
                ))
            }
        }

        return issues
    }

    func analyzeFunction(_ node: FunctionDeclSyntax) -> [NamingIssue] {
        var issues: [NamingIssue] = []

        if let name = node.name.text {
            let components = name.components(separatedBy: CharacterSet.uppercaseLetters.inverted)
                .filter { !$0.isEmpty }

            if components.count > 3 {
                issues.append(NamingIssue(
                    name: name,
                    type: .tooLong,
                    line: node.position.line
                ))
            }

            for component in components {
                if genericVerbs.contains(component.lowercased()) {
                    issues.append(NamingIssue(
                        name: name,
                        type: .generic,
                        line: node.position.line
                    ))
                    break
                }
            }
        }

        return issues
    }
}

struct NamingIssue {
    let name: String
    let type: NamingIssueType
    let line: Int
}

enum NamingIssueType {
    case vague
    case generic
    case tooLong
    case camelCase
}
```

### State Coupling Analysis

```swift
struct StateCouplingAnalyzer {
    func analyzeStateCoupling(in syntax: SourceFileSyntax) -> [CouplingIssue] {
        let visitor = StateVisitor()
        visitor.walk(syntax)

        var issues: [CouplingIssue] = []

        for stateStruct in visitor.stateStructs {
            // Check for unrelated concepts
            let domainConcepts = extractDomainConcepts(stateStruct)
            let couplingScore = calculateCouplingScore(domainConcepts)

            if couplingScore > 0.7 {
                issues.append(CouplingIssue(
                    stateName: stateStruct.name.text,
                    concepts: domainConcepts,
                    score: couplingScore,
                    line: stateStruct.position.line
                ))
            }
        }

        return issues
    }

    private func extractDomainConcepts(_ structDecl: StructDeclSyntax) -> [String] {
        let properties = structDecl.extractStateProperties()
        var concepts: [String] = []

        for property in properties {
            if let identifier = property.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                concepts.append(extractDomainConcept(from: identifier))
            }
        }

        return Array(Set(concepts))
    }

    private func extractDomainConcept(from identifier: String) -> String {
        // Extract semantic domain from variable names
        let concepts = [
            "user": ["profile", "auth", "session", "account"],
            "product": ["item", "cart", "price", "inventory"],
            "ui": ["theme", "layout", "navigation", "animation"],
            "data": ["cache", "storage", "network", "database"],
            "analytics": ["tracking", "event", "metric", "report"]
        ]

        let lowerIdentifier = identifier.lowercased()

        for (concept, keywords) in concepts {
            if keywords.contains(where: lowerIdentifier.contains($0)) {
                return concept
            }
        }

        return "unknown"
    }

    private func calculateCouplingScore(_ concepts: [String]) -> Double {
        let uniqueConcepts = Set(concepts)

        // Higher score if many different domains are mixed
        switch uniqueConcepts.count {
        case 0...1: return 0.0
        case 2: return 0.3
        case 3: return 0.6
        case 4: return 0.8
        default: return 1.0
        }
    }
}

struct CouplingIssue {
    let stateName: String
    let concepts: [String]
    let score: Double
    let line: Int
}
```

## Utility Functions

### Common AST Utilities

```swift
extension SyntaxProtocol {
    /// Get the line number for a syntax node
    var lineNumber: Int {
        let source = root.description
        let position = position.utf8Offset
        return source.prefix(position).components(separatedBy: .newlines).count
    }

    /// Extract the content as a string
    var content: String {
        return description
    }

    /// Check if node contains a pattern
    func contains(_ pattern: String) -> Bool {
        return description.contains(pattern)
    }

    /// Count occurrences of a pattern
    func countOccurrences(of pattern: String) -> Int {
        return description.components(separatedBy: pattern).count - 1
    }
}

extension AttributeListSyntax {
    /// Check if any attribute matches the predicate
    func containsAttribute(where predicate: (AttributeSyntax) -> Bool) -> Bool {
        return contains { attribute in
            attribute.as(AttributeSyntax.self).map(predicate) ?? false
        }
    }
}
```

### Validation Helpers

```swift
struct ValidationContext {
    let filePath: String
    let syntax: SourceFileSyntax

    var violations: [ArchitecturalViolation] = []

    init(filePath: String, syntax: SourceFileSyntax) {
        self.filePath = filePath
        self.syntax = syntax
    }

    func addViolation(
        rule: String,
        line: Int,
        message: String,
        severity: ArchitecturalViolation.Severity = .medium,
        recommendation: String? = nil
    ) {
        let violation = ArchitecturalViolation(
            severity: severity,
            rule: rule,
            file: filePath,
            line: line,
            message: message,
            recommendation: recommendation
        )
        violations.append(violation)
    }
}

extension ValidationContext {
    var violationCount: Int {
        return violations.count
    }

    var highPriorityViolations: Int {
        return violations.filter { $0.severity == .high || $0.severity == .critical }.count
    }

    var violationCollection: ViolationCollection {
        return ViolationCollection(violations: violations)
    }
}
```

## Pattern Matching Utilities

### Complex Pattern Detection

```swift
enum TCAPattern {
    // Rule 1.1: Monolithic Features
    case largeStateStruct(count: Int, threshold: Int)
    case largeActionEnum(count: Int, threshold: Int)

    // Rule 1.2: Dependency Injection
    case directClientInstantiation(clientType: String)
    case dependencyWithoutInjection(dependencyName: String)

    // Rule 1.3: Code Duplication
    case duplicateMethod(methodName: String)
    case duplicateProperty(propertyName: String)
    case similarSwitchCases(pattern: String)

    // Rule 1.4: Unclear Organization
    case vagueIdentifier(name: String)
    case genericMethodName(methodName: String)
    case poorCodeComplexity(complexity: Double)

    // Rule 1.5: Tightly Coupled State
    case mixedDomains(domains: [String], score: Double)
    case highChildFeatureCount(count: Int)
    var line: Int = 0

    var severity: ArchitecturalViolation.Severity {
        switch self {
        case .largeStateStruct(let count, let threshold):
            return count > threshold * 1.5 ? .critical : .high
        case .largeActionEnum(let count, let threshold):
            return count > threshold * 1.5 ? .high : .medium
        case .directClientInstantiation:
            return .high
        case .dependencyWithoutInjection:
            return .medium
        case .duplicateMethod, .duplicateProperty:
            return .medium
        case .similarSwitchCases:
            return .low
        case .vagueIdentifier, .genericMethodName:
            return .low
        case .poorCodeComplexity:
            return .medium
        case .mixedDomains(let score, _):
            return score > 0.8 ? .high : .medium
        case .highChildFeatureCount:
            return .high
        }
    }

    func createViolation(
        file: String,
        message: String,
        recommendation: String
    ) -> ArchitecturalViolation {
        return ArchitecturalViolation(
            severity: severity,
            rule: "TCA-\(patternType)",
            file: file,
            line: line,
            message: message,
            recommendation: recommendation
        )
    }
}
```

This AST pattern library provides the foundation for building sophisticated TCA validation rules with precise pattern detection and meaningful violation reporting.