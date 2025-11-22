import Foundation

/// Hybrid Knowledge Router
///
/// Routes queries between Maxwell Database (TCA expertise) and Sosumi (Apple ecosystem)
/// Synthesizes responses to provide comprehensive coverage

class HybridKnowledgeRouter {
    private let maxwellDB: SimpleDatabase
    private let sosumiCLI: SosumiInterface
    private let queryClassifier: QueryClassifier
    private let gapDetector: KnowledgeGapDetector
    private let synthesizer: ResponseSynthesizer

    init(maxwellDB: SimpleDatabase) {
        self.maxwellDB = maxwellDB
        self.sosumiCLI = SosumiInterface()
        self.queryClassifier = QueryClassifier()
        self.gapDetector = KnowledgeGapDetector()
        self.synthesizer = ResponseSynthesizer()
    }

    // MARK: - Main Query Interface

    func query(
        _ userQuery: String,
        responseLevel: ResponseLevel = .pattern
    ) async throws -> HybridResponse {

        // 1. Classify the query domain
        let domain = queryClassifier.classify(query: userQuery)
        print("🔍 Query classified as: \(domain)")

        // 2. Route to appropriate knowledge bases
        let responses = try await routeQuery(
            userQuery,
            domain: domain,
            responseLevel: responseLevel
        )

        // 3. Detect knowledge gaps in responses
        let gaps = gapDetector.detectGaps(
            maxwellResponse: responses.maxwell,
            sosumiResponse: responses.sosumi,
            originalQuery: userQuery
        )

        // 4. Fill knowledge gaps if needed
        let filledResponses = try await fillKnowledgeGaps(
            responses: responses,
            gaps: gaps,
            originalQuery: userQuery,
            responseLevel: responseLevel
        )

        // 5. Synthesize final response
        return synthesizer.synthesize(
            maxwellResponse: filledResponses.maxwell,
            sosumiResponse: filledResponses.sosumi,
            domain: domain,
            gaps: gaps,
            responseLevel: responseLevel
        )
    }

    // MARK: - Query Routing

    private func routeQuery(
        _ query: String,
        domain: QueryDomain,
        responseLevel: ResponseLevel
    ) async throws -> (maxwell: MaxwellResponse?, sosumi: SosumiResponse?) {

        var maxwellResponse: MaxwellResponse?
        var sosumiResponse: SosumiResponse?

        switch domain {
        case .tcaPrimary:
            // Only query Maxwell
            maxwellResponse = try await queryMaxwell(query, responseLevel: responseLevel)

        case .applePrimary:
            // Only query Sosumi
            sosumiResponse = try await querySosumi(query, responseLevel: responseLevel)

        case .hybrid:
            // Query both in parallel
            async let maxwellTask = queryMaxwell(query, responseLevel: responseLevel)
            async let sosumiTask = querySosumi(query, responseLevel: responseLevel)

            maxwellResponse = try await maxwellTask
            sosumiResponse = try await sosumiTask

        case .unknown:
            // Query both conservatively
            async let maxwellTask = queryMaxwell(query, responseLevel: .summary)
            async let sosumiTask = querySosumi(query, responseLevel: .summary)

            maxwellResponse = try await maxwellTask
            sosumiResponse = try await sosumiTask
        }

        return (maxwellResponse, sosumiResponse)
    }

    // MARK: - Knowledge Base Interfaces

    private func queryMaxwell(
        _ query: String,
        responseLevel: ResponseLevel
    ) async throws -> MaxwellResponse {

        // Search Maxwell database
        let documents = try maxwellDB.searchDocuments(query: query)

        // Generate progressive response
        let content = ProgressiveResponseGenerator.generateMaxwellResponse(
            documents: documents,
            query: query,
            level: responseLevel
        )

        return MaxwellResponse(
            content: content,
            documents: documents,
            confidence: calculateMaxwellConfidence(documents),
            source: "Maxwell Database",
            responseLevel: responseLevel
        )
    }

