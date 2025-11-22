// Maxwell TCA Rule: Monolithic Features validation using smith-validation framework
// This version uses smith-validation's sugar coating instead of reimplementing AST utilities

import Foundation
import SwiftSyntax

// Note: This would import smith-validation framework in real implementation
// import SmithValidationFramework

/// Maxwell TCA Rule: Monolithic Features Validator
/// Uses smith-validation framework for AST operations instead of custom implementations
///
/// Detects:
/// - State structs with >15 properties (threshold for monolithic features)
/// - Action enums with >40 cases (threshold for monolithic features)
public struct MaxwellTCARule_MonolithicFeatures_Framework {

    // Use smith-validation's violation structure
    public typealias Violation = ArchitecturalViolation
    public typealias ViolationCollection = ViolationCollection
    public typealias Severity = ArchitecturalViolation.Severity

    public struct Configuration {
        public let maxStateProperties: Int
        public let maxActionCases: Int
        public let severity: Severity

        public init(
            maxStateProperties: Int = 15,
            maxActionCases: Int = 40,
            severity: Severity = .high
        ) {
            self.maxStateProperties = maxStateProperties
            self.maxActionCases = maxActionCases
            self.severity = severity
        }
    }

    private let configuration: Configuration

    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }

    /// Validate a Swift file using smith-validation framework
    /// - Parameter filePath: Path to the Swift file to validate
    /// - Returns: Collection of architectural violations
    public func validate(filePath: String) -> ViolationCollection {
        guard let sourceCode = try? String(contentsOfFile: filePath) else {
            return ViolationCollection()
        }

        do {
            // Use smith-validation framework to parse
            let syntax = try SourceFileSyntax.parse(source: sourceCode)
            let url = URL(fileURLWithPath: filePath)
            let context = SourceFileContext(path: filePath, url: url, syntax: syntax)

            return validate(context: context)
        } catch {
            return ViolationCollection()
        }
    }

    /// Validate using smith-validation framework context
    /// - Parameter context: Source file context from smith-validation framework
    /// - Returns: Collection of architectural violations
    public func validate(context: SourceFileContext) -> ViolationCollection {
        var violations: [Violation] = []

        // Use smith-validation's sugar coating utilities!
        let reducers = context.syntax.findTCAReducers()

        for reducer in reducers {
            // Use smith-validation's built-in methods
            let stateStructs = reducer.findNestedStructs()
            let actionEnums = reducer.findNestedEnums()

            for stateStruct in stateStructs {
                if stateStruct.name == "State" {
                    violations.append(contentsOf: validateStateStruct(stateStruct, in: context))
                }
            }

            for actionEnum in actionEnums {
                if actionEnum.name == "Action" {
                    violations.append(contentsOf: validateActionEnum(actionEnum, in: context))
                }
            }
        }

        return ViolationCollection(violations: violations)
    }

    // MARK: - Validation Methods (using smith-validation framework)

    private func validateStateStruct(_ stateStruct: StructInfo, in context: SourceFileContext) -> [Violation] {
        var violations: [Violation] = []

        // Use smith-validation's computed property count
        let propertyCount = stateStruct.propertyCount

        if propertyCount > configuration.maxStateProperties {
            violations.append(Violation(
                severity: configuration.severity,
                rule: "MaxwellTCA-MonolithicFeatures-State-Framework",
                file: context.relativePath,
                line: stateStruct.lineNumber,
                message: "State struct has \(propertyCount) properties, exceeding limit of \(configuration.maxStateProperties)",
                recommendation: "Consider extracting this into multiple child features or reducing state complexity"
            ))
        }

        return violations
    }

    private func validateActionEnum(_ actionEnum: EnumInfo, in context: SourceFileContext) -> [Violation] {
        var violations: [Violation] = []

        // Use smith-validation's computed case count
        let caseCount = actionEnum.caseCount

        if caseCount > configuration.maxActionCases {
            violations.append(Violation(
                severity: configuration.severity,
                rule: "MaxwellTCA-MonolithicFeatures-Action-Framework",
                file: context.relativePath,
                line: actionEnum.lineNumber,
                message: "Action enum has \(caseCount) cases, exceeding limit of \(configuration.maxActionCases)",
                recommendation: "Consider splitting this feature into multiple focused features with separate reducers"
            ))
        }

        return violations
    }
}

// MARK: - Mock smith-validation Framework (for testing)
// In real implementation, these would be imported from SmithValidationFramework

extension SourceFileSyntax {
    static func parse(source: String) throws -> SourceFileSyntax {
        // This would be provided by smith-validation framework
        // For now, return empty syntax - real implementation would use SwiftParser
        return SourceFileSyntax(leadingTrivia: [], statements: [], trailingTrivia: .newlines(1))
    }
}

public struct ArchitecturalViolation {
    public let severity: Severity
    public let rule: String
    public let file: String
    public let line: Int
    public let message: String
    public let recommendation: String

    public enum Severity: String, CaseIterable {
        case critical = "🔴 CRITICAL"
        case high = "🔴 HIGH"
        case medium = "🟠 MEDIUM"
        case low = "🟡 LOW"
        case info = "🔵 INFO"
    }
}

public struct ViolationCollection {
    public let violations: [ArchitecturalViolation]

    public init(violations: [ArchitecturalViolation] = []) {
        self.violations = violations
    }

    public var isEmpty: Bool {
        violations.isEmpty
    }

    public var count: Int {
        violations.count
    }
}

public struct SourceFileContext {
    public let path: String
    public let url: URL
    public let syntax: SourceFileSyntax

    public init(path: String, url: URL, syntax: SourceFileSyntax) {
        self.path = path
        self.url = url
        self.syntax = syntax
    }

    public var relativePath: String {
        let currentPath = FileManager.default.currentDirectoryPath
        return path.hasPrefix(currentPath) ?
            String(path.dropFirst(currentPath.count + 1)) : path
    }
}

// Mock smith-validation framework extensions
extension SourceFileSyntax {
    public func findTCAReducers() -> [StructInfo] {
        // This would be provided by smith-validation framework
        return []
    }
}

extension StructInfo {
    public func findNestedStructs() -> [StructInfo] {
        // This would be provided by smith-validation framework
        return []
    }

    public func findNestedEnums() -> [EnumInfo] {
        // This would be provided by smith-validation framework
        return []
    }
}

public struct StructInfo {
    public let name: String
    public let propertyCount: Int
    public let lineNumber: Int

    public func findNestedStruct(named name: String) -> StructInfo? {
        return self.name == name ? self : nil
    }
}

public struct EnumInfo {
    public let name: String
    public let caseCount: Int
    public let lineNumber: Int

    public func findNestedEnum(named name: String) -> EnumInfo? {
        return self.name == name ? self : nil
    }
}