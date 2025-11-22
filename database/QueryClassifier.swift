import Foundation

/// Query Classification System
///
/// Analyzes user queries to determine which knowledge base(s) to query
/// Uses keyword analysis, pattern recognition, and context detection

class QueryClassifier {

    // MARK: - Classification Keywords

    private let tcaKeywords = [
        // Core TCA Concepts
        "@Shared", "@SharedReader", "@ObservableState", "@Reducer", "@Dependency",
        "TCA", "The Composable Architecture", "Point-Free",

        // State Management
        "state management", "shared state", "reducer", "action", "effect",
        "IdentifiedArrayOf", "State", "Action", "Body",

        // Testing & Architecture
        "TestStore", "Testable", "feature extraction", "dependency injection",
        "Point-Free Navigation", "Dependencies", "Swift Testing",

        // Specific Patterns
        "sheet presentation", "navigation", "binding", "async effect",
        "cancellation", "Entity component", "scope"
    ]

    private let appleKeywords = [
        // Platforms & Frameworks
        "RealityKit", "ARKit", "RealityView", "Entity", "Component",
        "SwiftUI", "UIKit", "AppKit", "Combine", "Core Data",

        // Apple Platforms
        "iOS", "macOS", "watchOS", "tvOS", "visionOS",
        "iPhone", "iPad", "Mac", "Apple Watch", "Apple TV",

        // Apple Technologies
        "Core Animation", "Metal", "SceneKit", "SpriteKit",
        "Core Motion", "Core Location", "Core Bluetooth",

        // Development Tools
        "Xcode", "SwiftUI Preview", "Interface Builder",
        "Instruments", "Swift Package Manager"
    ]

    private let wwdcKeywords = [
        "WWDC", "session", "video", "talk", "presentation",
        "Apple event", "developer conference", "keynote"
    ]

    private let hybridKeywords = [
        // Combinations that suggest both TCA and Apple knowledge
        "SwiftUI + TCA", "TCA SwiftUI", "RealityKit TCA",
        "SwiftUI state management TCA", "TCA visionOS",
        "Entity component TCA"
    ]

    // MARK: - Main Classification Method

    func classify(query: String) -> QueryDomain {
        let normalizedQuery = query.lowercased()

        // Check for explicit hybrid patterns first
        if isExplicitlyHybrid(normalizedQuery) {
            return .hybrid
        }

        // Calculate keyword scores
        let tcaScore = calculateKeywordScore(normalizedQuery, keywords: tcaKeywords)
        let appleScore = calculateKeywordScore(normalizedQuery, keywords: appleKeywords)
        let wwdcScore = calculateKeywordScore(normalizedQuery, keywords: wwdcKeywords)

        // Analyze query patterns
        let patternScore = analyzeQueryPatterns(normalizedQuery)

        // Combine scores with weights
        let finalTCAScore = tcaScore * 0.6 + patternScore.tcaPattern * 0.4
        let finalAppleScore = appleScore * 0.7 + wwdcScore * 0.3

        // Make classification decision
        return makeClassificationDecision(
            tcaScore: finalTCAScore,
            appleScore: finalAppleScore,
            query: normalizedQuery
        )
    }

    // MARK: - Score Calculations

    private func calculateKeywordScore(query: String, keywords: [String]) -> Double {
        let queryWords = query.components(separatedBy: .whitespacesAndNewlines)
        var matches = 0
        var totalWeight = 0.0

        for keyword in keywords {
            let keywordLower = keyword.lowercased()
            let keywordWords = keywordLower.components(separatedBy: .whitespacesAndNewlines)

            // Check for exact matches
            if query.contains(keywordLower) {
                matches += 1
                totalWeight += 2.0 // Exact match gets higher weight
            }

            // Check for partial word matches
            for queryWord in queryWords {
                for keywordWord in keywordWords {
                    if queryWord.contains(keywordWord) || keywordWord.contains(queryWord) {
                        matches += 1
                        totalWeight += 1.0
                    }
                }
            }
        }

        // Normalize score (0.0 to 1.0)
        let maxPossibleScore = Double(keywords.count) * 2.0
        return totalWeight > 0 ? min(totalWeight / maxPossibleScore, 1.0) : 0.0
    }

