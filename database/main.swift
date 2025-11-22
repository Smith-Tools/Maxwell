import Foundation

/// Main execution point for Maxwell Database Migration

let dbPath = "/Volumes/Plutonian/_Developer/Maxwells/database/maxwell.db"
let database = try SimpleDatabase(databasePath: dbPath)
let migrator = SimpleMigrator(database: database)

print("🔧 Simple Maxwell Database Migration Tool")
print(String(repeating: "=", count: 50))

try migrator.migrateAll()

print("\n🎉 Migration completed successfully!")
print("📁 Database location: \(dbPath)")

// Test search functionality
print("\n🔍 Testing search functionality...")
let searchResults = try database.searchDocuments(query: "TCA")
print("Found \(searchResults.count) documents matching 'TCA'")
for doc in searchResults.prefix(3) {
    print("  - \(doc.title) (\(doc.category))")
}
