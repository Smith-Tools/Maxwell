import Foundation
import SQLite3

/// Simple SQLite database for Maxwell documentation
class SimpleDatabase {
    private var db: OpaquePointer?
    private let path: String

    init(databasePath: String) throws {
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

        if sqlite3_exec(db, createDocumentsTable, nil, nil, nil) != SQLITE_OK {
            throw DatabaseError.tableCreationError
        }

        if sqlite3_exec(db, createSearchTable, nil, nil, nil) != SQLITE_OK {
            // FTS5 might not be available, continue without it
            print("Warning: FTS5 not available, search functionality limited")
        }
    }

    func insertDocument(
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

        sqlite3_bind_text(stmt, 1, title, -1, nil)
        sqlite3_bind_text(stmt, 2, content, -1, nil)
        sqlite3_bind_text(stmt, 3, path, -1, nil)
        sqlite3_bind_text(stmt, 4, documentType, -1, nil)
        sqlite3_bind_text(stmt, 5, category, -1, nil)
        sqlite3_bind_text(stmt, 6, subcategory, -1, nil)
        sqlite3_bind_text(stmt, 7, role, -1, nil)
        sqlite3_bind_text(stmt, 8, enforcementLevel, -1, nil)
        sqlite3_bind_text(stmt, 9, tagsString, -1, nil)
        sqlite3_bind_int(stmt, 10, Int32(fileSize))
        sqlite3_bind_int(stmt, 11, Int32(lineCount))

        if sqlite3_step(stmt) != SQLITE_DONE {
            throw DatabaseError.insertionError
        }
    }

    func searchDocuments(query: String) throws -> [Document] {
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

        sqlite3_bind_text(stmt, 1, searchPattern, -1, nil)
        sqlite3_bind_text(stmt, 2, searchPattern, -1, nil)
        sqlite3_bind_text(stmt, 3, searchPattern, -1, nil)

        var documents: [Document] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let document = createDocumentFromStatement(stmt) {
                documents.append(document)
            }
        }

        return documents
    }

    func getDocumentsByCategory(category: String) throws -> [Document] {
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

        sqlite3_bind_text(stmt, 1, category, -1, nil)

        var documents: [Document] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let document = createDocumentFromStatement(stmt) {
                documents.append(document)
            }
        }

        return documents
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

    func getStats() -> (total: Int, technical: Int, process: Int) {
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

struct Document {
    let id: Int64
    let title: String
    let content: String
    let path: String
    let documentType: String
    let category: String
    let subcategory: String?
    let role: String
    let enforcementLevel: String
    let tags: [String]
    let fileSize: Int
    let lineCount: Int
}
