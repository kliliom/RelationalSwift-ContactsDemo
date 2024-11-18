import Foundation
import RelationalSwift

protocol ContactPropertyRepository: Sendable {
    /// Database.
    var database: Database { get }

    /// Gets all contact properties.
    /// - Parameter contact: Contact to get properties for.
    /// - Returns: All contact properties.
    @DatabaseActor
    func getAll(for contact: Contact) throws -> [ContactProperty]

    /// Inserts a contact property.
    /// - Parameter property: Contact property.
    @DatabaseActor
    func insert(_ property: ContactProperty) throws

    /// Deletes a contact property by ID.
    /// - Parameter id: Contact property ID.
    @DatabaseActor
    func delete(byID id: UUID) throws
}

final class DefaultContactPropertyRepository: ContactPropertyRepository {
    let database: Database

    init(database: Database) {
        self.database = database
    }

    func getAll(for contact: Contact) throws -> [ContactProperty] {
        try database.from(ContactProperty.table)
            .where { $0.contactID == contact.id }.select()
    }

    func insert(_ property: ContactProperty) throws {
        try database.insert(property)
    }

    func delete(byID id: UUID) throws {
        try database.delete(from: ContactProperty.self, byKey: id)
    }
}
