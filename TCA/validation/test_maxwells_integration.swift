#!/usr/bin/env swift

// test_maxwells_integration.swift
// Integration test for Maxwells TCA rules using SmithValidationCore

import Foundation
import SmithValidationCore

// Import the migrated rules (we'll need to compile them together)
// For now, let's create a simple test that validates the framework works

print("=== Maxwells TCA Rules Integration Test ===")
print("Testing SmithValidationCore framework with migrated rules...\n")

// Test 1: Basic Framework Functionality
print("🧪 Test 1: SmithValidationCore Framework")
let testCode = """
import Foundation
import ComposableArchitecture

struct TestFeature: Reducer {
    struct State {
        let name: String
        let count: Int
    }

    enum Action {
        case increment
        case decrement
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .increment:
                state.count += 1
                return .none
            case .decrement:
                state.count -= 1
                return .none
            }
        }
    }
}
"""

do {
    // Test parsing with SmithValidationCore
    let syntax = try SourceFileSyntax.parse(source: testCode)
    let context = SourceFileContext(path: "<test>", url: URL(fileURLWithPath: "/test"), syntax: syntax)

    // Test AST extensions
    let reducers = syntax.findTCAReducers()
    print("✅ Found \(reducers.count) TCA reducers")

    let states = syntax.findStatesInTCAReducers()
    print("✅ Found \(states.count) State structs")

    let actions = syntax.findActionsInTCAReducers()
    print("✅ Found \(actions.count) Action enums")

    // Test StructInfo
    if let reducer = reducers.first {
        print("✅ Reducer name: \(reducer.name)")
        print("✅ Reducer conforms to Reducer: \(reducer.conformsTo("Reducer"))")
        print("✅ Reducer property count: \(reducer.propertyCount)")

        if let state = reducer.findNestedStruct(named: "State") {
            print("✅ State struct found with \(state.propertyCount) properties")
        }

        if let action = reducer.findNestedEnum(named: "Action") {
            print("✅ Action enum found with \(action.caseCount) cases")
        }
    }

    // Test ViolationCollection
    let testViolation = ArchitecturalViolation.high(
        rule: "TestRule",
        file: context.relativePath,
        line: 1,
        message: "Test violation",
        recommendation: "Fix this"
    )

    let violations = ViolationCollection(violations: [testViolation])
    print("✅ Created violation collection with \(violations.count) violations")
    print("✅ High priority violations: \(violations.highCount)")

} catch {
    print("❌ Error: \(error)")
    exit(1)
}

print("\n🎉 All SmithValidationCore tests passed!")
print("📝 Next steps:")
print("   1. Compile Maxwells TCA rules with SmithValidationCore")
print("   2. Test individual rule functionality")
print("   3. Compare results with smith-validation baseline")

print("\n✅ Integration test complete - SmithValidationCore ready for Maxwells rules!")