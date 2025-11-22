// PointFree Cross-Framework Validation Rules
// Swift implementation for validating multi-framework integrations

import Foundation
import SmithValidationCore
import SwiftSyntax

/// Cross-framework validation rules for Point-Free ecosystem
public enum PointFreeValidationRule: ValidatableRule {

    case frameworkBoundaries
    case dependencyIntegration
    case navigationIntegration
    case stateOwnership
    case testingCoverage
    case performanceConsiderations

    public func validate(syntax: SyntaxProtocol) -> [ArchitecturalViolation] {
        switch self {
        case .frameworkBoundaries:
            return validateFrameworkBoundaries(syntax: syntax)
        case .dependencyIntegration:
            return validateDependencyIntegration(syntax: syntax)
        case .navigationIntegration:
            return validateNavigationIntegration(syntax: syntax)
        case .stateOwnership:
            return validateStateOwnership(syntax: syntax)
        case .testingCoverage:
            return validateTestingCoverage(syntax: syntax)
        case .performanceConsiderations:
            return validatePerformanceConsiderations(syntax: syntax)
        }
    }

    // MARK: - Individual Rule Implementations

    /// Rule 1: Framework Boundaries
    /// Validates that frameworks are used within their proper boundaries
    private func validateFrameworkBoundaries(syntax: SyntaxProtocol) -> [ArchitecturalViolation] {
        var violations: [ArchitecturalViolation] = []

        // Check for @Dependency usage in Views (anti-pattern)
        let dependencyInViewPattern = Pattern(
            """
            struct \\w+: View \\{[^}]*@Dependency
            """,
            options: [.dotMatchesLineSeparators]
        )

        if dependencyInViewPattern.matches(in: syntax.description) {
            violations.append(ArchitecturalViolation(
                rule: "PF-1.1",
                severity: .high,
                message: "Direct @Dependency usage detected in SwiftUI View",
                description: "Views should not directly use dependencies. Dependencies should be injected into TCA reducers.",
                suggestion: "Move @Dependency to the corresponding TCA reducer and pass data through the store.",
                location: syntax.startLocation
            ))
        }

        // Check for direct API calls in Views
        let apiCallInViewPattern = Pattern(
            """
            struct \\w+: View \\{[^}]*URLSession|Alamofire|AFNetworking
            """,
            options: [.dotMatchesLineSeparators]
        )

        if apiCallInViewPattern.matches(in: syntax.description) {
            violations.append(ArchitecturalViolation(
                rule: "PF-1.2",
                severity: .high,
                message: "Direct API call detected in SwiftUI View",
                description: "API calls should be handled through Dependencies framework, not directly in views.",
                suggestion: "Create a dependency client and use @Dependency in your TCA reducer.",
                location: syntax.startLocation
            ))
        }

        return violations
    }

    /// Rule 2: Dependency Integration
    /// Validates proper dependency integration patterns
    private func validateDependencyIntegration(syntax: SyntaxProtocol) -> [ArchitecturalViolation] {
        var violations: [ArchitecturalViolation] = []

        // Check for missing DependencyKey conformance
        let dependencyKeyPattern = Pattern(
            """
            extension \\w+: DependencyKey
            """,
            options: []
        )

        if !dependencyKeyPattern.matches(in: syntax.description) {
            // Look for dependency-like structures without proper conformance
            let clientStructPattern = Pattern(
                """
                struct \\w+Client \\{[^}]*var \\w+: @Sendable
                """,
                options: [.dotMatchesLineSeparators]
            )

            if clientStructPattern.matches(in: syntax.description) {
                violations.append(ArchitecturalViolation(
                    rule: "PF-2.1",
                    severity: .medium,
                    message: "Dependency client without DependencyKey conformance",
                    description: "Dependency clients should conform to DependencyKey to be properly integrated.",
                    suggestion: "Add 'extension YourClient: DependencyKey' with liveValue and testValue.",
                    location: syntax.startLocation
                ))
            }
        }

        // Check for missing test values
        let testValuePattern = Pattern(
            """
            static let testValue
            """,
            options: []
        )

        if !testValuePattern.matches(in: syntax.description) && dependencyKeyPattern.matches(in: syntax.description) {
            violations.append(ArchitecturalViolation(
                rule: "PF-2.2",
                severity: .medium,
                message: "DependencyKey without testValue",
                description: "All dependencies should provide test values for proper testing.",
                suggestion: "Add 'static let testValue = YourClient(...)' to your DependencyKey implementation.",
                location: syntax.startLocation
            ))
        }

        return violations
    }

