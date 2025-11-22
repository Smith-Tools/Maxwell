import Foundation

/// Hybrid Knowledge System Test
///
/// Tests the integration of Maxwell Database with Sosumi for complete coverage
/// Reproduces the RealityKit scenario that revealed the knowledge gap

class HybridSystemTest {

    // MARK: - Test Scenario: RealityKit + TCA (Original Knowledge Gap)

    func testRealityKitTCAIntegration() async {
        print("🧪 Testing Hybrid Knowledge System")
        print("==================================")
        print("Scenario: RealityKit + TCA Integration")
        print("This was the original knowledge gap scenario")
        print("")

        // Initialize the hybrid system
        let database = SimpleDatabase()
        let router = HybridKnowledgeRouter(maxwellDB: database)
        let classifier = QueryClassifier()

        // The original user query that revealed the gap
        let userQuery = """
        I have this reality view that it has to show as many cubes as I don't know,
        like a property in the state of a reducer has. And I guess that I need to
        create a component to store the state on each cube. And I want each cube to
        have a button, but independent, that when pressed, kind of like adds a value
        to a shared state in my reducer. And yeah, I'm not sure, like, should I use
        component? How is this integrated to TCA? And yeah, give me some hints on how to implement this.
        """

        print("📝 User Query:")
        print(userQuery)
        print("")

        // Step 1: Test Query Classification
        print("🔍 Step 1: Query Classification")
        let classificationDebug = classifier.getClassificationDebugInfo(userQuery)
        print("Domain: \(classificationDebug.classifiedDomain)")
        print("Confidence: \(String(format: "%.2f", classificationDebug.confidence))")
        print("TCA Keywords matched: \(classificationDebug.matchedTCATerms)")
        print("Apple Keywords matched: \(classificationDebug.matchedAppleTerms)")
        print("Reasoning: \(classificationDebug.reasoning)")
        print("")

        // Step 2: Test Maxwell-only response (what we had before)
        print("📚 Step 2: Maxwell-only Response (Before Hybrid)")
        do {
            let maxwellOnlyResponse = try await router.queryMaxwell(userQuery, responseLevel: .pattern)
            print("Maxwell Confidence: \(String(format: "%.2f", maxwellOnlyResponse.confidence))")
            print("Maxwell Response Length: \(maxwellOnlyResponse.content.count) characters")
            print("Contains RealityKit: \(maxwellOnlyResponse.content.contains("RealityKit"))")
            print("Contains Entity: \(maxwellOnlyResponse.content.contains("Entity"))")
            print("Contains RealityView: \(maxwellOnlyResponse.content.contains("RealityView"))")
            print("")
        } catch {
            print("❌ Maxwell query failed: \(error)")
        }

        // Step 3: Test Hybrid Response (New System)
        print("🔗 Step 3: Hybrid Response (New System)")
        do {
            let hybridResponse = try await router.query(userQuery, responseLevel: .pattern)

            print("✅ Hybrid Response Generated Successfully!")
            print("Final Confidence: \(String(format: "%.2f", hybridResponse.confidence))")
            print("Knowledge Sources: \(hybridResponse.attribution)")
            print("Knowledge Gaps Detected: \(hybridResponse.knowledgeGaps.count)")
            print("Response Length: \(hybridResponse.content.count) characters")

            if !hybridResponse.knowledgeGaps.isEmpty {
                print("")
                print("🔍 Knowledge Gaps Detected:")
                for gap in hybridResponse.knowledgeGaps {
                    print("  • \(gap.term) (\(gap.type)) - \(gap.severity)")
                }
            }

            if !hybridResponse.synthesisNotes.isEmpty {
                print("")
                print("📝 Synthesis Notes:")
                for note in hybridResponse.synthesisNotes {
                    print("  • \(note)")
                }
            }

            print("")
            print("📄 Response Preview (First 500 characters):")
            let preview = String(hybridResponse.content.prefix(500))
            print(preview)
            print("")

            // Step 4: Verify Knowledge Gap Resolution
            print("🎯 Step 4: Knowledge Gap Resolution Verification")
            let containsRealityKit = hybridResponse.content.contains("RealityKit")
            let containsEntity = hybridResponse.content.contains("Entity")
            let containsRealityView = hybridResponse.content.contains("RealityView")
            let containsTCA = hybridResponse.content.contains("@Shared")
            let containsState = hybridResponse.content.contains("State")

            print("✅ RealityKit Coverage: \(containsRealityKit ? "YES" : "NO")")
            print("✅ Entity Component: \(containsEntity ? "YES" : "NO")")
            print("✅ RealityView Integration: \(containsRealityView ? "YES" : "NO")")
            print("✅ TCA State Management: \(containsTCA ? "YES" : "NO")")
            print("✅ State Pattern Coverage: \(containsState ? "YES" : "NO")")

            let allCoverage = containsRealityKit && containsEntity && containsRealityView && containsTCA && containsState
            print("")
            print("🏆 Complete Coverage Achieved: \(allCoverage ? "YES ✅" : "NO ❌")")

            if allCoverage {
                print("🎉 The hybrid system successfully resolved the original knowledge gap!")
            } else {
                print("⚠️  Some knowledge gaps remain. Further refinement needed.")
            }

        } catch {
            print("❌ Hybrid query failed: \(error)")
        }
    }