    private func analyzeQueryPatterns(_ query: String) -> (tcaPattern: Double, applePattern: Double) {
        var tcaPattern = 0.0
        var applePattern = 0.0

        // TCA-specific patterns
        if query.contains("@") { tcaPattern += 0.3 } // Property wrappers
        if query.contains("feature") { tcaPattern += 0.2 }
        if query.contains("reducer") { tcaPattern += 0.2 }
        if query.contains("dependency") { tcaPattern += 0.2 }
        if query.contains("test store") { tcaPattern += 0.2 }

        // Apple-specific patterns
        if query.contains("view") { applePattern += 0.1 }
        if query.contains("controller") { applePattern += 0.2 }
        if query.contains("delegate") { applePattern += 0.1 }
        if query.contains("framework") { applePattern += 0.1 }
        if query.contains("api") { applePattern += 0.1 }

        // Question patterns
        if query.contains("how to implement") {
            tcaPattern += 0.1
            applePattern += 0.1
        }

        if query.contains("best practices") {
            tcaPattern += 0.1
            applePattern += 0.1
        }

        return (min(tcaPattern, 1.0), min(applePattern, 1.0))
    }

    // MARK: - Classification Decision Logic

    private func isExplicitlyHybrid(_ query: String) -> Bool {
        for hybridKeyword in hybridKeywords {
            if query.contains(hybridKeyword.lowercased()) {
                return true
            }
        }
        return false
    }

    private func makeClassificationDecision(
        tcaScore: Double,
        appleScore: Double,
        query: String
    ) -> QueryDomain {

        let threshold = 0.3
        let dominantThreshold = 0.5

        // Clear winner scenarios
        if tcaScore >= dominantThreshold && appleScore < threshold {
            return .tcaPrimary
        }

        if appleScore >= dominantThreshold && tcaScore < threshold {
            return .applePrimary
        }

        // Hybrid scenarios (both significant)
        if tcaScore >= threshold && appleScore >= threshold {
            return .hybrid
        }

        // Low confidence scenarios - use heuristics
        if tcaScore < threshold && appleScore < threshold {
            return classifyLowConfidence(query: query)
        }

        // Edge case - slight preference to the higher score
        if tcaScore > appleScore {
            return .tcaPrimary
        } else if appleScore > tcaScore {
            return .applePrimary
        } else {
            return .unknown
        }
    }

    private func classifyLowConfidence(query: String) -> QueryDomain {
        // Use heuristics for low-confidence queries

        // Check for development context
        if query.contains("app") || query.contains("development") {
            return .applePrimary
        }

        // Check for architecture context
        if query.contains("architecture") || query.contains("pattern") {
            return .tcaPrimary
        }

        // Check for debugging/problem-solving context
        if query.contains("bug") || query.contains("error") || query.contains("fix") {
            return .hybrid // Could be either
        }

        // Default to unknown (query both conservatively)
        return .unknown
    }

    // MARK: - Classification Confidence

    func getClassificationConfidence(query: String, domain: QueryDomain) -> Double {
        let normalizedQuery = query.lowercased()

        switch domain {
        case .tcaPrimary:
            return calculateKeywordScore(normalizedQuery, keywords: tcaKeywords)

        case .applePrimary:
            return calculateKeywordScore(normalizedQuery, keywords: appleKeywords)

        case .hybrid:
            let tcaScore = calculateKeywordScore(normalizedQuery, keywords: tcaKeywords)
            let appleScore = calculateKeywordScore(normalizedQuery, keywords: appleKeywords)
            return min((tcaScore + appleScore) / 2.0, 1.0)

        case .unknown:
            return 0.0 // Low confidence by definition
        }
    }

    // MARK: - Query Enhancement

    func enhanceQueryForKnowledgeBase(_ query: String, domain: QueryDomain) -> String {
        switch domain {
        case .tcaPrimary:
            return addTCAContext(query)
        case .applePrimary:
            return addAppleContext(query)
        case .hybrid:
            return addHybridContext(query)
        case .unknown:
            return query
        }
    }

