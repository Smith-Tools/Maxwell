import Foundation

/// Progressive Response System for Maxwell Database
///
/// Provides different levels of detail based on agent needs:
/// Level 1: Summary (quick gist) - ~200 tokens
/// Level 2: Pattern (core structure) - ~800 tokens
/// Level 3: Example (full implementation) - ~2,000 tokens
/// Level 4: Full Context (comprehensive) - ~5,000+ tokens

enum ResponseLevel {
    case summary        // Quick gist for high-level decisions
    case pattern        // Core pattern structure
    case example        // Complete implementation
    case fullContext    // Comprehensive with related patterns
}

struct MaxwellResponse {
    let level: ResponseLevel
    let title: String
    let gist: String
    let pattern: String?
    let example: String?
    let relatedPatterns: [String]
    let confidence: Double
    let sources: [String]  // Document IDs and sections
    let nextLevelAvailable: Bool
}

class ProgressiveResponseSystem {
    private let database: SimpleDatabase

    init(database: SimpleDatabase) {
        self.database = database
    }

    func query(query: String, level: ResponseLevel) throws -> MaxwellResponse {
        // First, search for relevant content
        let documents = try database.searchDocuments(query: query)

        guard !documents.isEmpty else {
            throw MaxwellError.noResultsFound
        }

        // Determine confidence based on match quality
        let confidence = calculateConfidence(documents: documents, query: query)

        // Build progressive response
        switch level {
        case .summary:
            return buildSummaryResponse(documents: documents, confidence: confidence)
        case .pattern:
            return buildPatternResponse(documents: documents, confidence: confidence)
        case .example:
            return buildExampleResponse(documents: documents, confidence: confidence)
        case .fullContext:
            return buildFullContextResponse(documents: documents, confidence: confidence)
        }
    }

    private func buildSummaryResponse(documents: [Document], confidence: Double) -> MaxwellResponse {
        // Extract key information for quick gist
        let gist = extractGist(from: documents)

        return MaxwellResponse(
            level: .summary,
            title: "Quick Summary",
            gist: gist,
            pattern: nil,
            example: nil,
            relatedPatterns: [],
            confidence: confidence,
            sources: documents.map { "\($0.id):\($0.category)" },
            nextLevelAvailable: true
        )
    }

    private func buildPatternResponse(documents: [Document], confidence: Double) -> MaxwellResponse {
        // Extract core pattern structure
        let pattern = extractPattern(from: documents)

        return MaxwellResponse(
            level: .pattern,
            title: "Core Pattern Structure",
            gist: "",
            pattern: pattern,
            example: nil,
            relatedPatterns: findRelatedPatterns(for: documents),
            confidence: confidence,
            sources: documents.map { "\($0.id):\($0.category)" },
            nextLevelAvailable: true
        )
    }

    // MARK: - Honesty & Validation System

    private func calculateConfidence(documents: [Document], query: String) -> Double {
        var score = 0.0
        let queryTerms = query.lowercased().components(separatedBy: .whitespaces)

        for document in documents {
            let content = document.content.lowercased()

            // Exact matches get higher score
            for term in queryTerms {
                if content.contains(term) {
                    score += 1.0

                    // Bonus for exact phrase matches
                    if content.contains(query.lowercased()) {
                        score += 2.0
                    }

                    // Bonus for title matches
                    if document.title.lowercased().contains(term) {
                        score += 1.5
                    }
                }
            }

            // Source credibility scoring
            if document.category.contains("tca") {
                score += 0.5  // TCA docs are authoritative
            }
            if document.enforcementLevel == "critical" {
                score += 0.3  // Critical enforcement is more reliable
            }
        }

        // Normalize to 0-1 range
        return min(score / 10.0, 1.0)
    }

    // MARK: - Caching with Transparency

    private var cache: [String: MaxwellResponse] = [:]
    private var cacheStats: [String: CacheStats] = [:]

    struct CacheStats {
        let createdAt: Date
        let hitCount: Int
        let lastUpdated: Date
        let sourceQuery: String
    }

    func cachedResponse(for query: String, level: ResponseLevel) -> MaxwellResponse? {
        let key = "\(query):\(level)"

        if let response = cache[key] {
            // Update cache stats
            cacheStats[key]?.hitCount += 1
            return response
        }

        return nil
    }

    func cacheResponse(_ response: MaxwellResponse, for query: String) {
        let key = "\(query):\(level)"
        cache[key] = response

        // Record cache metadata for transparency
        cacheStats[key] = CacheStats(
            createdAt: Date(),
            hitCount: 1,
            lastUpdated: Date(),
            sourceQuery: query
        )
    }

    // MARK: - Cache Honesty System

    func getCacheInfo() -> CacheInfo {
        return CacheInfo(
            totalCached: cache.count,
            averageHitRate: calculateAverageHitRate(),
            oldestCache: cache.values.map { Date() }.min(),
            transparent: true  // Always show this to agents
        )
    }

    struct CacheInfo {
        let totalCached: Int
        let averageHitRate: Double
        let oldestCache: Date?
        let transparent: Bool
    }
}

// MARK: - Error Handling

enum MaxwellError: Error {
    case noResultsFound
    case lowConfidence(Double)
    case cacheCorrupted

    var localizedDescription: String {
        switch self {
        case .noResultsFound:
            return "No matching documents found in Maxwell database"
        case .lowConfidence(let confidence):
            return "Low confidence match (\(String(format: "%.1f", confidence * 100))%). Consider refining query."
        case .cacheCorrupted:
            return "Cache corrupted - bypassing and querying database directly"
        }
    }
}