import Foundation
import ArgumentParser
import MaxwellDatabase

@main
struct Maxwell: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "maxwell",
        abstract: "Maxwell Knowledge Base CLI - Query framework patterns and integrations",
        subcommands: [
            Search.self,
            Pattern.self,
            Domain.self,
            Init.self,
            MigrateCmd.self
        ]
    )
}

// MARK: - Search Command

struct Search: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Search the Maxwell knowledge base"
    )

    @Argument(help: "Search query")
    var query: String

    @Option(name: .shortAndLong, help: "Filter by domain (TCA, SharePlay, RealityKit, etc.)")
    var domain: String?

    @Option(name: .shortAndLong, help: "Maximum number of results")
    var limit: Int = 10

    func run() async throws {
        let dbPath = try getDatabasePath()
        let database = try SimpleDatabase(databasePath: dbPath)

        let results = try database.searchDocuments(query: query)
        let filtered = domain != nil
            ? results.filter { $0.category.lowercased().contains(domain!.lowercased()) }
            : results
        let limited = Array(filtered.prefix(limit))

        if results.isEmpty {
            print("📭 No results found for: \(query)")
            return
        }

        print("# Search Results: \(query)\n")
        for (index, result) in limited.enumerated() {
            print("\(index + 1). **\(result.title)**")
            print("   Category: \(result.category) | Type: \(result.documentType)")
            print("   Path: \(result.path)\n")
        }
    }
}

// MARK: - Pattern Command

struct Pattern: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Search patterns by name or domain"
    )

    @Argument(help: "Pattern name to search for")
    var name: String

    func run() async throws {
        let dbPath = try getDatabasePath()
        let database = try SimpleDatabase(databasePath: dbPath)

        let patterns = try database.searchPatterns(query: name)

        if patterns.isEmpty {
            print("📭 No patterns found matching: \(name)")
            return
        }

        print("# Patterns: \(name)\n")
        for (index, pattern) in patterns.enumerated() {
            print("\(index + 1). **\(pattern.name)**")
            print("   Domain: \(pattern.domain)")
            print("   Problem: \(pattern.problem.prefix(100))...")
            if !pattern.notes.isEmpty {
                print("   Notes: \(pattern.notes)")
            }
            print()
        }
    }
}

// MARK: - Domain Command

struct Domain: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "List all patterns in a domain"
    )

    @Argument(help: "Domain name (TCA, SharePlay, RealityKit)")
    var name: String

    func run() async throws {
        let dbPath = try getDatabasePath()
        let database = try SimpleDatabase(databasePath: dbPath)

        let patterns = try database.getPatternsByDomain(name)

        if patterns.isEmpty {
            print("📭 No patterns found for domain: \(name)")
            return
        }

        print("# \(name) Patterns (\(patterns.count) total)\n")
        for (index, pattern) in patterns.enumerated() {
            print("\(index + 1). \(pattern.name)")
        }
    }
}

// MARK: - Init Command

struct Init: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Initialize the Maxwell database"
    )

    func run() async throws {
        let dbPath = try getDatabasePath()
        let database = try SimpleDatabase(databasePath: dbPath)
        print("✅ Maxwell database initialized at: \(dbPath)")
    }
}

// MARK: - Migrate Command

struct MigrateCmd: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "migrate",
        abstract: "Migrate markdown files into the Maxwell database"
    )

    @Argument(help: "Path to skills directory containing markdown files")
    var source: String

    func run() async throws {
        let dbPath = try getDatabasePath()
        let database = try SimpleDatabase(databasePath: dbPath)

        let migration = PatternMigration(database: database)
        try migration.migrateFromDirectory(source)
    }
}

// MARK: - Migration Support

struct PatternMigration {
    let database: SimpleDatabase