    /// Rule 3: Navigation Integration
    /// Validates proper navigation integration with TCA
    private func validateNavigationIntegration(syntax: SyntaxProtocol) -> [ArchitecturalViolation] {
        var violations: [ArchitecturalViolation] = []

        // Check for NavigationPath usage without TCA coordination
        let navigationPathPattern = Pattern(
            """
            @State.*NavigationPath
            """,
            options: []
        )

        if navigationPathPattern.matches(in: syntax.description) {
            violations.append(ArchitecturalViolation(
                rule: "PF-3.1",
                severity: .medium,
                message: "NavigationPath used without TCA coordination",
                description: "Navigation should be driven by TCA state for predictable behavior.",
                suggestion: "Use NavigationPathState in your TCA State struct and drive navigation through actions.",
                location: syntax.startLocation
            ))
        }

        // Check for sheet presentation without TCA state
        let sheetPresentationPattern = Pattern(
            """
            \\.sheet\\(isPresented: \\$\\w+\\)
            """,
            options: []
        )

        if sheetPresentationPattern.matches(in: syntax.description) {
            violations.append(ArchitecturalViolation(
                rule: "PF-3.2",
                severity: .low,
                message: "Sheet presentation without TCA state",
                description: "Sheet presentation should be driven by TCA state for consistency.",
                suggestion: "Use '.sheet(item: $store.scope(state: \.destination, action: \.destination))' pattern.",
                location: syntax.startLocation
            ))
        }

        return violations
    }

    /// Rule 4: State Ownership
    /// Validates clear ownership of state across frameworks
    private func validateStateOwnership(syntax: SyntaxProtocol) -> [ArchitecturalViolation] {
        var violations: [ArchitecturalViolation] = []

        // Check for state duplication
        let stateStructPattern = Pattern(
            """
            struct State.*\\{[^}]*var \\w+: User[^}]*var \\w+: User
            """,
            options: [.dotMatchesLineSeparators]
        )

        if stateStructPattern.matches(in: syntax.description) {
            violations.append(ArchitecturalViolation(
                rule: "PF-4.1",
                severity: .medium,
                message: "Potential state duplication detected",
                description: "Multiple User properties in State struct may indicate state duplication.",
                suggestion: "Ensure there's a single source of truth for each piece of data.",
                location: syntax.startLocation
            ))
        }

        // Check for @Shared usage without single owner pattern
        let sharedPattern = Pattern(
            """
            @Shared.*var \\w+
            """,
            options: []
        )

        if sharedPattern.matches(in: syntax.description) {
            violations.append(ArchitecturalViolation(
                rule: "PF-4.2",
                severity: .low,
                message: "@Shared usage detected - verify single owner pattern",
                description: "@Shared state should have a single owner and use @SharedReader for access.",
                suggestion: "Ensure only one feature writes to @Shared state; others use @SharedReader.",
                location: syntax.startLocation
            ))
        }

        return violations
    }

    /// Rule 5: Testing Coverage
    /// Validates testing patterns for multi-framework integrations
    private func validateTestingCoverage(syntax: SyntaxProtocol) -> [ArchitecturalViolation] {
        var violations: [ArchitecturalViolation] = []

        // Check for TestStore usage without dependency mocking
        let testStorePattern = Pattern(
            """
            TestStore.*\\{[^}]*\\} withDependencies:
            """,
            options: [.dotMatchesLineSeparators]
        )

        if !testStorePattern.matches(in: syntax.description) && syntax.description.contains("TestStore") {
            violations.append(ArchitecturalViolation(
                rule: "PF-5.1",
                severity: .medium,
                message: "TestStore usage without dependency mocking",
                description: "Tests should mock dependencies to ensure reliability and isolation.",
                suggestion: "Add 'withDependencies: { $0.yourDependency.mockImplementation }' to your TestStore setup.",
                location: syntax.startLocation
            ))
        }

        // Check for async test patterns without proper TestClock
        let asyncTestPattern = Pattern(
            """
            await store\\.send.*\\.[^}]*Task
            """,
            options: []
        )

        if asyncTestPattern.matches(in: syntax.description) && !syntax.description.contains("TestClock") {
            violations.append(ArchitecturalViolation(
                rule: "PF-5.2",
                severity: .low,
                message: "Async operations without TestClock",
                description: "Async tests should use TestClock for deterministic timing.",
                suggestion: "Add '$0.dateClient = .init(clock: TestClock())' to your test dependencies.",
                location: syntax.startLocation
            ))
        }

        return violations
    }

