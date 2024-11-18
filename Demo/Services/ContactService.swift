import Foundation

@MainActor
protocol ContactService: ObservableObject {
    /// Loads contacts.
    func load() async

    /// Returns all contacts.
    var contacts: [Contact] { get }
    
    /// Adds a contact.
    /// - Parameter name: Contact name.
    func addContact(name: String) async

    /// Updates a contact.
    /// - Parameters:
    ///   - id: Contact ID.
    ///   - name: Contact name.
    func updateContact(id: UUID, name: String) async

    /// Deletes a contact.
    /// - Parameter id: Contact ID.
    func deleteContact(id: UUID) async
    
    /// Returns a property service for a contact.
    /// - Parameter contact: Contact.
    /// - Returns: Contact property service.
    func getPropertyService(for contact: Contact) -> any ContactPropertyService
}

@Observable
final class DefaultContactService: ContactService {
    @ObservationIgnored private let repository: ContactRepository
    @ObservationIgnored private var loadTask: Task<Void, Never>?

    init(repository: ContactRepository) {
        self.repository = repository

        loadTask = Task {
            await reloadContacts()
        }
    }

    func load() async {
        await loadTask?.value
    }

    private(set) var contacts: [Contact] = []

    private func reloadContacts() async {
        do {
            contacts = try await repository.getAll()
        } catch {
            print("Failed to reload contacts: \(error)")
        }
    }

    func addContact(name: String) async {
        let contact = Contact(id: UUID(), name: name)
        do {
            try await repository.insert(contact)
            await reloadContacts()
        } catch {
            print("Failed to add contact: \(error)")
        }
    }

    func updateContact(id: UUID, name: String) async {
        do {
            try await repository.update(Contact(id: id, name: name))
            await reloadContacts()
        } catch {
            print("Failed to update contact: \(error)")
        }
    }

    func deleteContact(id: UUID) async {
        do {
            try await repository.delete(byID: id)
            await reloadContacts()
        } catch {
            print("Failed to delete contact: \(error)")
        }
    }

    func getPropertyService(for contact: Contact) -> any ContactPropertyService {
        DefaultContactPropertyService(
            repository: DefaultContactPropertyRepository(
                database: repository.database
            ),
            contact: contact
        )
    }
}
