import Foundation
import SQLite

/// Type-safe SQLite database for Maxwell documentation using SQLite.swift
public class SimpleDatabase {
    private let db: Connection

    // Define tables
    private let documents = Table("documents")
    private let patterns = Table("patterns")

    // Document columns
    private let docId = Expression<Int64>("id")
    private let docTitle = Expression<String>("title")
    private let docContent = Expression<String>("content")
    private let docPath = Expression<String>("path")
    private let docType = Expression<String>("document_type")
    private let docCategory = Expression<String>("category")
    private let docSubcategory = Expression<String?>("subcategory")
    private let docRole = Expression<String>("role")
    private let docEnforcementLevel = Expression<String>("enforcement_level")
    private let docTags = Expression<String>("tags")
    private let docCreatedAt = Expression<Date>("created_at")
    private let docFileSize = Expression<Int>("file_size")
    private let docLineCount = Expression<Int>("line_count")

    // Pattern columns
    private let patternId = Expression<Int64>("id")
    private let patternName = Expression<String>("name")
    private let patternDomain = Expression<String>("domain")
    private let patternProblem = Expression<String>("problem")
    private let patternSolution = Expression<String>("solution")
    private let patternCode = Expression<String>("code_example")
    private let patternCreatedAt = Expression<Date>("created_at")
    private let patternLastValidated = Expression<Date?>("last_validated")
    private let patternIsCurrent = Expression<Bool>("is_current")
    private let patternNotes = Expression<String>("notes")

    public init(databasePath: String) throws {
        self.db = try Connection(databasePath)
        try createTables()
    }

    private func createTables() throws {
        // Create documents table
        try db.run(documents.create(ifNotExists: true) { t in
            t.column(docId, primaryKey: .autoincrement)
            t.column(docTitle)
            t.column(docContent)
            t.column(docPath, unique: true)
            t.column(docType)
            t.column(docCategory)
            t.column(docSubcategory)
            t.column(docRole)
            t.column(docEnforcementLevel)
            t.column(docTags)
            t.column(docCreatedAt, defaultValue: Date())
            t.column(docFileSize)
            t.column(docLineCount)
        })

        // Create patterns table
        try db.run(patterns.create(ifNotExists: true) { t in
            t.column(patternId, primaryKey: .autoincrement)
            t.column(patternName, unique: true)
            t.column(patternDomain)
            t.column(patternProblem)
            t.column(patternSolution)
            t.column(patternCode)
            t.column(patternCreatedAt, defaultValue: Date())
            t.column(patternLastValidated)
            t.column(patternIsCurrent, defaultValue: true)
            t.column(patternNotes)
        })
    }

    // MARK: - Document Methods

    public func insertDocument(
        title: String,
        content: String,
        path: String,
        documentType: String,
        category: String,
        subcategory: String?,
        role: String,
        enforcementLevel: String,
        tags: [String],
        fileSize: Int,
        lineCount: Int
    ) throws {
        let tagsString = tags.joined(separator: ",")

        try db.run(documents.insert(or: .replace,
            docTitle <- title,
            docContent <- content,
            docPath <- path,
            docType <- documentType,
            docCategory <- category,
            docSubcategory <- (subcategory?.isEmpty == false ? subcategory : nil),
            docRole <- role,
            docEnforcementLevel <- enforcementLevel,
            docTags <- tagsString,
            docFileSize <- fileSize,
            docLineCount <- lineCount
        ))
    }