    /// Rule 6: Performance Considerations
    /// Validates performance patterns for multi-framework apps
    private func validatePerformanceConsiderations(syntax: SyntaxProtocol) -> [ArchitecturalViolation] {
        var violations: [ArchitecturalViolation] = []

        // Check for potential performance issues
        let forEachWithPublisherPattern = Pattern(
            """
            ForEach.*\\.onReceive
            """,
            options: []
        )

        if forEachWithPublisherPattern.matches(in: syntax.description) {
            violations.append(ArchitecturalViolation(
                rule: "PF-6.1",
                severity: .low,
                message: "ForEach with onReceive may have performance implications",
                description: "Consider using @Bindable or TCA-driven updates for better performance.",
                suggestion: "Use ForEach with @Bindable store properties or TCA state-driven updates.",
                location: syntax.startLocation
            ))
        }

        // Check for large state structs
        let linesOfCode = syntax.description.components(separatedBy: .newlines).count
        if linesOfCode > 500 {
            violations.append(ArchitecturalViolation(
                rule: "PF-6.2",
                severity: .low,
                message: "Large file detected - consider feature extraction",
                description: "Large files may indicate the need for feature decomposition.",
                suggestion: "Consider breaking this into smaller, focused features.",
                location: syntax.startLocation
            ))
        }

        return violations
    }
}

/// Point-Free validation configuration
public struct PointFreeValidationConfiguration {
    public let enabledRules: [PointFreeValidationRule]
    public let severityThreshold: ArchitecturalViolation.Severity

    public init(
        enabledRules: [PointFreeValidationRule] = [
            .frameworkBoundaries,
            .dependencyIntegration,
            .navigationIntegration,
            .stateOwnership,
            .testingCoverage,
            .performanceConsiderations
        ],
        severityThreshold: ArchitecturalViolation.Severity = .medium
    ) {
        self.enabledRules = enabledRules
        self.severityThreshold = severityThreshold
    }
}

/// Main Point-Free validator
public struct PointFreeValidator: Validatable {
    private let configuration: PointFreeValidationConfiguration

    public init(configuration: PointFreeValidationConfiguration = .init()) {
        self.configuration = configuration
    }

    public func validate(syntax: SyntaxProtocol) -> [ArchitecturalViolation] {
        var allViolations: [ArchitecturalViolation] = []

        for rule in configuration.enabledRules {
            let violations = rule.validate(syntax: syntax)
            allViolations.append(contentsOf: violations)
        }

        // Filter by severity threshold
        return allViolations.filter { $0.severity.rawValue >= configuration.severityThreshold.rawValue }
    }
}

// MARK: - Validation Result Types

extension ArchitecturalViolation {
    public static func pointFreeViolation(
        rule: String,
        severity: Severity,
        message: String,
        description: String,
        suggestion: String,
        location: SourceLocation
    ) -> ArchitecturalViolation {
        ArchitecturalViolation(
            rule: rule,
            severity: severity,
            message: message,
            description: description,
            suggestion: suggestion,
            location: location
        )
    }
}

// MARK: - Pattern Matching Helper

private struct Pattern {
    let regex: NSRegularExpression

    init(_ pattern: String, options: NSRegularExpression.Options = []) {
        do {
            self.regex = try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            fatalError("Invalid regex pattern: \(pattern)")
        }
    }

    func matches(in string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return regex.firstMatch(in: string, options: [], range: range) != nil
    }
}