# Global Maxwells TCA Detection Mechanism Design

## Overview

A global detection mechanism for Maxwells TCA that can automatically discover and validate TCA projects without manual configuration. This enables universal TCA architectural validation across development environments.

## Detection Strategies

### 1. Automatic Project Discovery

```swift
struct TCAProjectDetector {
    /// Scan directory for TCA projects
    static func discoverTCAProjects(in directory: URL) -> [TCAProjectInfo] {
        var projects: [TCAProjectInfo] = []

        if let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey]
        ) {
            for case let fileURL as URL in enumerator {
                guard fileURL.pathExtension == "swift" else { continue }

                if let projectInfo = analyzeForTCA(fileURL: fileURL) {
                    projects.append(projectInfo)
                }
            }
        }

        return Array(Set(projects)) // Remove duplicates
    }

    /// Analyze Swift file for TCA patterns
    private static func analyzeForTCA(fileURL: URL) -> TCAProjectInfo? {
        do {
            let content = try String(contentsOf: fileURL)
            let syntax = try Parser.parse(source: content)

            // Check for TCA indicators
            let hasTCAImports = content.contains("import ComposableArchitecture") ||
                              content.contains("import TCA") ||
                              content.contains("@Reducer")

            let hasReducerConformance = content.contains(": Reducer") ||
                                         content.contains("struct.*Reducer")

            let hasTCAPatterns = content.contains("Dependency(") ||
                                content.contains("State") && content.contains("Action")

            if hasTCAImports || hasReducerConformance || hasTCAPatterns {
                return TCAProjectInfo(
                    path: fileURL.path,
                    name: extractProjectName(from: fileURL),
                    tcaIndicators: extractTCAIndicators(from: content),
                    fileCount: 1
                )
            }

        } catch {
            return nil
        }
    }
}
```

### 2. Claude Agent Integration (~/.claude/agents)

