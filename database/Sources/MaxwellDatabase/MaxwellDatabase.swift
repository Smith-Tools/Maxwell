import Foundation
import SQLite

/// Maxwell Knowledge Database - Combines TCA technical docs with Smith process workflows
public struct MaxwellDatabase {
    public let db: Connection

    public init(databasePath: String = "/Volumes/Plutonian/_Developer/Maxwells/database/maxwell.db") throws {
        self.db = try Connection(databasePath)
        try createTables()
        setupPerformanceOptimizations()
    }

    private func createTables() throws {
        try db.execute("""
            CREATE TABLE IF NOT EXISTS documents (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                content TEXT NOT NULL,
                path TEXT UNIQUE NOT NULL,
                document_type TEXT NOT NULL,
                category TEXT NOT NULL,
                subcategory TEXT,
                role TEXT NOT NULL,
                enforcement_level TEXT NOT NULL,
                tags TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
                file_size INTEGER,
                line_count INTEGER
            );
        """)

        try db.execute("""
            CREATE TABLE IF NOT EXISTS user_roles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                role_name TEXT UNIQUE NOT NULL,
                description TEXT,
                default_categories TEXT,
                default_enforcement_min TEXT,
                workflow_stages TEXT
            );
        """)

        try db.execute("""
            CREATE VIRTUAL TABLE IF NOT EXISTS document_search USING fts5(
                title,
                content,
                tags,
                category,
                content='documents',
                content_rowid='id'
            );
        """)

        try insertDefaultRoles()
    }

    private func insertDefaultRoles() throws {
        let roles: [(String, String, String, String, String)] = [
            ("developer", "Writes code and implements features", "tca-patterns,tca-navigation", "STANDARD", "implementation,testing"),
            ("agent", "AI assistant that provides guidance", "tca-patterns,decision-trees", "GUIDANCE", "analysis,generation"),
            ("lead", "Team lead who reviews code", "decision-trees,validation", "CRITICAL", "planning,review"),
            ("architect", "System architect who designs", "decision-trees,architecture", "CRITICAL", "planning,design")
        ]

        for (role, description, categories, enforcement, stages) in roles {
            try db.execute("""
                INSERT OR IGNORE INTO user_roles
                (role_name, description, default_categories, default_enforcement_min, workflow_stages)
                VALUES (?, ?, ?, ?, ?)
            """, role, description, categories, enforcement, stages)
        }
    }

    private func setupPerformanceOptimizations() {
        do {
            try db.execute("PRAGMA journal_mode = WAL")
            try db.execute("PRAGMA synchronous = NORMAL")
            try db.execute("PRAGMA cache_size = 10000")
        } catch {
            print("Warning: Could not setup performance optimizations: \(error)")
        }
    }

    public func insertDocument(
        title: String,
        content: String,
        path: String,
        documentType: DocumentType,
        category: String,
        subcategory: String? = nil,
        role: Role,
        enforcementLevel: EnforcementLevel,
        tags: [String] = [],
        fileSize: Int,
        lineCount: Int
    ) throws -> Int64 {
        let tagsJson = tags.joined(separator: ",")

        try db.run("""
            INSERT OR REPLACE INTO documents (
                title, content, path, document_type, category, subcategory,
                role, enforcement_level, tags, file_size, line_count, last_updated
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        """, title, content, path, documentType.rawValue, category, subcategory,
              role.rawValue, enforcementLevel.rawValue, tagsJson, fileSize, lineCount)

        let documentId = db.lastInsertRowid

        // Update search index
        try updateSearchIndex(documentId: documentId, title: title, content: content, tags: tags, category: category)

        return documentId
    }

    private func updateSearchIndex(documentId: Int64, title: String, content: String, tags: [String], category: String) throws {
        let tagsString = tags.joined(separator: " ")
        try db.execute("""
            INSERT INTO document_search (rowid, title, content, tags, category)
            VALUES (?, ?, ?, ?, ?)
        """, documentId, title, content, tagsString, category)
    }

    public func searchDocuments(query: String, role: Role? = nil, limit: Int = 50) throws -> [Document] {
        var sql = """
            SELECT d.* FROM documents d
            JOIN document_search ds ON d.id = ds.rowid
            WHERE document_search MATCH ?
        """
        var params: [Binding] = [query]

        if let role = role {
            sql += " AND d.role = ?"
            params.append(role.rawValue)
        }

        sql += " ORDER BY rank LIMIT ?"
        params.append(limit)

        var documents: [Document] = []
        for row in try db.prepare(sql, params) {
            documents.append(try documentFromRow(row))
        }

        return documents
    }

    public func getDocumentsByCategory(category: String, role: Role? = nil) throws -> [Document] {
        var sql = "SELECT * FROM documents WHERE category = ?"
        var params: [Binding] = [category]

        if let role = role {
            sql += " AND role = ?"
            params.append(role.rawValue)
        }

        sql += " ORDER BY enforcement_level DESC, title"

        var documents: [Document] = []
        for row in try db.prepare(sql, params) {
            documents.append(try documentFromRow(row))
        }

        return documents
    }

    private func documentFromRow(_ row: Row) throws -> Document {
        let tagsJson = row[9] as? String ?? ""
        let tags = tagsJson.isEmpty ? [] : tagsJson.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }

        return Document(
            id: row[0] as! Int64,
            title: row[1] as! String,
            content: row[2] as! String,
            path: row[3] as! String,
            documentType: DocumentType(rawValue: row[4] as! String) ?? .technical,
            category: row[5] as! String,
            subcategory: row[6] as? String,
            role: Role(rawValue: row[7] as! String) ?? .developer,
            enforcementLevel: EnforcementLevel(rawValue: row[8] as! String) ?? .standard,
            tags: tags,
            createdAt: row[10] as! Date,
            lastUpdated: row[11] as! Date,
            fileSize: row[12] as? Int ?? 0,
            lineCount: row[13] as? Int ?? 0
        )
    }
}

// MARK: - Data Models

public enum DocumentType: String, CaseIterable {
    case technical = "technical"
    case process = "process"
}

public enum Role: String, CaseIterable {
    case developer = "developer"
    case agent = "agent"
    case lead = "lead"
    case architect = "architect"
}

public enum EnforcementLevel: String, CaseIterable, Comparable {
    case guidance = "GUIDANCE"
    case standard = "STANDARD"
    case critical = "CRITICAL"

    public static func < (lhs: EnforcementLevel, rhs: EnforcementLevel) -> Bool {
        let order: [EnforcementLevel] = [.guidance, .standard, .critical]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

public struct Document {
    public let id: Int64
    public let title: String
    public let content: String
    public let path: String
    public let documentType: DocumentType
    public let category: String
    public let subcategory: String?
    public let role: Role
    public let enforcementLevel: EnforcementLevel
    public let tags: [String]
    public let createdAt: Date
    public let lastUpdated: Date
    public let fileSize: Int
    public let lineCount: Int
}