#!/usr/bin/env swift

import Foundation

/// API for Detecting and Resolving Pattern Contradictions

struct PatternContradiction: Identifiable {
    let id = UUID()
    let severity: Severity
    let type: ContradictionType
    let patterns: [ConflictingPattern]
    let recommendation: ResolutionStrategy
    let requiresHumanDecision: Bool

    enum Severity {
        case critical    // Direct opposite approaches - must resolve
        case warning     // Different but compatible approaches
        case info        // Alternative approaches - can coexist
    }

    enum ContradictionType {
        case architecturalApproach    // Different fundamental patterns
        case implementationDetail     // Same approach, different code
        case sourceAuthority          // Different source credibility conflict
    }

    struct ConflictingPattern {
        let name: String
        let recommendation: String
        let source: PatternSource
        let credibility: Int
    }

    struct PatternSource {
        let name: String
        let type: SourceType
        let authority: AuthorityLevel
        let url: String?
    }

    enum SourceType {
        case officialDocumentation
        case expertBlog
        case customAnalysis
        case communityPractice
    }

    enum AuthorityLevel {
        case canonical    // Official docs
        case expert       // Original creators
        case derived      // Based on canonical
        case opinion      // Community wisdom
    }

    enum ResolutionStrategy {
        case followHighestCredibility
        case synthesizeApproach
        case requireHumanDecision
        case markAsDeprecated
    }
}

class ContradictionDetectionAPI {

    /// Detects contradictions between patterns and returns actionable results
    func detectContradictions(
        existingPatterns: [Pattern],
        newPatterns: [Pattern]
    ) -> [PatternContradiction] {
        var contradictions: [PatternContradiction] = []

        // Check for direct contradictions
        let directContradictions = findDirectContradictions(
            existing: existingPatterns,
            new: newPatterns
        )

        for contradiction in directContradictions {
            let severity = determineSeverity(contradiction)
            let strategy = determineResolutionStrategy(contradiction, severity: severity)

            contradictions.append(PatternContradiction(
                severity: severity,
                type: .architecturalApproach,
                patterns: contradiction,
                recommendation: strategy,
                requiresHumanDecision: severity == .critical
            ))
        }

        return contradictions
    }

    // MARK: - Private Helper Methods

    private func findDirectContradictions(
        existing: [Pattern],
        new: [Pattern]
    ) -> [[PatternContradiction.ConflictingPattern]] {
        var contradictions: [[PatternContradiction.ConflictingPattern]] = []

        // Look for patterns with same domain but opposite recommendations
        for existingPattern in existing {
            for newPattern in new {
                if existingPattern.domain == newPattern.domain &&
                   areContradictory(existingPattern.recommendation, newPattern.recommendation) {

                    contradictions.append([
                        PatternContradiction.ConflictingPattern(
                            name: existingPattern.name,
                            recommendation: existingPattern.recommendation,
                            source: existingPattern.source,
                            credibility: existingPattern.credibility
                        ),
                        PatternContradiction.ConflictingPattern(
                            name: newPattern.name,
                            recommendation: newPattern.recommendation,
                            source: newPattern.source,
                            credibility: newPattern.credibility
                        )
                    ])
                }
            }
        }

        return contradictions
    }

    private func areContradictory(_ rec1: String, _ rec2: String) -> Bool {
        // Simple contradiction detection - look for opposite keywords
        let contradictoryPairs = [
            ("single", "multiple"),
            ("one", "both"),
            ("only", "allow"),
            ("writer", "writers"),
            ("single writer", "multiple writers"),
            ("only one", "both"),
            ("should own", "can both"),
            ("single owner", "multiple allowed")
        ]

        let rec1Lower = rec1.lowercased()
        let rec2Lower = rec2.lowercased()

        for (word1, word2) in contradictoryPairs {
            if (rec1Lower.contains(word1) && rec2Lower.contains(word2)) ||
               (rec1Lower.contains(word2) && rec2Lower.contains(word1)) {
                print("🔍 Contradiction detected: '\(word1)' vs '\(word2)'")
                print("   Rec1: \(rec1Lower)")
                print("   Rec2: \(rec2Lower)")
                return true
            }
        }

        return false
    }

    private func determineSeverity(_ patterns: [PatternContradiction.ConflictingPattern]) -> PatternContradiction.Severity {
        // TCA domain contradictions are inherently critical
        let isTCADomain = patterns.contains {
            // Check if pattern name contains TCA-related keywords
            $0.name.contains("@Shared") || $0.name.contains("TCA")
        }

        // If TCA domain contradiction, it's critical regardless of credibility
        if isTCADomain {
            return .critical
        }

        // If both have high credibility, it's critical
        let highCredibilityCount = patterns.filter { $0.credibility >= 4 }.count

        if highCredibilityCount >= 2 {
            return .critical
        } else if highCredibilityCount == 1 {
            return .warning
        } else {
            return .info
        }
    }

    private func determineResolutionStrategy(
        _ patterns: [PatternContradiction.ConflictingPattern],
        severity: PatternContradiction.Severity
    ) -> PatternContradiction.ResolutionStrategy {
        switch severity {
        case .critical:
            return .requireHumanDecision
        case .warning:
            return .followHighestCredibility
        case .info:
            return .synthesizeApproach
        }
    }

    /// API Response Structure for User Decision Points
    func generateDecisionPointResponse(_ contradictions: [PatternContradiction]) -> DecisionPointResponse {
        let criticalContradictions = contradictions.filter { $0.severity == .critical }
        let warningContradictions = contradictions.filter { $0.severity == .warning }

        return DecisionPointResponse(
            hasCriticalContradictions: !criticalContradictions.isEmpty,
            criticalCount: criticalContradictions.count,
            warningCount: warningContradictions.count,
            decisionPoints: criticalContradictions.map { contradiction in
                DecisionPoint(
                    contradiction: contradiction,
                    question: generateDecisionQuestion(contradiction),
                    options: generateDecisionOptions(contradiction),
                    recommendedAction: generateRecommendedAction(contradiction)
                )
            }
        )
    }