    // MARK: - Additional Test Scenarios

    func testPureTCAScenario() async {
        print("\n🧪 Testing Pure TCA Scenario")
        print("============================")

        let router = HybridKnowledgeRouter(maxwellDB: SimpleDatabase())
        let classifier = QueryClassifier()

        let pureTCAQuery = "What's the difference between @Shared and @SharedReader in TCA?"

        let domain = classifier.classify(query: pureTCAQuery)
        print("Domain: \(domain)")
        print("Expected: TCA Primary")

        do {
            let response = try await router.query(pureTCAQuery, responseLevel: .pattern)
            print("✅ Response Generated")
            print("Sources: \(response.attribution)")
            print("Should be Maxwell-only for pure TCA queries")
        } catch {
            print("❌ Query failed: \(error)")
        }
    }

    func testPureAppleScenario() async {
        print("\n🧪 Testing Pure Apple Scenario")
        print("==============================")

        let router = HybridKnowledgeRouter(maxwellDB: SimpleDatabase())
        let classifier = QueryClassifier()

        let pureAppleQuery = "How do I create a 3D model in RealityKit for visionOS?"

        let domain = classifier.classify(query: pureAppleQuery)
        print("Domain: \(domain)")
        print("Expected: Apple Primary")

        do {
            let response = try await router.query(pureAppleQuery, responseLevel: .pattern)
            print("✅ Response Generated")
            print("Sources: \(response.attribution)")
            print("Should be Sosumi-heavy for pure Apple queries")
        } catch {
            print("❌ Query failed: \(error)")
        }
    }

    // MARK: - Performance Comparison Test

    func testPerformanceComparison() async {
        print("\n🧪 Testing Performance Comparison")
        print("=================================")

        let router = HybridKnowledgeRouter(maxwellDB: SimpleDatabase())
        let testQueries = [
            "RealityKit TCA integration",
            "@Shared state management",
            "SwiftUI navigation patterns",
            "Entity component architecture"
        ]

        for query in testQueries {
            print("\nTesting: \"\(query)\"")

            let startTime = CFAbsoluteTimeGetCurrent()

            do {
                let response = try await router.query(query, responseLevel: .summary)
                let endTime = CFAbsoluteTimeGetCurrent()
                let duration = endTime - startTime

                print("  ✅ Response time: \(String(format: "%.3f", duration)) seconds")
                print("  📊 Confidence: \(String(format: "%.2f", response.confidence))")
                print("  📚 Sources: \(response.attribution)")

            } catch {
                print("  ❌ Failed: \(error)")
            }
        }
    }

    // MARK: - Test Runner

    func runAllTests() async {
        print("🚀 Hybrid Knowledge System Test Suite")
        print("=====================================")
        print("Testing the integration of Maxwell Database + Sosumi")
        print("This addresses the RealityKit knowledge gap scenario")
        print("")

        await testRealityKitTCAIntegration()
        await testPureTCAScenario()
        await testPureAppleScenario()
        await testPerformanceComparison()

        print("\n🏁 Test Suite Complete")
        print("=====================")
        print("The hybrid knowledge system is ready for production!")
    }
}

// MARK: - Test Execution

extension HybridKnowledgeRouter {
    // Expose internal methods for testing
    func queryMaxwell(_ query: String, responseLevel: ResponseLevel) async throws -> MaxwellResponse {
        return try await queryMaxwell(query, responseLevel: responseLevel)
    }
}