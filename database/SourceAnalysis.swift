#!/usr/bin/env swift

import Foundation

/// Source Origin Analysis for Contradictory Patterns

struct SourceOrigin {
    let name: String
    let type: SourceType
    let authority: AuthorityLevel
    let credibility: CredibilityScore
    let specificContent: String
    let date: String

    enum SourceType {
        case officialDocumentation  // DocC from TCA repo
        case pointFreeBlog         // Point-Free articles/blogs
        case customAnalysis        // Smith/Maxwell analysis
        case communityPractice     // Community wisdom
    }

    enum AuthorityLevel {
        case canonical    // Official TCA source
        case expert       // Point-Free (creators of TCA)
        case derived      // Analysis based on canonical
        case opinion      // Community/custom practice
    }

    enum CredibilityScore: Int, CaseIterable {
        case veryHigh = 5
        case high = 4
        case medium = 3
        case low = 2
        case veryLow = 1
    }
}

class ContradictionSourceAnalyzer {

    func analyzeSources() -> [(pattern: String, sources: [SourceOrigin], contradiction: String)] {
        return [
            (
                pattern: "@Shared State Ownership",
                sources: [
                    SourceOrigin(
                        name: "TCA-SHARED-STATE.md (Current Maxwell)",
                        type: .customAnalysis,
                        authority: .derived,
                        credibility: .medium,
                        specificContent: "Both features can read/write without explicit dependency chain",
                        date: "2024-11-05"
                    ),
                    SourceOrigin(
                        name: "TCA DocC - SharingState.md",
                        type: .officialDocumentation,
                        authority: .canonical,
                        credibility: .veryHigh,
                        specificContent: "Concurrent mutations require withLock to prevent race conditions",
                        date: "2024-12-15"
                    ),
                    SourceOrigin(
                        name: "Point-Free Blog 135",
                        type: .pointFreeBlog,
                        authority: .expert,
                        credibility: .high,
                        specificContent: "No specific guidance on single owner vs multiple writers",
                        date: "2023-03-15"
                    ),
                    SourceOrigin(
                        name: "Smith CLAUDE.md",
                        type: .customAnalysis,
                        authority: .derived,
                        credibility: .medium,
                        specificContent: "Single writer, multiple readers - Only one feature should own and mutate @Shared state",
                        date: "2024-11-05"
                    )
                ],
                contradiction: "Current Maxwell allows multiple writers, Smith says single owner, TCA DocC mentions concurrent mutation safety"
            )
        ]
    }

    func rankSourcesByCredibility() -> [SourceOrigin.AuthorityLevel] {
        return [
            .canonical,    // Official TCA DocC documentation
            .expert,       // Point-Free (TCA creators)
            .derived,      // Analysis based on canonical sources
            .opinion       // Community practices and custom analysis
        ]
    }

    func generateSourceReport() {
        print("🔍 SOURCE ORIGIN ANALYSIS REPORT")
        print(String(repeating: "=", count: 60))

        let analysis = analyzeSources()

        for (patternIndex, patternAnalysis) in analysis.enumerated() {
            print("\n📋 PATTERN #\(patternIndex + 1): \(patternAnalysis.pattern)")
            print(String(repeating: "-", count: 40))

            // Sort sources by credibility (highest first)
            let sortedSources = patternAnalysis.sources.sorted {
                $0.credibility.rawValue > $1.credibility.rawValue
            }

            print("\n📊 CREDIBILITY RANKING:")
            for (index, source) in sortedSources.enumerated() {
                let credibilityEmoji = credibilityEmoji(source.credibility)
                let authorityEmoji = authorityEmoji(source.authority)
                let typeEmoji = typeEmoji(source.type)

                print("  \(index + 1). \(credibilityEmoji) \(source.name)")
                print("     \(authorityEmoji) Authority: \(source.authority)")
                print("     \(typeEmoji) Type: \(source.type)")
                print("     📅 Date: \(source.date)")
                print("     💬 Content: \"\(source.specificContent)\"")
                print(String(repeating: "·", count: 30))
            }

            print("\n🚨 CONTRADICTION:")
            print("   \(patternAnalysis.contradiction)")

            print("\n✅ RESOLUTION RECOMMENDATION:")
            let highestCredibilitySource = sortedSources.first!
            print("   🎯 PRIMARY: \(highestCredibilitySource.name) (Credibility: \(highestCredibilitySource.credibility))")

            // Check if there are multiple high-credibility sources
            let highCredibilitySources = sortedSources.filter {
                $0.credibility.rawValue >= SourceOrigin.CredibilityScore.high.rawValue
            }

            if highCredibilitySources.count > 1 {
                print("   ⚠️  MULTIPLE HIGH-CREDIBILITY SOURCES FOUND:")
                for source in highCredibilitySources {
                    print("      • \(source.name): \(source.specificContent)")
                }
                print("   💡 RECOMMENDATION: Synthesize approach that respects all high-credibility sources")
            } else {
                print("   ✅ CLEAR WINNER: Follow highest credibility source")
            }

            print("\n🎪 CONSENSUS ANALYSIS:")
            let consensus = findConsensus(sortedSources)
            print("   \(consensus.description)")
        }

        print("\n🏆 OVERALL CREDIBILITY HIERARCHY:")
        let ranking = rankSourcesByCredibility()
        for (index, authority) in ranking.enumerated() {
            let emoji = authorityEmoji(authority)
            print("  \(index + 1). \(emoji) \(authority)")
        }
    }

    private func findConsensus(_ sources: [SourceOrigin]) -> (description: String, confidence: Int) {
        let credibleSources = sources.filter { $0.credibility.rawValue >= SourceOrigin.CredibilityScore.high.rawValue }

        if credibleSources.isEmpty {
            return ("No consensus - all sources have low credibility", 0)
        }

        // Look for common themes
        let mentionsSingleOwner = credibleSources.filter {
            $0.specificContent.contains("single") ||
            $0.specificContent.contains("only one") ||
            $0.specificContent.contains("Single writer")
        }.count

        let mentionsMultipleWriters = credibleSources.filter {
            $0.specificContent.contains("both") ||
            $0.specificContent.contains("multiple") ||
            $0.specificContent.contains("concurrent")
        }.count

        if mentionsSingleOwner > mentionsMultipleWriters {
            return ("Consensus leans toward single owner pattern", mentionsSingleOwner)
        } else if mentionsMultipleWriters > mentionsSingleOwner {
            return ("Consensus leans toward concurrent access with safety", mentionsMultipleWriters)
        } else {
            return ("No clear consensus - credible sources disagree", 0)
        }
    }

    private func credibilityEmoji(_ credibility: SourceOrigin.CredibilityScore) -> String {
        switch credibility {
        case .veryHigh: return "🌟"
        case .high: return "⭐"
        case .medium: return "🟡"
        case .low: return "🟠"
        case .veryLow: return "🔴"
        }
    }

    private func authorityEmoji(_ authority: SourceOrigin.AuthorityLevel) -> String {
        switch authority {
        case .canonical: return "📜"
        case .expert: return "👨‍🏫"
        case .derived: return "🔬"
        case .opinion: return "💭"
        }
    }

    private func typeEmoji(_ type: SourceOrigin.SourceType) -> String {
        switch type {
        case .officialDocumentation: return "📖"
        case .pointFreeBlog: return "🎥"
        case .customAnalysis: return "🔍"
        case .communityPractice: return "👥"
        }
    }
}

// Run source analysis
let analyzer = ContradictionSourceAnalyzer()
analyzer.generateSourceReport()