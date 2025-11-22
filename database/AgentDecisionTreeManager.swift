import Foundation

/// Agent Decision Tree Manager
///
/// Guides agent choices through structured decision trees
/// Tracks decision quality and evolves based on outcomes
/// Provides transparent reasoning for all recommendations

class AgentDecisionTreeManager {
    private let database: SimpleDatabase
    private var decisionTrees: [DecisionTree] = []
    private let performanceTracker = DecisionPerformanceTracker()

    init(database: SimpleDatabase) {
        self.database = database
        initializeCoreDecisionTrees()
    }

    // MARK: - Core Decision Trees

    private func initializeCoreDecisionTrees() {
        // Tree 1: State Management Strategy
        decisionTrees.append(DecisionTree(
            id: "state-management",
            name: "State Management Strategy",
            rootNode: DecisionNode(
                id: "state-root",
                question: "What type of state are you managing?",
                context: .architecture,
                options: [
                    DecisionOption(
                        id: "user-auth",
                        description: "User authentication state",
                        outcome: .recommendation(pattern: "@Shared with single owner", reasoning: "Authentication is shared across app, needs single owner pattern"),
                        confidence: 0.95,
                        examples: ["AuthFeature", "UserProfile", "SessionManagement"]
                    ),
                    DecisionOption(
                        id: "feature-local",
                        description: "Feature-specific state",
                        outcome: .recommendation(pattern: "Local @ObservableState", reasoning: "Only this feature needs this state"),
                        confidence: 0.90,
                        examples: ["CounterFeature", "SettingsToggle", "FormState"]
                    ),
                    DecisionOption(
                        id: "shared-feature",
                        description: "Shared across multiple features",
                        outcome: .recommendation(pattern: "@Shared + @SharedReader", reasoning: "Multiple features need access with single writer"),
                        confidence: 0.85,
                        examples: ["ShoppingCart", "NetworkStatus", "UserPreferences"]
                    ),
                    DecisionOption(
                        id: "external-service",
                        description: "External API or service",
                        outcome: .recommendation(pattern: "@DependencyClient", reasoning: "External services should be dependencies"),
                        confidence: 0.98,
                        examples: ["APIClient", "DatabaseClient", "NotificationService"]
                    )
                ]
            )
        ))

        // Tree 2: Navigation Pattern Selection
        decisionTrees.append(DecisionTree(
            id: "navigation-patterns",
            name: "Navigation Pattern Selection",
            rootNode: DecisionNode(
                id: "nav-root",
                question: "What type of navigation do you need?",
                context: .navigation,
                options: [
                    DecisionOption(
                        id: "optional-child",
                        description: "Optional child feature (modal, sheet, popover)",
                        outcome: .recommendation(pattern: ".sheet(item:) + .scope()", reasoning: "Modern TCA uses optional state with sheet presentation"),
                        confidence: 0.95,
                        examples: ["DetailView", "FormSheet", "ConfirmationDialog"]
                    ),
                    DecisionOption(
                        id: "multi-destination",
                        description: "Multiple navigation destinations",
                        outcome: .recommendation(pattern: "NavigationStack + enum destinations", reasoning: "Type-safe multi-destination navigation"),
                        confidence: 0.90,
                        examples: ["TabNavigation", "WizardFlow", "DeepLinking"]
                    ),
                    DecisionOption(
                        id: "persistent-state",
                        description: "Navigation needs to persist across app lifecycle",
                        outcome: .recommendation(pattern: "PathCodable + deep linking", reasoning: "Persistent navigation needs codable paths"),
                        confidence: 0.85,
                        examples: ["ArticleReader", "VideoPlayer", "ShoppingFlow"]
                    )
                ]
            )
        ))

        // Tree 3: Feature Extraction Decisions
        decisionTrees.append(DecisionTree(
            id: "feature-extraction",
            name: "Feature Extraction Decision",
            rootNode: DecisionNode(
                id: "extraction-root",
                question: "Should you extract a new child feature?",
                context: .architecture,
                options: [
                    DecisionOption(
                        id: "extract-large",
                        description: "Reducer >200 lines",
                        outcome: .recommendation(pattern: "Extract child feature", reasoning: "Large reducers are hard to maintain and test"),
                        confidence: 0.95,
                        examples: ["MonolithicReducer → MultipleChildFeatures"]
                    ),
                    DecisionOption(
                        id: "extract-responsibility",
                        description: "Multiple unrelated responsibilities",
                        outcome: .recommendation(pattern: "Extract by responsibility", reasoning: "Single responsibility principle for maintainability"),
                        confidence: 0.90,
                        examples: ["UserAuth → AuthFeature + ProfileFeature"]
                    ),
                    DecisionOption(
                        id: "extract-reusable",
                        description: "Reused in multiple places",
                        outcome: .recommendation(pattern: "Extract reusable component", reasoning: "DRY principle and maintainability"),
                        confidence: 0.85,
                        examples: ["DatePickerFeature", "ImageUploader", "SearchBar"]
                    ),
                    DecisionOption(
                        id: "keep-together",
                        description: < 100 lines, single responsibility",
                        outcome: .recommendation(pattern: "Keep in current feature", reasoning: "No clear benefit to extraction"),
                        confidence: 0.80,
                        examples: ["SimpleCounterFeature", "ToggleSwitchFeature"]
                    )
                ]
            )
        ))
    }

