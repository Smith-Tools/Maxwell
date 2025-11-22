import Foundation

/// Knowledge Gap Detection System
///
/// Analyzes responses to identify missing information and knowledge gaps
/// Automatically detects when additional expertise is needed

class KnowledgeGapDetector {

    // MARK: - Knowledge Base Dictionaries

    private let appleFrameworks = Set([
        "RealityKit", "ARKit", "SceneKit", "SpriteKit", "Metal",
        "SwiftUI", "UIKit", "AppKit", "Combine", "Core Data",
        "Core Animation", "Core Motion", "Core Location", "Core Bluetooth",
        "Vision", "Natural Language", "Speech", "AVFoundation",
        "PassKit", "HealthKit", "HomeKit", "WatchKit", "TVMLKit"
    ])

    private let tcaPatterns = Set([
        "@Shared", "@SharedReader", "@ObservableState", "@Reducer", "@Dependency",
        "IdentifiedArrayOf", "TestStore", "Scope", "Binding", "Effect",
        "Action", "State", "Body", "reduce", "ifLet"
    ])

    private let platformAPIs = Set([
        "RealityView", "ARView", "Entity", "Component", "AnchorEntity",
        "ModelEntity", "CollisionComponent", "PhysicsBodyComponent",
        "UIViewRepresentable", "UIViewControllerRepresentable",
        "ObservableObject", "StateObject", "EnvironmentObject"
    ])

    // MARK: - Main Gap Detection

    func detectGaps(
        maxwellResponse: MaxwellResponse?,
        sosumiResponse: SosumiResponse?,
        originalQuery: String
    ) -> [KnowledgeGap] {
        var gaps: [KnowledgeGap] = []

        // Analyze Maxwell response for Apple knowledge gaps
        if let maxwell = maxwellResponse {
            gaps.append(contentsOf: detectAppleGapsInMaxwellResponse(
                response: maxwell,
                query: originalQuery
            ))
        }

        // Analyze Sosumi response for TCA knowledge gaps
        if let sosumi = sosumiResponse {
            gaps.append(contentsOf: detectTCAGapsInSosumiResponse(
                response: sosumi,
                query: originalQuery
            ))
        }

        // Detect cross-domain gaps
        gaps.append(contentsOf: detectCrossDomainGaps(
            maxwellResponse: maxwellResponse,
            sosumiResponse: sosumiResponse,
            query: originalQuery
        ))

        // Remove duplicates and prioritize
        return prioritizeGaps(gaps)
    }

    // MARK: - Apple Knowledge Gaps in Maxwell Response

    private func detectAppleGapsInMaxwellResponse(
        response: MaxwellResponse,
        query: String
    ) -> [KnowledgeGap] {

        var gaps: [KnowledgeGap] = []

        // Find Apple framework terms mentioned in query but not explained in response
        let queryAppleTerms = extractTermsFromText(query, allowedTerms: appleFrameworks)
        let responseAppleTerms = extractTermsFromText(response.content, allowedTerms: appleFrameworks)
        let missingAppleTerms = Set(queryAppleTerms).subtracting(Set(responseAppleTerms))

        for term in missingAppleTerms {
            gaps.append(KnowledgeGap(
                term: term,
                type: .appleFramework,
                severity: determineSeverity(term: term, query: query),
                context: "Query mentions \(term) but response lacks platform-specific details"
            ))
        }

        // Detect incomplete implementation guidance
        if query.contains("RealityKit") && !response.content.contains("Entity") {
            gaps.append(KnowledgeGap(
                term: "RealityKit Entity implementation",
                type: .platformSpecific,
                severity: .high,
                context: "RealityKit query needs Entity component implementation details"
            ))
        }

        if query.contains("SwiftUI") && !response.content.contains("View") {
            gaps.append(KnowledgeGap(
                term: "SwiftUI View implementation",
                type: .platformSpecific,
                severity: .medium,
                context: "SwiftUI query needs View implementation details"
            ))
        }

        return gaps
    }

    // MARK: - TCA Knowledge Gaps in Sosumi Response