    private func querySosumi(
        _ query: String,
        responseLevel: ResponseLevel
    ) async throws -> SosumiResponse {

        // Query Sosumi CLI
        let sosumiResult = try await sosumiCLI.search(
            query: query,
            type: determineSosumiSearchType(query),
            verbosity: mapResponseLevelToVerbosity(responseLevel)
        )

        return SosumiResponse(
            content: sosumiResult.content,
            sessions: sosumiResult.sessions,
            documentation: sosumiResult.documentation,
            confidence: calculateSosumiConfidence(sosumiResult),
            source: "Sosumi (Apple Developer)",
            responseLevel: responseLevel
        )
    }

    // MARK: - Knowledge Gap Filling

    private func fillKnowledgeGaps(
        responses: (maxwell: MaxwellResponse?, sosumi: SosumiResponse?),
        gaps: [KnowledgeGap],
        originalQuery: String,
        responseLevel: ResponseLevel
    ) async throws -> (maxwell: MaxwellResponse?, sosumi: SosumiResponse?) {

        var maxwellResponse = responses.maxwell
        var sosumiResponse = responses.sosumi

        // Fill Apple framework gaps in Maxwell response
        if let maxwell = maxwellResponse {
            let appleGaps = gaps.filter { $0.type == .appleFramework }
            if !appleGaps.isEmpty {
                let supplementaryApple = try await querySosumi(
                    extractGapTerms(appleGaps),
                    responseLevel: .pattern
                )
                // Add supplementary info to Maxwell response
                maxwellResponse = augmentMaxwellResponse(
                    maxwell,
                    with: supplementaryApple
                )
            }
        }

        // Fill TCA gaps in Sosumi response
        if let sosumi = sosumiResponse {
            let tcaGaps = gaps.filter { $0.type == .tcaPattern }
            if !tcaGaps.isEmpty {
                let supplementaryTCA = try await queryMaxwell(
                    extractGapTerms(tcaGaps),
                    responseLevel: .pattern
                )
                // Add supplementary info to Sosumi response
                sosumiResponse = augmentSosumiResponse(
                    sosumi,
                    with: supplementaryTCA
                )
            }
        }

        return (maxwellResponse, sosumiResponse)
    }

    // MARK: - Helper Methods

    private func calculateMaxwellConfidence(_ documents: [Document]) -> Double {
        guard !documents.isEmpty else { return 0.0 }

        let totalScore = documents.map { doc in
            // Consider relevance score, document quality, and match type
            var score = doc.relevanceScore

            // Boost for TCA-specific content
            if doc.category.contains("TCA") {
                score *= 1.2
            }

            // Boost for pattern documents
            if doc.content.contains("Pattern:") || doc.content.contains("@Shared") {
                score *= 1.1
            }

            return min(score, 1.0)
        }.reduce(0, +)

        return min(totalScore / Double(documents.count), 1.0)
    }

    private func calculateSosumiConfidence(_ result: SosumiSearchResult) -> Double {
        guard !result.sessions.isEmpty || !result.documentation.isEmpty else { return 0.0 }

        var confidence = 0.0

        // Sessions are high quality
        if !result.sessions.isEmpty {
            confidence += Double(result.sessions.count) * 0.3
        }

        // Documentation is also valuable
        if !result.documentation.isEmpty {
            confidence += Double(result.documentation.count) * 0.2
        }

        // Cap at 1.0
        return min(confidence, 1.0)
    }

    private func determineSosumiSearchType(_ query: String) -> SosumiSearchType {
        if query.contains("RealityKit") || query.contains("ARKit") || query.contains("visionOS") {
            return .wwdc
        } else if query.contains("@State") || query.contains("SwiftUI") {
            return .combined
        } else {
            return .combined
        }
    }

    private func mapResponseLevelToVerbosity(_ level: ResponseLevel) -> SosumiVerbosity {
        switch level {
        case .summary: return .compact
        case .pattern: return .detailed
        case .example: return .full
        case .fullContext: return .full
        }
    }

    private func extractGapTerms(_ gaps: [KnowledgeGap]) -> String {
        gaps.map { $0.term }.joined(separator: " ")
    }