    // MARK: - Agent Interface

    func queryDecisionTree(
        treeId: String,
        context: AgentContext,
        currentPath: [String] = []
    ) throws -> DecisionResult {
        guard let tree = decisionTrees.first(where: { $0.id == treeId }) else {
            throw DecisionError.treeNotFound(treeId)
        }

        // Navigate to current node or start at root
        let currentNode = currentPath.isEmpty ?
            tree.rootNode :
            try navigateToNode(tree: tree, path: currentPath)

        // Analyze current node with agent context
        let analyzedOptions = analyzeOptions(
            options: currentNode.options,
            context: context
        )

        // Select best option
        let bestOption = selectBestOption(
            from: analyzedOptions,
            context: context
        )

        // Track decision for learning
        performanceTracker.recordDecision(
            treeId: treeId,
            context: context,
            selectedOption: bestOption,
            allOptions: analyzedOptions
        )

        return DecisionResult(
            tree: tree,
            currentNode: currentNode,
            selectedOption: bestOption,
            alternativeOptions: analyzedOptions.filter { $0.id != bestOption.id },
            confidence: bestOption.confidence,
            reasoning: bestOption.outcome.reasoning,
            nextSteps: bestOption.outcome.nextSteps
        )
    }

    // MARK: - Decision Analysis

    private func analyzeOptions(
        options: [DecisionOption],
        context: AgentContext
    ) -> [AnalyzedOption] {
        return options.map { option in
            var adjustedConfidence = option.confidence

            // Adjust confidence based on context
            if context.projectType == .prototype {
                // Lower confidence threshold for prototypes
                adjustedConfidence *= 0.8
            } else if context.projectType == .production {
                // Higher confidence required for production
                adjustedConfidence *= 1.1
            }

            // Check for anti-patterns in context
            if let antiPatterns = detectAntiPatterns(context: context) {
                for antiPattern in antiPatterns {
                    if option.description.contains(antiPattern) {
                        adjustedConfidence *= 0.5  // Penalize if matches anti-pattern
                    }
                }
            }

            return AnalyzedOption(
                option: option,
                adjustedConfidence: adjustedConfidence,
                contextualFactors: getContextualFactors(for: option, context: context),
                warnings: generateWarnings(for: option, context: context)
            )
        }.sorted { $0.adjustedConfidence > $1.adjustedConfidence }
    }

    private func selectBestOption(
        from analyzedOptions: [AnalyzedOption],
        context: AgentContext
    ) -> AnalyzedOption {
        // Select highest confidence option
        let bestOption = analyzedOptions.first!

        // Check if confidence meets threshold
        let threshold = context.projectType == .production ? 0.8 : 0.6

        if bestOption.adjustedConfidence < threshold {
            // Add warning about low confidence
            return AnalyzedOption(
                option: bestOption.option,
                adjustedConfidence: bestOption.adjustedConfidence,
                contextualFactors: bestOption.contextualFactors,
                warnings: bestOption.warnings + ["Low confidence: \(bestOption.adjustedConfidence)"]
            )
        }

        return bestOption
    }

    // MARK: - Performance Tracking