    private func addTCAContext(_ query: String) -> String {
        var enhanced = query

        // Add relevant TCA terms if not present
        if !query.lowercased().contains("tca") && !query.lowercased().contains("@shared") {
            enhanced += " TCA architecture"
        }

        return enhanced
    }

    private func addAppleContext(_ query: String) -> String {
        var enhanced = query

        // Add relevant Apple terms if not present
        if !query.lowercased().contains("ios") && !query.lowercased().contains("swiftui") {
            enhanced += " iOS development"
        }

        return enhanced
    }

    private func addHybridContext(_ query: String) -> String {
        var enhanced = query

        // For hybrid queries, ensure both contexts are represented
        if !query.lowercased().contains("tca") {
            enhanced += " TCA"
        }

        if !query.lowercased().contains("swiftui") && !query.lowercased().contains("ios") {
            enhanced += " iOS"
        }

        return enhanced
    }
}

// MARK: - Query Classification Debugging

extension QueryClassifier {

    func getClassificationDebugInfo(_ query: String) -> QueryClassificationDebug {
        let normalizedQuery = query.lowercased()

        let tcaScore = calculateKeywordScore(normalizedQuery, keywords: tcaKeywords)
        let appleScore = calculateKeywordScore(normalizedQuery, keywords: appleKeywords)
        let wwdcScore = calculateKeywordScore(normalizedQuery, keywords: wwdcKeywords)
        let patternScore = analyzeQueryPatterns(normalizedQuery)

        let domain = classify(query)
        let confidence = getClassificationConfidence(query: query, domain: domain)

        let matchedTCATerms = findMatchedTerms(normalizedQuery, keywords: tcaKeywords)
        let matchedAppleTerms = findMatchedTerms(normalizedQuery, keywords: appleKeywords)

        return QueryClassificationDebug(
            originalQuery: query,
            normalizedQuery: normalizedQuery,
            classifiedDomain: domain,
            confidence: confidence,
            tcaKeywordScore: tcaScore,
            appleKeywordScore: appleScore,
            wwdcKeywordScore: wwdcScore,
            tcaPatternScore: patternScore.tcaPattern,
            applePatternScore: patternScore.applePattern,
            matchedTCATerms: matchedTCATerms,
            matchedAppleTerms: matchedAppleTerms,
            reasoning: generateClassificationReasoning(
                domain: domain,
                tcaScore: tcaScore,
                appleScore: appleScore,
                wwdcScore: wwdcScore
            )
        )
    }

    private func findMatchedTerms(_ query: String, keywords: [String]) -> [String] {
        return keywords.filter { keyword in
            query.contains(keyword.lowercased())
        }
    }

    private func generateClassificationReasoning(
        domain: QueryDomain,
        tcaScore: Double,
        appleScore: Double,
        wwdcScore: Double
    ) -> String {

        switch domain {
        case .tcaPrimary:
            return "Classified as TCA Primary: TCA score (\(String(format: "%.2f", tcaScore))) > Apple score (\(String(format: "%.2f", appleScore)))"

        case .applePrimary:
            return "Classified as Apple Primary: Apple score (\(String(format: "%.2f", appleScore))) > TCA score (\(String(format: "%.2f", tcaScore)))"

        case .hybrid:
            return "Classified as Hybrid: Both TCA (\(String(format: "%.2f", tcaScore))) and Apple (\(String(format: "%.2f", appleScore))) scores above threshold"

        case .unknown:
            return "Classified as Unknown: Both scores below threshold (TCA: \(String(format: "%.2f", tcaScore)), Apple: \(String(format: "%.2f", appleScore)))"
        }
    }
}

// MARK: - Debug Types

struct QueryClassificationDebug {
    let originalQuery: String
    let normalizedQuery: String
    let classifiedDomain: QueryDomain
    let confidence: Double
    let tcaKeywordScore: Double
    let appleKeywordScore: Double
    let wwdcKeywordScore: Double
    let tcaPatternScore: Double
    let applePatternScore: Double
    let matchedTCATerms: [String]
    let matchedAppleTerms: [String]
    let reasoning: String
}