    public func searchDocuments(query: String) throws -> [Document] {
        let searchPattern = "%\(query)%"

        let results = try db.prepare(
            documents
                .where(docTitle.like(searchPattern) ||
                       docContent.like(searchPattern) ||
                       docTags.like(searchPattern))
                .order(docTitle)
                .limit(50)
        )

        return try results.map { row in
            Document(
                id: row[docId],
                title: row[docTitle],
                content: row[docContent],
                path: row[docPath],
                documentType: row[docType],
                category: row[docCategory],
                subcategory: row[docSubcategory],
                role: row[docRole],
                enforcementLevel: row[docEnforcementLevel],
                tags: row[docTags].split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) },
                fileSize: row[docFileSize],
                lineCount: row[docLineCount]
            )
        }
    }

    public func getDocumentsByCategory(category: String) throws -> [Document] {
        let results = try db.prepare(
            documents
                .where(docCategory == category)
                .order(docTitle)
        )

        return try results.map { row in
            Document(
                id: row[docId],
                title: row[docTitle],
                content: row[docContent],
                path: row[docPath],
                documentType: row[docType],
                category: row[docCategory],
                subcategory: row[docSubcategory],
                role: row[docRole],
                enforcementLevel: row[docEnforcementLevel],
                tags: row[docTags].split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) },
                fileSize: row[docFileSize],
                lineCount: row[docLineCount]
            )
        }
    }

    // MARK: - Pattern Methods

    public func insertPattern(
        name: String,
        domain: String,
        problem: String,
        solution: String,
        codeExample: String,
        notes: String = ""
    ) throws {
        try db.run(patterns.insert(
            patternName <- name,
            patternDomain <- domain,
            patternProblem <- problem,
            patternSolution <- solution,
            patternCode <- codeExample,
            patternNotes <- notes
        ))
    }

    public func searchPatterns(query: String) throws -> [Pattern] {
        let searchPattern = "%\(query)%"

        let results = try db.prepare(
            patterns
                .where(patternName.like(searchPattern) ||
                       patternDomain.like(searchPattern) ||
                       patternProblem.like(searchPattern) ||
                       patternSolution.like(searchPattern))
        )

        return try results.map { row in
            Pattern(
                id: row[patternId],
                name: row[patternName],
                domain: row[patternDomain],
                problem: row[patternProblem],
                solution: row[patternSolution],
                codeExample: row[patternCode],
                createdAt: ISO8601DateFormatter().string(from: row[patternCreatedAt]),
                lastValidated: row[patternLastValidated].map { ISO8601DateFormatter().string(from: $0) } ?? "",
                isCurrent: row[patternIsCurrent],
                notes: row[patternNotes]
            )
        }
    }

    public func getPatternsByDomain(_ domain: String) throws -> [Pattern] {
        let results = try db.prepare(
            patterns
                .where(patternDomain == domain && patternIsCurrent == true)
                .order(patternName)
        )

        return try results.map { row in
            Pattern(
                id: row[patternId],
                name: row[patternName],
                domain: row[patternDomain],
                problem: row[patternProblem],
                solution: row[patternSolution],
                codeExample: row[patternCode],
                createdAt: ISO8601DateFormatter().string(from: row[patternCreatedAt]),
                lastValidated: row[patternLastValidated].map { ISO8601DateFormatter().string(from: $0) } ?? "",
                isCurrent: row[patternIsCurrent],
                notes: row[patternNotes]
            )
        }
    }

    public func getStats() -> (total: Int, technical: Int, process: Int) {
        do {
            let total = try db.scalar(documents.select(docId).count)
            let technical = try db.scalar(
                documents.where(docType == "technical").select(docId).count
            )
            let process = try db.scalar(
                documents.where(docType == "process").select(docId).count
            )
            return (total: total, technical: technical, process: process)
        } catch {
            return (total: 0, technical: 0, process: 0)
        }
    }
}

// MARK: - Models

public struct Pattern {
    public let id: Int64
    public let name: String
    public let domain: String
    public let problem: String
    public let solution: String
    public let codeExample: String
    public let createdAt: String
    public let lastValidated: String
    public let isCurrent: Bool
    public let notes: String
}

public struct Document {
    public let id: Int64
    public let title: String
    public let content: String
    public let path: String
    public let documentType: String
    public let category: String
    public let subcategory: String?
    public let role: String
    public let enforcementLevel: String
    public let tags: [String]
    public let fileSize: Int
    public let lineCount: Int
}