    func getDecisionTreePerformance() -> DecisionTreePerformanceReport {
        return performanceTracker.generateReport()
    }

    func optimizeDecisionTrees() throws {
        let report = performanceTracker.generateReport()

        // Identify underperforming trees
        for treePerformance in report.treePerformances {
            if treePerformance.averageConfidence < 0.7 {
                try optimizeTree(treeId: treePerformance.treeId)
            }
        }
    }

    private func optimizeTree(treeId: String) throws {
        // Collect feedback and examples
        let feedback = performanceTracker.getFeedback(for: treeId)

        // Identify patterns in failures or low-confidence decisions
        let improvements = analyzeDecisionFeedback(feedback: feedback)

        // Apply improvements to tree structure
        for improvement in improvements {
            try applyImprovement(to: treeId, improvement: improvement)
        }
    }
}

// MARK: - Supporting Types

struct DecisionTree {
    let id: String
    let name: String
    let rootNode: DecisionNode
}

struct DecisionNode {
    let id: String
    let question: String
    let context: DecisionContext
    let options: [DecisionOption]
}

struct DecisionOption {
    let id: String
    let description: String
    let outcome: DecisionOutcome
    let confidence: Double
    let examples: [String]
}

struct DecisionOutcome {
    let pattern: String?
    let reasoning: String
    let nextSteps: [String]
}

struct AnalyzedOption {
    let option: DecisionOption
    let adjustedConfidence: Double
    let contextualFactors: [String]
    let warnings: [String]
}

struct DecisionResult {
    let tree: DecisionTree
    let currentNode: DecisionNode
    let selectedOption: AnalyzedOption
    let alternativeOptions: [AnalyzedOption]
    let confidence: Double
    let reasoning: String
    let nextSteps: [String]
}

enum DecisionContext {
    case architecture
    case navigation
    case testing
    case performance
}

struct AgentContext {
    let projectType: ProjectType
    let complexity: Complexity
    let currentCode: String
    let constraints: [String]
    let previousDecisions: [String]
}

enum ProjectType {
    case prototype
    case production
    case learning
}

enum Complexity {
    case simple
    case medium
    case complex
}

// MARK: - Performance Tracking

class DecisionPerformanceTracker {
    private var decisions: [TrackedDecision] = []

    struct TrackedDecision {
        let treeId: String
        let context: AgentContext
        let selectedOption: String
        let confidence: Double
        let timestamp: Date
        let userSatisfaction: Double?  // Would be set after user feedback
    }

    func recordDecision(
        treeId: String,
        context: AgentContext,
        selectedOption: AnalyzedOption,
        allOptions: [AnalyzedOption]
    ) {
        let decision = TrackedDecision(
            treeId: treeId,
            context: context,
            selectedOption: selectedOption.option.id,
            confidence: selectedOption.adjustedConfidence,
            timestamp: Date(),
            userSatisfaction: nil
        )
        decisions.append(decision)
    }

    func generateReport() -> DecisionTreePerformanceReport {
        // Analyze decisions by tree
        let treePerformances = Dictionary(grouping: decisions) { $0.treeId }
            .mapValues { decisions in
                let avgConfidence = decisions.map { $0.confidence }.reduce(0, +) / Double(decisions.count)
                let satisfaction = decisions.compactMap { $0.userSatisfaction }
                let avgSatisfaction = satisfaction.isEmpty ? nil : satisfaction.reduce(0, +) / Double(satisfaction.count)

                return TreePerformance(
                    treeId: decisions.first!.treeId,
                    totalDecisions: decisions.count,
                    averageConfidence: avgConfidence,
                    averageSatisfaction: avgSatisfaction
                )
            }

        return DecisionTreePerformanceReport(
            totalDecisions: decisions.count,
            treePerformances: Array(treePerformances.values),
            generatedAt: Date()
        )
    }
}

struct DecisionTreePerformanceReport {
    let totalDecisions: Int
    let treePerformances: [TreePerformance]
    let generatedAt: Date
}

struct TreePerformance {
    let treeId: String
    let totalDecisions: Int
    let averageConfidence: Double
    let averageSatisfaction: Double?
}

enum DecisionError: Error {
    case treeNotFound(String)
    case nodeNotFound(String)
    case invalidContext
}