    private func detectTCAGapsInSosumiResponse(
        response: SosumiResponse,
        query: String
    ) -> [KnowledgeGap] {

        var gaps: [KnowledgeGap] = []

        // Find TCA pattern terms mentioned in query but not explained in response
        let queryTCATerms = extractTermsFromText(query, allowedTerms: tcaPatterns)
        let responseTCATerms = extractTermsFromText(response.content, allowedTerms: tcaPatterns)
        let missingTCATerms = Set(queryTCATerms).subtracting(Set(responseTCATerms))

        for term in missingTCATerms {
            gaps.append(KnowledgeGap(
                term: term,
                type: .tcaPattern,
                severity: determineSeverity(term: term, query: query),
                context: "Query mentions \(term) but response lacks TCA architecture details"
            ))
        }

        // Detect missing state management guidance
        if query.contains("state") && !response.content.contains("@State") && !response.content.contains("@Shared") {
            gaps.append(KnowledgeGap(
                term: "State management pattern",
                type: .tcaPattern,
                severity: .high,
                context: "State-related query needs TCA state management guidance"
            ))
        }

        // Detect missing testing guidance
        if query.contains("test") && !response.content.contains("TestStore") {
            gaps.append(KnowledgeGap(
                term: "TCA testing pattern",
                type: .tcaPattern,
                severity: .medium,
                context: "Testing query needs TCA testing guidance"
            ))
        }

        return gaps
    }

    // MARK: - Cross-Domain Gap Detection

    private func detectCrossDomainGaps(
        maxwellResponse: MaxwellResponse?,
        sosumiResponse: SosumiResponse?,
        query: String
    ) -> [KnowledgeGap] {

        var gaps: [KnowledgeGap] = []

        // Check for incomplete integration patterns
        if query.contains("integration") || query.contains("combine") {
            let hasTCAGuidance = maxwellResponse?.content.contains("@Shared") == true
            let hasAppleGuidance = sosumiResponse?.content.contains("SwiftUI") == true

            if !hasTCAGuidance || !hasAppleGuidance {
                gaps.append(KnowledgeGap(
                    term: "Integration pattern",
                    type: .platformSpecific,
                    severity: .medium,
                    context: "Integration query needs both TCA and Apple platform guidance"
                ))
            }
        }

        // Check for missing performance considerations
        if query.contains("performance") || query.contains("optimization") {
            let hasPerformanceGuidance = maxwellResponse?.content.contains("performance") == true ||
                                        sosumiResponse?.content.contains("performance") == true

            if !hasPerformanceGuidance {
                gaps.append(KnowledgeGap(
                    term: "Performance optimization",
                    type: .platformSpecific,
                    severity: .medium,
                    context: "Performance query needs optimization guidance"
                ))
            }
        }

        // Check for missing implementation examples
        let totalResponseLength = (maxwellResponse?.content.count ?? 0) + (sosumiResponse?.content.count ?? 0)
        if totalResponseLength < 500 && (query.contains("example") || query.contains("implement")) {
            gaps.append(KnowledgeGap(
                term: "Implementation example",
                type: .platformSpecific,
                severity: .high,
                context: "Implementation query needs code examples"
            ))
        }

        return gaps
    }

    // MARK: - Helper Methods

    private func extractTermsFromText(_ text: String, allowedTerms: Set<String>) -> [String] {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        var foundTerms: [String] = []

        for term in allowedTerms {
            let termLower = term.lowercased()
            let textLower = text.lowercased()

            if textLower.contains(termLower) {
                foundTerms.append(term)
            }
        }

        return foundTerms
    }

    private func determineSeverity(term: String, query: String) -> KnowledgeGap.GapSeverity {
        // Critical terms get high severity
        if ["RealityKit", "@Shared", "@Reducer", "Entity"].contains(term) {
            return .high
        }

        // Important but not critical terms get medium severity
        if ["SwiftUI", "State", "TestStore", "Component"].contains(term) {
            return .medium
        }

        // Nice-to-have terms get low severity
        return .low
    }

    private func prioritizeGaps(_ gaps: [KnowledgeGap]) -> [KnowledgeGap] {
        // Sort by severity and remove duplicates
        let uniqueGaps = removeDuplicateGaps(gaps)
        return uniqueGaps.sorted { gap1, gap2 in
            // Sort by severity first, then by term
            if gap1.severity != gap2.severity {
                return getSeverityWeight(gap1.severity) > getSeverityWeight(gap2.severity)
            }
            return gap1.term < gap2.term
        }
    }