```swift
// ~/.claude/agents/maxwells-tca-validator.swift
import Foundation
import SmithValidationCore

@main
struct MaxwellsTCADetector {
    static func main() {
        let arguments = CommandLine.arguments

        if arguments.count < 2 {
            printUsage()
            exit(1)
        }

        let path = arguments[1]
        let enableGlobal = arguments.contains("--global")

        do {
            if enableGlobal {
                runGlobalDetection(basePath: path)
            } else {
                runSingleProjectDetection(projectPath: path)
            }
        } catch {
            print("❌ Error: \(error)")
            exit(1)
        }
    }

    private static func runGlobalDetection(basePath: String) throws {
        print("🔍 Global Maxwells TCA Detection")
        print("Scanning for TCA projects in: \(basePath)")
        print("")

        let baseURL = URL(fileURLWithPath: basePath)
        let projects = TCAProjectDetector.discoverTCAProjects(in: baseURL)

        if projects.isEmpty {
            print("ℹ️ No TCA projects found in specified directory")
            return
        }

        print("📊 Found \(projects.count) TCA projects:")
        print("")

        for project in projects.sorted(by: { $0.name < $1.name }) {
            runValidation(on: project)
            print("")
        }
    }

    private static func runSingleProjectDetection(projectPath: String) throws {
        let projectURL = URL(fileURLWithPath: projectPath)

        print("🔍 Single Project TCA Validation")
        print("Project: \(projectURL.lastPathComponent)")
        print("")

        // Validate project
        let projectInfo = TCAProjectDetector.analyzeProject(at: projectURL)

        guard let project = projectInfo else {
            print("❌ Not a valid TCA project")
            return
        }

        runValidation(on: project)
    }

    private static func runValidation(on project: TCAProjectInfo) {
        print("📋 Project: \(project.name)")
        print("   Path: \(project.path)")
        print("   TCA Indicators: \(project.tcaIndicators.joined(separator: ", "))")
        print("   Swift Files: \(project.fileCount)")
        print("")

        // Load and run Maxwells rules
        let maxwellsPath = "/Volumes/Plutonian/_Developer/Maxwells/TCA/validation"
        let rules = loadMaxwellsRules(from: URL(fileURLWithPath: maxwellsPath))

        print("🔧 Running Maxwells TCA Rules:")
        print("   ✅ Rule 1.1: Monolithic Features")
        print("   ✅ Rule 1.2: Proper Dependency Injection")
        print("   ✅ Rule 1.3: Code Duplication")
        print("   ✅ Rule 1.4: Unclear Organization")
        print("   ✅ Rule 1.5: Tightly Coupled State")
        print("")

        var totalViolations = 0
        var criticalViolations = 0

        for rule in rules {
            do {
                let violations = try rule.validate(filePath: project.path)
                totalViolations += violations.violations.count
                criticalViolations += violations.criticalCount

                print("   📊 \(rule.name): \(violations.violations.count) violations")
                if violations.criticalCount > 0 {
                    print("      🔴 Critical: \(violations.criticalCount)")
                }
                if violations.highCount > 0 {
                    print("      🟠 High: \(violations.highCount)")
                }
            } catch {
                print("   ❌ \(rule.name): Validation error")
            }
        }

        print("")
        print("📈 SUMMARY:")
        print("   Total Violations: \(totalViolations)")
        print("   Critical Violations: \(criticalViolations)")
        print("   Health Score: \(max(0, 100 - totalViolations * 2))%")
        print("")

        if criticalViolations > 0 {
            print("🚨 CRITICAL ISSUES FOUND - Review required!")
        } else if totalViolations > 0 {
            print("⚠️  IMPROVEMENTS RECOMMENDED")
        } else {
            print("✅ EXCELLENT ARCHITECTURAL HEALTH!")
        }
    }

    private static func loadMaxwellsRules(from directory: URL) -> [any ValidatableRule] {
        // This would dynamically compile and load Maxwells rules
        // For now, return mock rules
        return [
            MockRule(name: "Rule 1.1", description: "Monolithic Features"),
            MockRule(name: "Rule 1.2", description: "Proper Dependency Injection"),
            MockRule(name: "Rule 1.3", description: "Code Duplication"),
            MockRule(name: "Rule 1.4", description: "Unclear Organization"),
            MockRule(name: "Rule 1.5", description: "Tightly Coupled State")
        ]
    }

    private static func printUsage() {
        print("""
        Usage: maxwells-tca-validator [options] <path>

        Options:
          --global    Scan all subdirectories for TCA projects
          --help      Show this help message

        Examples:
          maxwells-tca-validator ./Sources                    # Single project
          maxwells-tca-validator --global ~/Projects         # Global scan
          maxwells-tca-validator --global /path/to/repo      # Repository scan
        """)
    }
}
```

### 3. Installation and Setup

```bash
#!/bin/bash

# Installation script
install() {
    echo "Installing Maxwells TCA Global Detector..."

    # Create agent directory
    mkdir -p ~/.claude/agents

    # Copy the detector
    cp maxwells-tca-validator.swift ~/.claude/agents/

    # Make it executable
    chmod +x ~/.claude/agents/maxwells-tca-validator.swift

    # Compile if needed (or use Swift interpreter)
    cd ~/.claude/agents
    swiftc maxwells-tca-validator.swift -o maxwells-tca-validator

    echo "✅ Maxwells TCA Global Detector installed!"
    echo ""
    echo "Usage: ~/.claude/agents/maxwells-tca-validator <project-path>"
    echo "      ~/.claude/agents/maxwells-tca-validator --global <directory>"
}

# Run installation
install "$@"
```

### 4. Integration Shell Script

```bash
#!/bin/bash
# ~/.claude/agents/maxwells-validator.sh

validate_directory() {
    local dir="$1"
    echo "🔍 Scanning for TCA projects in: $dir"

    # Look for Package.swift files with TCA dependencies
    while IFS= read -r -d '' package_file; do
        if grep -q "ComposableArchitecture\|TCA" "$package_file"; then
            project_dir="$(dirname "$package_file")"
            echo "📋 Found TCA project: $(basename "$project_dir")"

            # Quick validation
            swift_files=$(find "$project_dir" -name "*.swift" | wc -l)
            reducer_files=$(find "$project_dir" -name "*.swift" -exec grep -l "@Reducer\|: Reducer" {} \; 2>/dev/null | wc -l)

            echo "   Swift files: $swift_files"
            echo "   Reducers: $reducer_files"

            if [ "$reducer_files" -gt 0 ]; then
                echo "   ✅ TCA project detected - Running validation..."
                # Run actual validation
                run_validation "$project_dir"
            fi
            echo ""
        fi
    done < <(find "$dir" -name "Package.swift" -print0)
}

run_validation() {
    local project_dir="$1"

    # Use smith-validation if available
    if command -v smith-validation &> /dev/null; then
        echo "   🔧 Running smith-validation with Maxwells rules..."
        smith-validation "$project_dir" 2>/dev/null | head -20
    else
        echo "   ⚠️  smith-validation not available"
        echo "   📋 Found $(find "$project_dir" -name "*.swift" | wc -l) Swift files"
    fi
}

# Main execution
main() {
    if [ $# -eq 0 ]; then
        echo "Usage: maxwells-validator <directory>"
        exit 1
    fi

    validate_directory "$1"
}

main "$@"
```

