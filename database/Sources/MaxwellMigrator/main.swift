import Foundation

/// Maxwell Database Migration Tool
let database = try MaxwellDatabase()
let migrator = DocumentMigrator(database: database)

print("🔧 Maxwell Knowledge Database Migration Tool")
print(String(repeating: "=", count: 50))

try await migrator.migrateAll()

print("\n🎉 Migration completed successfully!")
print("📁 Database location: /Volumes/Plutonian/_Developer/Maxwells/database/maxwell.db")