    private func augmentMaxwellResponse(
        _ response: MaxwellResponse,
        with supplementary: SosumiResponse
    ) -> MaxwellResponse {
        let augmentedContent = """
        \(response.content)

        ---

        🍎 **Apple Platform Integration:**
        \(supplementary.content)
        """

        return MaxwellResponse(
            content: augmentedContent,
            documents: response.documents,
            confidence: min(response.confidence + 0.2, 1.0), // Boost confidence
            source: "\(response.source) + \(supplementary.source)",
            responseLevel: response.responseLevel
        )
    }

    private func augmentSosumiResponse(
        _ response: SosumiResponse,
        with supplementary: MaxwellResponse
    ) -> SosumiResponse {
        let augmentedContent = """
        \(response.content)

        ---

        🏗️ **TCA Architecture Pattern:**
        \(supplementary.content)
        """

        return SosumiResponse(
            content: augmentedContent,
            sessions: response.sessions,
            documentation: response.documentation,
            confidence: min(response.confidence + 0.2, 1.0), // Boost confidence
            source: "\(response.source) + \(supplementary.source)",
            responseLevel: response.responseLevel
        )
    }
}

// MARK: - Supporting Types

enum QueryDomain {
    case tcaPrimary          // Maxwell handles completely
    case applePrimary        // Sosumi handles completely
    case hybrid             // Both contribute
    case unknown            // Requires both

    var description: String {
        switch self {
        case .tcaPrimary: return "TCA Architecture (Maxwell)"
        case .applePrimary: return "Apple Platform (Sosumi)"
        case .hybrid: return "Hybrid (Maxwell + Sosumi)"
        case .unknown: return "Exploratory (Both)"
        }
    }
}

enum ResponseLevel {
    case summary        // ~200 tokens
    case pattern        // ~800 tokens
    case example        // ~2,000 tokens
    case fullContext    // ~5,000+ tokens

    var tokenLimit: Int {
        switch self {
        case .summary: return 200
        case .pattern: return 800
        case .example: return 2000
        case .fullContext: return 5000
        }
    }
}

struct MaxwellResponse {
    let content: String
    let documents: [Document]
    let confidence: Double
    let source: String
    let responseLevel: ResponseLevel
}

struct SosumiResponse {
    let content: String
    let sessions: [WWDCSession]
    let documentation: [AppleDocumentation]
    let confidence: Double
    let source: String
    let responseLevel: ResponseLevel
}

struct HybridResponse {
    let content: String
    let maxwellContribution: MaxwellResponse?
    let sosumiContribution: SosumiResponse?
    let domain: QueryDomain
    let confidence: Double
    let knowledgeGaps: [KnowledgeGap]
    let responseLevel: ResponseLevel
    let synthesisNotes: [String]

    var attribution: String {
        var sources: [String] = []
        if maxwellContribution != nil { sources.append("Maxwell Database") }
        if sosumiContribution != nil { sources.append("Sosumi (Apple Developer)") }
        return sources.joined(separator: " + ")
    }
}

struct KnowledgeGap {
    let term: String
    let type: GapType
    let severity: GapSeverity

    enum GapType {
        case appleFramework    // RealityKit, SwiftUI, etc.
        case tcaPattern      // @Shared, Entity patterns
        case platformSpecific // visionOS, iOS specifics
    }

    enum GapSeverity {
        case low      // Nice to have
        case medium   // Important for complete answer
        case high     // Critical for usable answer
    }
}

// MARK: - Sosumi Interface

class SosumiInterface {
    func search(
        query: String,
        type: SosumiSearchType,
        verbosity: SosumiVerbosity
    ) async throws -> SosumiSearchResult {
        // Implementation would call the actual Sosumi CLI
        // For now, return mock result

        return SosumiSearchResult(
            content: "Apple platform information for: \(query)",
            sessions: [],
            documentation: [],
            searchTime: 0.1
        )
    }
}

enum SosumiSearchType {
    case wwdc
    case documentation
    case combined
}

enum SosumiVerbosity {
    case compact
    case detailed
    case full
}

struct SosumiSearchResult {
    let content: String
    let sessions: [WWDCSession]
    let documentation: [AppleDocumentation]
    let searchTime: Double
}

struct WWDCSession {
    let id: String
    let title: String
    let year: Int
    let transcript: String?
}

struct AppleDocumentation {
    let title: String
    let url: String
    let content: String
}