    struct DecisionPointResponse {
        let hasCriticalContradictions: Bool
        let criticalCount: Int
        let warningCount: Int
        let decisionPoints: [DecisionPoint]

        var shouldProceed: Bool {
            return !hasCriticalContradictions
        }

        var userMessage: String {
            if hasCriticalContradictions {
                return "🚨 **PATTERN CONTRADICTION DETECTED**\n\nFound \(criticalCount) critical contradictions that require your decision before proceeding.\n\nPlease review the decision points below."
            } else if warningCount > 0 {
                return "⚠️ **PATTERN WARNINGS**\n\nFound \(warningCount) minor contradictions. These can be resolved automatically, but you may want to review them."
            } else {
                return "✅ **NO CONTRADICTIONS**\n\nNo contradictions detected. Safe to proceed."
            }
        }
    }

    struct DecisionPoint {
        let contradiction: PatternContradiction
        let question: String
        let options: [DecisionOption]
        let recommendedAction: String

        struct DecisionOption {
            let label: String
            let description: String
            let consequences: String
            let patternName: String?
        }
    }
}

// MARK: - Decision Point Generation

extension ContradictionDetectionAPI {

    private func generateDecisionQuestion(_ contradiction: PatternContradiction) -> String {
        let patternNames = contradiction.patterns.map { $0.name }.joined(separator: " vs ")
        return "How should we resolve the contradiction between \(patternNames)?"
    }

    private func generateDecisionOptions(_ contradiction: PatternContradiction) -> [DecisionPoint.DecisionOption] {
        return contradiction.patterns.map { pattern in
            DecisionPoint.DecisionOption(
                label: "Follow \(pattern.source.name)",
                description: pattern.recommendation,
                consequences: "Credibility: \(pattern.credibility)/5. Authority: \(pattern.source.authority)",
                patternName: pattern.name
            )
        }
    }

    private func generateRecommendedAction(_ contradiction: PatternContradiction) -> String {
        let highestCredibility = contradiction.patterns.max { $0.credibility < $1.credibility }!
        return "Follow \(highestCredibility.source.name) (highest credibility: \(highestCredibility.credibility)/5)"
    }
}

// MARK: - Pattern Data Structures

struct Pattern {
    let name: String
    let domain: String
    let recommendation: String
    let source: PatternContradiction.PatternSource
    let credibility: Int
}

// MARK: - Example Usage

class ExampleUsage {

    func demonstrateContradictionAPI() {
        let api = ContradictionDetectionAPI()

        // Example patterns with contradictory @Shared guidance
        let existingPatterns = [
            Pattern(
                name: "@Shared Multiple Writers",
                domain: "TCA",
                recommendation: "Both features can read/write without explicit dependency chain",
                source: PatternContradiction.PatternSource(
                    name: "TCA-SHARED-STATE.md",
                    type: .customAnalysis,
                    authority: .derived,
                    url: nil
                ),
                credibility: 3
            ),
            Pattern(
                name: "@Shared Official TCA",
                domain: "TCA",
                recommendation: "Concurrent mutations require withLock to prevent race conditions",
                source: PatternContradiction.PatternSource(
                    name: "TCA DocC - SharingState.md",
                    type: .officialDocumentation,
                    authority: .canonical,
                    url: nil
                ),
                credibility: 5
            )
        ]

        let newPatterns = [
            Pattern(
                name: "@Shared Single Owner",
                domain: "TCA",
                recommendation: "Single writer, multiple readers - Only one feature should own and mutate @Shared state",
                source: PatternContradiction.PatternSource(
                    name: "Smith CLAUDE.md",
                    type: .customAnalysis,
                    authority: .derived,
                    url: nil
                ),
                credibility: 3
            ),
            Pattern(
                name: "@Shared Multiple Allowed",
                domain: "TCA",
                recommendation: "Multiple features can both read and write the same shared state",
                source: PatternContradiction.PatternSource(
                    name: "Current Maxwell Analysis",
                    type: .customAnalysis,
                    authority: .derived,
                    url: nil
                ),
                credibility: 4
            )
        ]

        // Detect contradictions
        let contradictions = api.detectContradictions(
            existingPatterns: existingPatterns,
            newPatterns: newPatterns
        )

        print("\n🐛 DEBUG: Found \(contradictions.count) contradictions")
        for (index, contradiction) in contradictions.enumerated() {
            print("  \(index + 1). Severity: \(contradiction.severity)")
            print("     Patterns: \(contradiction.patterns.count)")
        }

        // Generate decision point response
        let response = api.generateDecisionPointResponse(contradictions)

        // Display results
        print("\n🔍 CONTRADICTION API RESPONSE")
        print(String(repeating: "=", count: 50))
        print(response.userMessage)

        if !response.decisionPoints.isEmpty {
            print("\n🎯 DECISION POINTS:")
            for (index, decisionPoint) in response.decisionPoints.enumerated() {
                print("\n\(index + 1). \(decisionPoint.question)")
                print("   💡 Recommended: \(decisionPoint.recommendedAction)")

                print("\n   Options:")
                for (optionIndex, option) in decisionPoint.options.enumerated() {
                    print("   \(optionIndex + 1). \(option.label)")
                    print("      \(option.description)")
                    print("      \(option.consequences)")
                }
            }

            print("\n🚦 STATUS: Requires human decision before proceeding")
        }
    }
}

// Run the example
let example = ExampleUsage()
example.demonstrateContradictionAPI()