#!/usr/bin/env swift

import Foundation

// Database connection
let dbPath = "/Volumes/Plutonian/_Developer/Smith Tools/Maxwell/database/maxwell.db"
var db: OpaquePointer?

func openDatabase() -> Bool {
    if sqlite3_open(dbPath, &db) == SQLITE_OK {
        return true
    }
    print("Failed to open database")
    return false
}

func insertDocument(title: String, content: String, path: String, category: String, subcategory: String?, role: String, enforcementLevel: String, tags: String) {
    var stmt: OpaquePointer?

    let sql = """
    INSERT OR REPLACE INTO documents (
        title, content, path, document_type, category, subcategory, role, enforcement_level, tags, created_at, file_size, line_count
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), ?, ?);
    """

    if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
        sqlite3_bind_text(stmt, 1, title, -1, nil)
        sqlite3_bind_text(stmt, 2, content, -1, nil)
        sqlite3_bind_text(stmt, 3, path, -1, nil)
        sqlite3_bind_text(stmt, 4, "technical", -1, nil)
        sqlite3_bind_text(stmt, 5, category, -1, nil)

        if let subcategory = subcategory {
            sqlite3_bind_text(stmt, 6, subcategory, -1, nil)
        } else {
            sqlite3_bind_null(stmt, 6)
        }

        sqlite3_bind_text(stmt, 7, role, -1, nil)
        sqlite3_bind_text(stmt, 8, enforcementLevel, -1, nil)
        sqlite3_bind_text(stmt, 9, tags, -1, nil)
        sqlite3_bind_int(stmt, 10, Int32(content.count))
        sqlite3_bind_int(stmt, 11, Int32(content.components(separatedBy: .newlines).count))

        if sqlite3_step(stmt) == SQLITE_DONE {
            print("✅ Inserted: \(title)")
        } else {
            print("❌ Failed to insert: \(title)")
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error: \(errmsg)")
        }

        sqlite3_finalize(stmt)
    }
}

// Read TCA patterns file
let tcaPatternsPath = "/Volumes/Plutonian/_Developer/_deprecated/Smith/Smith/Sources/AGENTS-TCA-PATTERNS.md"
guard let tcaContent = try? String(contentsOfFile: tcaPatternsPath) else {
    print("Failed to read TCA patterns file")
    exit(1)
}

// Open database
guard openDatabase() else {
    exit(1)
}

// Insert the complete TCA patterns document
insertDocument(
    title: "TCA 1.23.0+ Modern Patterns for Agents",
    content: tcaContent,
    path: "/Volumes/Plutonian/_Developer/_deprecated/Smith/Smith/Sources/AGENTS-TCA-PATTERNS.md",
    category: "TCA",
    subcategory: "Modern Patterns",
    role: "canonical",
    enforcementLevel: "canonical",
    tags: "TCA,Swift Composable Architecture,@Bindable,@Shared,Point-Free,Modern Patterns,Anti-Patterns"
)

print("✅ TCA Patterns migration complete")

sqlite3_close(db)