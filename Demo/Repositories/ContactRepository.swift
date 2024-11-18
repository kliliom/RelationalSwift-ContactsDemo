import Foundation
import RelationalSwift

protocol ContactRepository: Sendable {
    /// Database.
    var database: Database { get }

    /// Gets all contacts.
    /// - Returns: All contacts.
    @DatabaseActor
    func getAll() throws -> [Contact]

    /// Gets a contact by ID.
    /// - Parameter byID: Contact ID.
    /// - Returns: Contact.
    @DatabaseActor
    func get(byID: UUID) throws -> Contact

    /// Inserts a contact.
    /// - Parameter contact: Contact.
    @DatabaseActor
    func insert(_ contact: Contact) throws

    /// Updates a contact.
    /// - Parameter contact: Contact.
    @DatabaseActor
    func update(_ contact: Contact) throws

    /// Deletes a contact by ID.
    /// - Parameter id: Contact ID.
    @DatabaseActor
    func delete(byID id: UUID) throws
}

final class DefaultContactRepository: ContactRepository {
    let database: Database

    init(database: Database) {
        self.database = database
    }

    func getAll() throws -> [Contact] {
        try database.from(Contact.self)
            .select()
    }

    func get(byID: UUID) throws -> Contact {
        let contacts = try database.from(Contact.self)
            .where { $0.id == byID }
            .select()

        guard let contact = contacts.first else {
            throw AppError.contactNotFound
        }
        return contact
    }

    func insert(_ contact: Contact) throws {
        try database.insert(contact)
    }

    func update(_ contact: Contact) throws {
        try database.update(contact)
    }

    func delete(byID id: UUID) throws {
        try database.delete(from: Contact.self, byKey: id)
    }
}
