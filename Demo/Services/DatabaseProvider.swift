import Foundation
import RelationalSwift

protocol DatabaseProvider {
    /// Get a database connection.
    /// - Returns: Database connection.
    func getDatabase() async throws -> Database
}

actor DefaultDatabaseProvider: DatabaseProvider {
    static let shared = DefaultDatabaseProvider()

    private init() {}

    private var _database: Database?

    func getDatabase() async throws -> Database {
        // Return cached database connection if it exists
        if let _database {
            return _database
        }

        // Get URL for database file
        let directories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documents = directories.first else {
            throw AppError.documentsDirectoryNotFound
        }
        let url = documents.appending(path: "db.sqlite")

        // Check for the file's existance
        let exists = FileManager.default.fileExists(atPath: url.path(percentEncoded: false))

        // Create or open database
        let database = try await Database.open(url: url)

        // Create tables if the database was newly created
        if !exists {
            try await database.createTable(for: Contact.self)
            try await database.createTable(for: ContactProperty.self)
        }

        _database = database
        return database
    }
}
