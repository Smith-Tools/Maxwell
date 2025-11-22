import Foundation
import SQLite3

/// Simple SQLite database for Maxwell documentation
public class SimpleDatabase {
    private var db: OpaquePointer?
    private let path: String

    public init(databasePath: String) throws {
        self.path = databasePath
        try openDatabase()
        try createTables()
    }

    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }

    private func openDatabase() throws {
        if sqlite3_open(path, &db) != SQLITE_OK {
            throw DatabaseError.connectionError
        }
    }

    private func createTables() throws {
        let createDocumentsTable = """
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
                file_size INTEGER,
                line_count INTEGER
            );
        """

        let createSearchTable = """
            CREATE VIRTUAL TABLE IF NOT EXISTS document_search USING fts5(
                title,
                content,
                tags,
                category
            );
        """

        let createPatternsTable = """
            CREATE TABLE IF NOT EXISTS patterns (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT UNIQUE NOT NULL,
                domain TEXT NOT NULL,
                problem TEXT NOT NULL,
                solution TEXT NOT NULL,
                code_example TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                last_validated DATETIME,
                is_current BOOLEAN DEFAULT 1,
                notes TEXT
            );
        """

        let createPatternSearchTable = """
            CREATE VIRTUAL TABLE IF NOT EXISTS pattern_search USING fts5(
                name,
                problem,
                solution,
                code_example
            );
        """

        if sqlite3_exec(db, createDocumentsTable, nil, nil, nil) != SQLITE_OK {
            throw DatabaseError.tableCreationError
        }

        if sqlite3_exec(db, createPatternsTable, nil, nil, nil) != SQLITE_OK {
            throw DatabaseError.tableCreationError
        }

        if sqlite3_exec(db, createSearchTable, nil, nil, nil) != SQLITE_OK {
            // FTS5 might not be available, continue without it
            print("Warning: FTS5 not available, search functionality limited")
        }

        if sqlite3_exec(db, createPatternSearchTable, nil, nil, nil) != SQLITE_OK {
            // FTS5 might not be available, continue without it
            print("Warning: Pattern FTS5 not available, pattern search functionality limited")
        }
    }

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

        let insertSQL = """
            INSERT OR REPLACE INTO documents 
            (title, content, path, document_type, category, subcategory, 
             role, enforcement_level, tags, file_size, line_count)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """

        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, insertSQL, -1, &stmt, nil) != SQLITE_OK {
            throw DatabaseError.preparationError
        }

        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (title as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 2, (content as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 3, (path as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 4, (documentType as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 5, (category as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        if let subcategory = subcategory {
            sqlite3_bind_text(stmt, 6, (subcategory as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        } else {
            sqlite3_bind_null(stmt, 6)
        }
        sqlite3_bind_text(stmt, 7, (role as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 8, (enforcementLevel as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 9, (tagsString as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_int(stmt, 10, Int32(fileSize))
        sqlite3_bind_int(stmt, 11, Int32(lineCount))

        if sqlite3_step(stmt) != SQLITE_DONE {
            throw DatabaseError.insertionError
        }
    }

    public func searchDocuments(query: String) throws -> [Document] {
        let searchSQL = """
            SELECT id, title, content, path, document_type, category, subcategory,
                   role, enforcement_level, tags, file_size, line_count
            FROM documents 
            WHERE title LIKE ? OR content LIKE ? OR tags LIKE ?
            ORDER BY title
            LIMIT 50
        """

        let searchPattern = "%\(query)%"

        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, searchSQL, -1, &stmt, nil) != SQLITE_OK {
            throw DatabaseError.preparationError
        }

        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (searchPattern as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 2, (searchPattern as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 3, (searchPattern as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))

        var documents: [Document] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let document = createDocumentFromStatement(stmt) {
                documents.append(document)
            }
        }

        return documents
    }

    public func getDocumentsByCategory(category: String) throws -> [Document] {
        let selectSQL = """
            SELECT id, title, content, path, document_type, category, subcategory,
                   role, enforcement_level, tags, file_size, line_count
            FROM documents 
            WHERE category = ?
            ORDER BY title
        """

        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, selectSQL, -1, &stmt, nil) != SQLITE_OK {
            throw DatabaseError.preparationError
        }

        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (category as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))

        var documents: [Document] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let document = createDocumentFromStatement(stmt) {
                documents.append(document)
            }
        }

        return documents
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
        let insertSQL = """
            INSERT INTO patterns (name, domain, problem, solution, code_example, notes)
            VALUES (?, ?, ?, ?, ?, ?);
        """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) != SQLITE_OK {
            throw DatabaseError.preparationError
        }

        sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(statement, 2, (domain as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(statement, 3, (problem as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(statement, 4, (solution as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(statement, 5, (codeExample as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(statement, 6, (notes as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))

        if sqlite3_step(statement) != SQLITE_DONE {
            throw DatabaseError.insertionError
        }

        sqlite3_finalize(statement)
    }

    public func searchPatterns(query: String) throws -> [Pattern] {
        let searchSQL = """
            SELECT p.* FROM patterns p
            JOIN pattern_search ps ON p.id = ps.rowid
            WHERE pattern_search MATCH ?;
        """

        var statement: OpaquePointer?
        var patterns: [Pattern] = []

        if sqlite3_prepare_v2(db, searchSQL, -1, &statement, nil) != SQLITE_OK {
            // Fallback to basic search without FTS5
            return try basicPatternSearch(query: query)
        }

        sqlite3_bind_text(statement, 1, (query as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))

        while sqlite3_step(statement) == SQLITE_ROW {
            if let pattern = createPatternFromStatement(statement) {
                patterns.append(pattern)
            }
        }

        sqlite3_finalize(statement)
        return patterns
    }

    private func basicPatternSearch(query: String) throws -> [Pattern] {
        let searchSQL = """
            SELECT * FROM patterns
            WHERE name LIKE ? OR domain LIKE ? OR problem LIKE ? OR solution LIKE ?;
        """

        var statement: OpaquePointer?
        var patterns: [Pattern] = []
        let searchPattern = "%\(query)%"

        if sqlite3_prepare_v2(db, searchSQL, -1, &statement, nil) != SQLITE_OK {
            throw DatabaseError.preparationError
        }

        sqlite3_bind_text(statement, 1, (searchPattern as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(statement, 2, (searchPattern as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(statement, 3, (searchPattern as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))
        sqlite3_bind_text(statement, 4, (searchPattern as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))

        while sqlite3_step(statement) == SQLITE_ROW {
            if let pattern = createPatternFromStatement(statement) {
                patterns.append(pattern)
            }
        }

        sqlite3_finalize(statement)
        return patterns
    }

    public func getPatternsByDomain(_ domain: String) throws -> [Pattern] {
        let searchSQL = "SELECT * FROM patterns WHERE domain = ? AND is_current = 1 ORDER BY name;"

        var statement: OpaquePointer?
        var patterns: [Pattern] = []

        if sqlite3_prepare_v2(db, searchSQL, -1, &statement, nil) != SQLITE_OK {
            throw DatabaseError.preparationError
        }

        sqlite3_bind_text(statement, 1, (domain as NSString).utf8String, -1, unsafeBitCast(Int(-1), to: sqlite3_destructor_type.self))

        while sqlite3_step(statement) == SQLITE_ROW {
            if let pattern = createPatternFromStatement(statement) {
                patterns.append(pattern)
            }
        }

        sqlite3_finalize(statement)
        return patterns
    }

    private func createPatternFromStatement(_ stmt: OpaquePointer?) -> Pattern? {
        guard let stmt = stmt else { return nil }

        let id = sqlite3_column_int64(stmt, 0)

        let nameCString = sqlite3_column_text(stmt, 1)
        let name = nameCString != nil ? String(cString: nameCString!) : ""

        let domainCString = sqlite3_column_text(stmt, 2)
        let domain = domainCString != nil ? String(cString: domainCString!) : ""

        let problemCString = sqlite3_column_text(stmt, 3)
        let problem = problemCString != nil ? String(cString: problemCString!) : ""

        let solutionCString = sqlite3_column_text(stmt, 4)
        let solution = solutionCString != nil ? String(cString: solutionCString!) : ""

        let codeCString = sqlite3_column_text(stmt, 5)
        let codeExample = codeCString != nil ? String(cString: codeCString!) : ""

        let createdCString = sqlite3_column_text(stmt, 6)
        let createdAt = createdCString != nil ? String(cString: createdCString!) : ""

        let validatedCString = sqlite3_column_text(stmt, 7)
        let lastValidated = validatedCString != nil ? String(cString: validatedCString!) : ""

        let isCurrent = sqlite3_column_int(stmt, 8) == 1

        let notesCString = sqlite3_column_text(stmt, 9)
        let notes = notesCString != nil ? String(cString: notesCString!) : ""

        return Pattern(
            id: id,
            name: name,
            domain: domain,
            problem: problem,
            solution: solution,
            codeExample: codeExample,
            createdAt: createdAt,
            lastValidated: lastValidated,
            isCurrent: isCurrent,
            notes: notes
        )
    }

    private func createDocumentFromStatement(_ stmt: OpaquePointer?) -> Document? {
        guard let stmt = stmt else { return nil }

        let id = sqlite3_column_int64(stmt, 0)
        
        let titleCString = sqlite3_column_text(stmt, 1)
        let title = titleCString != nil ? String(cString: titleCString!) : ""
        
        let contentCString = sqlite3_column_text(stmt, 2)
        let content = contentCString != nil ? String(cString: contentCString!) : ""
        
        let pathCString = sqlite3_column_text(stmt, 3)
        let path = pathCString != nil ? String(cString: pathCString!) : ""
        
        let typeCString = sqlite3_column_text(stmt, 4)
        let documentType = typeCString != nil ? String(cString: typeCString!) : ""
        
        let categoryCString = sqlite3_column_text(stmt, 5)
        let category = categoryCString != nil ? String(cString: categoryCString!) : ""
        
        let subcategoryCString = sqlite3_column_text(stmt, 6)
        let subcategory = subcategoryCString != nil ? String(cString: subcategoryCString!) : nil
        
        let roleCString = sqlite3_column_text(stmt, 7)
        let role = roleCString != nil ? String(cString: roleCString!) : ""
        
        let enforcementCString = sqlite3_column_text(stmt, 8)
        let enforcement = enforcementCString != nil ? String(cString: enforcementCString!) : ""
        
        let tagsCString = sqlite3_column_text(stmt, 9)
        let tagsString = tagsCString != nil ? String(cString: tagsCString!) : ""
        let tags = tagsString.isEmpty ? [] : tagsString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        
        let fileSize = Int(sqlite3_column_int(stmt, 10))
        let lineCount = Int(sqlite3_column_int(stmt, 11))

        return Document(
            id: id,
            title: title,
            content: content,
            path: path,
            documentType: documentType,
            category: category,
            subcategory: subcategory,
            role: role,
            enforcementLevel: enforcement,
            tags: tags,
            fileSize: fileSize,
            lineCount: lineCount
        )
    }

    public func getStats() -> (total: Int, technical: Int, process: Int) {
        let countSQL = "SELECT COUNT(*), document_type FROM documents GROUP BY document_type"
        var stmt: OpaquePointer?
        
        var total = 0
        var technical = 0
        var process = 0

        if sqlite3_prepare_v2(db, countSQL, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let count = Int(sqlite3_column_int(stmt, 0))
                let typeCString = sqlite3_column_text(stmt, 1)
                let type = typeCString != nil ? String(cString: typeCString!) : ""
                
                total += count
                if type == "technical" {
                    technical = count
                } else if type == "process" {
                    process = count
                }
            }
            sqlite3_finalize(stmt)
        }

        return (total: total, technical: technical, process: process)
    }
}

enum DatabaseError: Error {
    case connectionError
    case tableCreationError
    case preparationError
    case insertionError
    
    var localizedDescription: String {
        switch self {
        case .connectionError: return "Failed to connect to database"
        case .tableCreationError: return "Failed to create tables"
        case .preparationError: return "Failed to prepare SQL statement"
        case .insertionError: return "Failed to insert data"
        }
    }
}

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