    private func removeDuplicateGaps(_ gaps: [KnowledgeGap]) -> [KnowledgeGap] {
        var uniqueGaps: [KnowledgeGap] = []
        var seenTerms = Set<String>()

        for gap in gaps {
            let key = "\(gap.term)-\(gap.type)"
            if !seenTerms.contains(key) {
                seenTerms.insert(key)
                uniqueGaps.append(gap)
            }
        }

        return uniqueGaps
    }

    private func getSeverityWeight(_ severity: KnowledgeGap.GapSeverity) -> Int {
        switch severity {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }

    // MARK: - Gap Analysis Reporting

    func generateGapAnalysisReport(
        gaps: [KnowledgeGap],
        maxwellResponse: MaxwellResponse?,
        sosumiResponse: SosumiResponse?,
        query: String
    ) -> GapAnalysisReport {

        let gapTypes = Dictionary(grouping: gaps) { $0.type }
        let severityBreakdown = Dictionary(grouping: gaps) { $0.severity }

        let coverageScore = calculateCoverageScore(
            gaps: gaps,
            query: query,
            hasMaxwellResponse: maxwellResponse != nil,
            hasSosumiResponse: sosumiResponse != nil
        )

        return GapAnalysisReport(
            query: query,
            totalGaps: gaps.count,
            gapTypes: gapTypes,
            severityBreakdown: severityBreakdown,
            coverageScore: coverageScore,
            maxwellConfidence: maxwellResponse?.confidence ?? 0.0,
            sosumiConfidence: sosumiResponse?.confidence ?? 0.0,
            recommendations: generateRecommendations(gaps: gaps)
        )
    }

    private func calculateCoverageScore(
        gaps: [KnowledgeGap],
        query: String,
        hasMaxwellResponse: Bool,
        hasSosumiResponse: Bool
    ) -> Double {
        var score = 1.0

        // Deduct for high severity gaps
        let highSeverityGaps = gaps.filter { $0.severity == .high }.count
        score -= Double(highSeverityGaps) * 0.2

        // Deduct for medium severity gaps
        let mediumSeverityGaps = gaps.filter { $0.severity == .medium }.count
        score -= Double(mediumSeverityGaps) * 0.1

        // Boost for having both knowledge bases
        if hasMaxwellResponse && hasSosumiResponse {
            score += 0.1
        }

        return max(score, 0.0)
    }

    private func generateRecommendations(gaps: [KnowledgeGap]) -> [String] {
        var recommendations: [String] = []

        if gaps.contains(where: { $0.type == .appleFramework }) {
            recommendations.append("Query Sosumi for Apple framework details")
        }

        if gaps.contains(where: { $0.type == .tcaPattern }) {
            recommendations.append("Query Maxwell for TCA pattern examples")
        }

        if gaps.contains(where: { $0.severity == .high }) {
            recommendations.append("High-priority knowledge gaps need immediate attention")
        }

        let implementationGaps = gaps.filter { $0.context.contains("implementation") }
        if !implementationGaps.isEmpty {
            recommendations.append("Add concrete code examples for implementation")
        }

        return recommendations
    }
}

// MARK: - Supporting Types

struct GapAnalysisReport {
    let query: String
    let totalGaps: Int
    let gapTypes: [KnowledgeGap.GapType: [KnowledgeGap]]
    let severityBreakdown: [KnowledgeGap.GapSeverity: [KnowledgeGap]]
    let coverageScore: Double
    let maxwellConfidence: Double
    let sosumiConfidence: Double
    let recommendations: [String]

    var summary: String {
        return """
        Query: "\(query)"
        Total Knowledge Gaps: \(totalGaps)
        Coverage Score: \(String(format: "%.1f%%", coverageScore * 100))

        Gaps by Type:
        \(gapTypes.map { "\($0.key): \($0.value.count)" }.joined(separator: ", "))

        Gaps by Severity:
        \(severityBreakdown.map { "\($0.key): \($0.value.count)" }.joined(separator: ", "))
        """
    }
}