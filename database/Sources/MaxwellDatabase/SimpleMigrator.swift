import Foundation

/// Simple Maxwell Database Migrator
class SimpleMigrator {
    private let database: SimpleDatabase
    private let fileManager = FileManager.default

    init(database: SimpleDatabase) {
        self.database = database
    }

    func migrateAll() throws {
        print("🚀 Starting Simple Maxwell Database Migration...")
        let startTime = Date()
        var migratedCount = 0

        migratedCount += try migrateTCADocumentation()
        migratedCount += try migrateSmithDocumentation()

        let duration = Date().timeIntervalSince(startTime)
        print("✅ Migration completed!")
        print("📊 Total documents migrated: \(migratedCount)")
        print("⏱️  Duration: \(String(format: "%.2f", duration)) seconds")
        
        // Show stats
        let stats = database.getStats()
        print("📈 Database Stats:")
        print("  Total: \(stats.total)")
        print("  Technical: \(stats.technical)")
        print("  Process: \(stats.process)")
    }

    private func migrateTCADocumentation() throws -> Int {
        print("📚 Migrating TCA Technical Documentation...")
        let tcaBasePath = "/Volumes/Plutonian/_Developer/Maxwells/TCA"
        var migratedCount = 0

        // Migrate Skill Guides
        let guidesPath = "\(tcaBasePath)/skill/guides"
        if fileManager.fileExists(atPath: guidesPath) {
            let files = try fileManager.contentsOfDirectory(atPath: guidesPath)
            let mdFiles = files.filter { $0.hasSuffix(".md") }

            for file in mdFiles {
                let filePath = "\(guidesPath)/\(file)"
                try migrateDocument(
                    path: filePath,
                    category: "tca-guides",
                    role: "developer",
                    enforcement: "STANDARD"
                )
                migratedCount += 1
                print("    ✅ \(file)")
            }
        }

        return migratedCount
    }

    private func migrateSmithDocumentation() throws -> Int {
        print("📋 Migrating Smith Process Documentation...")
        let smithBasePath = "/Volumes/Plutonian/_Developer/_deprecated/Smith"
        var migratedCount = 0

        let smithFiles = [
            ("GETTING_STARTED.md", "smith-workflow", "agent", "STANDARD")
        ]

        for (filename, category, role, enforcement) in smithFiles {
            let filePath = "\(smithBasePath)/\(filename)"
            if fileManager.fileExists(atPath: filePath) {
                try migrateDocument(
                    path: filePath,
                    category: category,
                    role: role,
                    enforcement: enforcement
                )
                migratedCount += 1
                print("    ✅ \(filename)")
            }
        }

        return migratedCount
    }

    private func migrateDocument(
        path: String,
        category: String,
        role: String,
        enforcement: String
    ) throws {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        let filename = URL(fileURLWithPath: path).lastPathComponent
        let title = (filename as NSString).deletingPathExtension.replacingOccurrences(of: "-", with: " ")

        let tags = extractTags(from: content, category: category)
        let lineCount = content.components(separatedBy: .newlines).count
        let fileSize = content.count

        let documentType = category.contains("smith") || category.contains("decision") ? "process" : "technical"

        try database.insertDocument(
            title: title,
            content: content,
            path: path,
            documentType: documentType,
            category: category,
            subcategory: nil,
            role: role,
            enforcementLevel: enforcement,
            tags: tags,
            fileSize: fileSize,
            lineCount: lineCount
        )
    }

    private func extractTags(from content: String, category: String) -> [String] {
        var tags: [String] = [category]

        let patterns = ["@Bindable", "@Shared", "decision-tree", "workflow", "template"]
        for pattern in patterns {
            if content.contains(pattern) {
                tags.append(pattern.lowercased())
            }
        }

        return Array(Set(tags)).sorted()
}
}
