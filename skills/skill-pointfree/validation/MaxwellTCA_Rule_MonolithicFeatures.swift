// Maxwell TCA Rule: Monolithic Features validation
// Moved from smith-validation for feasibility test

import Foundation
import SwiftSyntax

/// Maxwell TCA Rule: Monolithic Features Validator
///
/// Detects:
/// - State structs with >15 properties (threshold for monolithic features)
/// - Action enums with >40 cases (threshold for monolithic features)
///
/// Rationale:
/// - Large State structs indicate multiple features crammed into one reducer
/// - Large Action enums suggest too much responsibility in a single feature
/// - Both patterns lead to maintenance issues and testing complexity
public struct MaxwellTCARule_MonolithicFeatures {

    // Simple violation structure for standalone testing
    public struct Violation {
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
        public let violations: [Violation]

        public init(violations: [Violation] = []) {
            self.violations = violations
        }

        public var isEmpty: Bool {
            violations.isEmpty
        }

        public var count: Int {
            violations.count
        }
    }

    public struct Configuration {
        public let maxStateProperties: Int
        public let maxActionCases: Int
        public let severity: Violation.Severity

        public init(
            maxStateProperties: Int = 15,
            maxActionCases: Int = 40,
            severity: Violation.Severity = .high
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

    /// Validate a Swift file for monolithic feature violations
    /// - Parameter filePath: Path to the Swift file to validate
    /// - Returns: Collection of architectural violations
    public func validate(filePath: String) -> ViolationCollection {
        guard let sourceCode = try? String(contentsOfFile: filePath) else {
            return ViolationCollection()
        }

        do {
            let syntax = try SyntaxParser.parse(source: sourceCode)
            return validate(syntax: syntax, filePath: filePath)
        } catch {
            return ViolationCollection()
        }
    }

    /// Validate Swift syntax for monolithic feature violations
    /// - Parameters:
    ///   - syntax: Parsed Swift syntax tree
    ///   - filePath: File path for reporting
    /// - Returns: Collection of architectural violations
    public func validate(syntax: SourceFileSyntax, filePath: String) -> ViolationCollection {
        var violations: [Violation] = []

        // Find all TCA reducers in the file
        let reducers = findTCAReducers(in: syntax)

        for reducer in reducers {
            // Validate State struct
            if let stateStruct = findNestedStruct(in: reducer, named: "State") {
                violations.append(contentsOf: validateStateStruct(stateStruct, in: reducer, filePath: filePath))
            }

            // Validate Action enum
            if let actionEnum = findNestedEnum(in: reducer, named: "Action") {
                violations.append(contentsOf: validateActionEnum(actionEnum, in: reducer, filePath: filePath))
            }
        }

        return ViolationCollection(violations: violations)
    }

    // MARK: - Private Helper Methods

    private func findTCAReducers(in syntax: SourceFileSyntax) -> [StructDeclSyntax] {
        var reducers: [StructDeclSyntax] = []

        syntax.walk { node in
            if let structDecl = node.as(StructDeclSyntax.self) {
                // Check if this struct conforms to Reducer protocol
                let conformsToReducer = structDecl.inheritanceClause?.inheritedTypes.contains {
                    $0.typeName.as(IdentifierTypeSyntax.self)?.name.text == "Reducer"
                } ?? false

                if conformsToReducer {
                    reducers.append(structDecl)
                }
            }
        }

        return reducers
    }

    private func findNestedStruct(in parent: DeclGroupSyntax, named name: String) -> StructDeclSyntax? {
        for member in parent.memberBlock.members {
            if let structDecl = member.decl.as(StructDeclSyntax.self),
               structDecl.name.text == name {
                return structDecl
            }
        }
        return nil
    }

    private func findNestedEnum(in parent: DeclGroupSyntax, named name: String) -> EnumDeclSyntax? {
        for member in parent.memberBlock.members {
            if let enumDecl = member.decl.as(EnumDeclSyntax.self),
               enumDecl.name.text == name {
                return enumDecl
            }
        }
        return nil
    }

    private func validateStateStruct(_ stateStruct: StructDeclSyntax, in parent: StructDeclSyntax, filePath: String) -> [Violation] {
        var violations: [Violation] = []

        let propertyCount = stateStruct.memberBlock.members.count { member in
            member.decl.as(VariableDeclSyntax.self) != nil
        }

        if propertyCount > configuration.maxStateProperties {
            violations.append(Violation(
                severity: configuration.severity,
                rule: "MaxwellTCA-MonolithicFeatures-State",
                file: filePath,
                line: stateStruct.position.line,
                message: "State struct has \(propertyCount) properties, exceeding limit of \(configuration.maxStateProperties)",
                recommendation: "Consider extracting this into multiple child features or reducing state complexity"
            ))
        }

        return violations
    }

    private func validateActionEnum(_ actionEnum: EnumDeclSyntax, in parent: StructDeclSyntax, filePath: String) -> [Violation] {
        var violations: [Violation] = []

        let caseCount = actionEnum.memberBlock.members.count { member in
            member.decl.as(EnumCaseDeclSyntax.self) != nil
        }

        if caseCount > configuration.maxActionCases {
            violations.append(Violation(
                severity: configuration.severity,
                rule: "MaxwellTCA-MonolithicFeatures-Action",
                file: filePath,
                line: actionEnum.position.line,
                message: "Action enum has \(caseCount) cases, exceeding limit of \(configuration.maxActionCases)",
                recommendation: "Consider splitting this feature into multiple focused features with separate reducers"
            ))
        }

        return violations
    }
}