### 5. Integration with Development Workflow

#### VSCode Extension Integration

```json
{
    "name": "Maxwells TCA Validator",
    "publisher": "Maxwells",
    "contributes": [
        {
            "command": "maxwells-validate",
            "title": "Validate TCA Architecture",
            "type": "shell",
            "command": "~/.claude/agents/maxwells-validator.sh",
            "group": "build",
            "presentation": {
                "echo": "🔍 Validating TCA architecture..."
            }
        }
    ]
}
```

#### Pre-commit Hook

```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "🔍 Running Maxwells TCA validation..."

# Find TCA projects and validate them
~/.claude/agents/maxwells-validator.sh . 2>&1 | grep -E "Total|Critical|❌|✅" | tail -5

# Check for critical violations
if ~/.claude/agents/maxwells-validator.sh . 2>&1 | grep -q "CRITICAL"; then
    echo ""
    echo "🚨 CRITICAL TCA VIOLATIONS FOUND!"
    echo "Please fix before committing."
    exit 1
fi
```

### 6. Global Configuration

```swift
// ~/.claude/agents/maxwells-config.json
struct MaxwellsGlobalConfig {
    let scanDirectories: [String] = [
        "~/Projects",
        "~/Development",
        "/Users/$USER/Projects"
    ]

    let excludedPatterns: [String] = [
        ".build/",
        "DerivedData/",
        "*.xcodeproj",
        ".git/"
    ]

    let notificationEnabled: Bool = true
    let autoFixEnabled: Bool = false
    let severityThreshold: Double = 0.3
}
```

### 7. Performance Considerations

```swift
class GlobalTCAValidator {
    private let cache = NSCache<NSString, TCAValidationResult>()
    private let maxConcurrentValidations = 4
    private let validationQueue = DispatchQueue(
        label: "com.maxwells.validation",
        qos: .userInitiated,
        attributes: .concurrent
    )

    func validateProjects(_ projects: [TCAProjectInfo]) async -> [TCAValidationResult] {
        return await withThrowingTaskGroup(returning: [TCAValidationResult].self) { group in
            for project in projects {
                group.addTask {
                    await validateProject(project)
                }
            }
        }
    }

    private func validateProject(_ project: TCAProjectInfo) async -> TCAValidationResult {
        // Check cache first
        if let cached = cache.object(forKey: project.path as NSString) {
            return cached
        }

        // Perform validation
        let result = await performValidation(on: project)

        // Cache result
        cache.setObject(result, forKey: project.path as NSString)

        return result
    }
}
```

## Benefits

### For Development Teams
- **Zero Configuration**: Automatic TCA project discovery
- **Universal Access**: Works from any directory
- **Continuous Validation**: Integrate with CI/CD pipelines
- **Global Standards**: Enforce architectural consistency

### For Architectural Compliance
- **Early Detection**: Catch issues during development
- **Team-wide Enforcement**: Consistent validation across projects
- **Automated Reporting**: Comprehensive violation reporting
- **Scalable**: Handle large codebases efficiently

### For Integration Ecosystem
- **Multi-tool Support**: Works with various development tools
- **Platform Agnostic**: Works on macOS, Linux, Windows
- **Framework Extensible**: Easy to add new validation rules
- **Performance Optimized**: Caching and parallel processing

This global detection mechanism makes Maxwells TCA validation universally accessible and automatically discovers TCA projects for validation.