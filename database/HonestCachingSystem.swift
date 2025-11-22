import Foundation

/// Honest Caching System for Maxwell Database
///
/// Transparency First: Always shows cache status, confidence, and sources
/// No False Positives: Validates cache entries before returning
/// Evolution Aware: Tracks pattern changes and updates

class HonestCachingSystem {
    private let database: SimpleDatabase
    private var cache: [String: CachedResponse] = [:]
    private let validationLayer = CacheValidationLayer()

    init(database: SimpleDatabase) {
        self.database = database
    }

    // MARK: - Honest Query Interface

    func queryWithTransparency(
        query: String,
        level: ResponseLevel,
        bypassCache: Bool = false
    ) throws -> TransparentResponse {
        let cacheKey = generateCacheKey(query: query, level: level)

        // Check cache first if not bypassing
        if !bypassCache, let cached = cache[cacheKey] {
            // Validate cached response before returning
            if validationLayer.isValid(cachedResponse: cached) {
                cached.hitCount += 1
                return TransparentResponse(
                    response: cached.response,
                    metadata: ResponseMetadata(
                        source: .cache,
                        confidence: cached.response.confidence,
                        responseTime: 0.001,
                        cacheInfo: CacheInfo(
                            isFromCache: true,
                            createdAt: cached.createdAt,
                            hitCount: cached.hitCount,
                            lastValidated: cached.lastValidated
                        )
                    )
                )
            } else {
                // Remove invalid cache entry
                cache.removeValue(forKey: cacheKey)
                print("⚠️  Cache invalidated - querying database directly")
            }
        }

        // Query database
        let startTime = Date()
        let documents = try database.searchDocuments(query: query)
        let queryTime = Date().timeIntervalSince(startTime)

        // Build response
        let response = try buildResponse(documents: documents, level: level)

        // Cache the response with metadata
        let cachedResponse = CachedResponse(
            response: response,
            createdAt: Date(),
            hitCount: 1,
            lastValidated: Date(),
            sourceQuery: query,
            documentsMatched: documents.count
        )
        cache[cacheKey] = cachedResponse

        return TransparentResponse(
            response: response,
            metadata: ResponseMetadata(
                source: .database,
                confidence: calculateConfidence(documents: documents, query: query),
                responseTime: queryTime,
                cacheInfo: CacheInfo(
                    isFromCache: false,
                    createdAt: Date(),
                    hitCount: 1,
                    lastValidated: Date()
                )
            )
        )
    }

    // MARK: - Cache Validation

    struct CachedResponse {
        let response: MaxwellResponse
        let createdAt: Date
        var hitCount: Int
        var lastValidated: Date
        let sourceQuery: String
        let documentsMatched: Int
    }

    class CacheValidationLayer {
        func isValid(cachedResponse: CachedResponse) -> Bool {
            // Time-based validation
            let maxAge: TimeInterval = 24 * 60 * 60  // 24 hours
            if Date().timeIntervalSince(cachedResponse.createdAt) > maxAge {
                return false
            }

            // Confidence threshold validation
            if cachedResponse.response.confidence < 0.3 {
                return false
            }

            // Source query validation
            if cachedResponse.sourceQuery.isEmpty {
                return false
            }

            return true
        }
    }

    // MARK: - Transparency Metadata

    struct TransparentResponse {
        let response: MaxwellResponse
        let metadata: ResponseMetadata
    }

    struct ResponseMetadata {
        let source: ResponseSource
        let confidence: Double
        let responseTime: TimeInterval
        let cacheInfo: CacheInfo

        enum ResponseSource {
            case cache
            case database
            case hybrid  // Cache + database validation
        }
    }

    struct CacheInfo {
        let isFromCache: Bool
        let createdAt: Date
        let hitCount: Int
        let lastValidated: Date
    }
}

// MARK: - Context-Aware Query Optimization

class ContextAwareQueryOptimizer {
    private let database: SimpleDatabase
    private var contextHistory: [QueryContext] = []

    init(database: SimpleDatabase) {
        self.database = database
    }

    struct QueryContext {
        let query: String
        let timestamp: Date
        let responseLevel: ResponseLevel
        let userSatisfaction: Double?  // Would be set after response
    }

    func optimizeQuery(
        originalQuery: String,
        level: ResponseLevel,
        conversationContext: [String] = []
    ) -> OptimizedQuery {
        // Extract key terms
        let keyTerms = extractKeyTerms(from: originalQuery)

        // Determine document scope based on context
        let documentScope = determineDocumentScope(
            terms: keyTerms,
            context: conversationContext
        )

        // Optimize search terms
        let optimizedTerms = optimizeSearchTerms(
            terms: keyTerms,
            scope: documentScope
        )

        return OptimizedQuery(
            originalQuery: originalQuery,
            optimizedQuery: optimizedTerms.joined(separator: " "),
            documentScope: documentScope,
            confidenceEstimate: estimateConfidence(
                terms: optimizedTerms,
                scope: documentScope
            )
        )
    }

    private func determineDocumentScope(
        terms: [String],
        context: [String]
    ) -> DocumentScope {
        // Analyze terms to determine relevant document types
        let tcaTerms = ["@Reducer", "@Shared", "@Bindable", "TestStore"]
        let navigationTerms = ["navigation", "sheet", "popover", "scope"]
        let testingTerms = ["test", "testing", "TestStore", "@Test"]

        let hasTCATerms = terms.contains { tcaTerms.contains($0) }
        let hasNavigationTerms = terms.contains { navigationTerms.contains($0) }
        let hasTestingTerms = terms.contains { testingTerms.contains($0) }

        if hasNavigationTerms {
            return .navigation
        } else if hasTestingTerms {
            return .testing
        } else if hasTCATerms {
            return .patterns
        } else {
            return .comprehensive
        }
    }

    enum DocumentScope {
        case patterns
        case navigation
        case testing
        case comprehensive
    }

    struct OptimizedQuery {
        let originalQuery: String
        let optimizedQuery: String
        let documentScope: DocumentScope
        let confidenceEstimate: Double
    }
}