    func migrateFromDirectory(_ dirPath: String) throws {
        print("📚 Starting migration from: \(dirPath)")

        let fileManager = FileManager.default
        let resourceKeys: [URLResourceKey] = [.nameKey, .isDirectoryKey, .contentModificationDateKey]

        guard let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: dirPath),
            includingPropertiesForKeys: resourceKeys,
            options: [.skipsHiddenFiles],
            errorHandler: { _, error in
                print("❌ Error: \(error)")
                return true
            }
        ) else {
            throw MigrationError.directoryNotFound
        }

        var processedCount = 0
        var skippedCount = 0

        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension == "md" else { continue }

            do {
                let content = try String(contentsOf: fileURL, encoding: .utf8)
                let (title, domain, _) = parseMarkdown(content, path: fileURL.path)

                let truncatedContent = String(content.prefix(5000))
                try database.insertDocument(
                    title: title,
                    content: truncatedContent,
                    path: fileURL.path,
                    documentType: "technical",
                    category: domain,
                    subcategory: extractSubcategory(from: fileURL.path) ?? "",
                    role: "pattern",
                    enforcementLevel: "recommended",
                    tags: extractTags(from: fileURL.path),
                    fileSize: content.count,
                    lineCount: content.components(separatedBy: "\n").count
                )

                processedCount += 1
                if processedCount % 10 == 0 {
                    print("  ✓ Processed \(processedCount) files...")
                }
            } catch {
                skippedCount += 1
            }
        }

        print("\n✅ Migration complete!")
        print("   Processed: \(processedCount) files")
        print("   Skipped: \(skippedCount) files")
    }

    private func parseMarkdown(_ content: String, path: String) -> (title: String, domain: String, body: String) {
        let lines = content.components(separatedBy: .newlines)
        var title = extractPathBasedTitle(path)

        for line in lines {
            if line.hasPrefix("# ") {
                title = String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                break
            }
        }

        let domain = extractDomain(from: path)
        return (title, domain, content)
    }

    private func extractDomain(from path: String) -> String {
        let components = path.components(separatedBy: "/")
        if let index = components.firstIndex(where: { $0.contains("skill-") }) {
            let skillName = components[index]
            if skillName.contains("tca") { return "TCA" }
            if skillName.contains("shareplay") { return "SharePlay" }
            if skillName.contains("pointfree") { return "Point-Free" }
            if skillName.contains("realitykit") { return "RealityKit" }
            if skillName.contains("architectural") { return "Architecture" }
        }
        return "General"
    }

    private func extractSubcategory(from path: String) -> String? {
        let components = path.components(separatedBy: "/")
        let keywords = ["guides", "examples", "patterns", "decision-trees", "routing", "integration", "validation"]
        for component in components {
            if keywords.contains(component.lowercased()) {
                return component.lowercased()
            }
        }
        return nil
    }

    private func extractTags(from path: String) -> [String] {
        var tags: [String] = []
        let filename = (path as NSString).lastPathComponent

        if path.contains("tca") { tags.append("TCA") }
        if path.contains("shareplay") { tags.append("SharePlay") }
        if path.contains("pointfree") { tags.append("Point-Free") }
        if path.contains("realitykit") { tags.append("RealityKit") }

        if filename.contains("PATTERN") { tags.append("pattern") }
        if filename.contains("INTEGRATION") { tags.append("integration") }
        if filename.contains("DISCOVERY") { tags.append("discovery") }
        if filename.contains("ANTI") { tags.append("anti-pattern") }
        if filename.contains("GUIDE") || path.contains("guides") { tags.append("guide") }
        if filename.contains("EXAMPLE") || path.contains("examples") { tags.append("example") }

        return Array(Set(tags))
    }

    private func extractPathBasedTitle(_ path: String) -> String {
        var filename = (path as NSString).lastPathComponent
        if filename.hasSuffix(".md") {
            filename = String(filename.dropLast(3))
        }
        filename = filename.replacingOccurrences(of: "-", with: " ")
        filename = filename.replacingOccurrences(of: "_", with: " ")
        return filename
    }
}

enum MigrationError: Error {
    case directoryNotFound
    case failedToParseFile(String)
}

// MARK: - Helper Functions

func getDatabasePath() throws -> String {
    let home = FileManager.default.homeDirectoryForCurrentUser
    let resourceDir = home.appendingPathComponent(".claude/resources/databases")

    try FileManager.default.createDirectory(at: resourceDir, withIntermediateDirectories: true)

    return resourceDir.appendingPathComponent("maxwell.db").path
}
