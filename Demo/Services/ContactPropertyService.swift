import Foundation

@MainActor
protocol ContactPropertyService: ObservableObject {
    /// Loads contacts.
    func load() async

    /// Contact.
    var contact: Contact { get }

    /// Returns all contact properties for a contact.
    var properties: [ContactProperty] { get }
    
    /// Adds a property.
    /// - Parameters:
    ///   - key: Property key.
    ///   - value: Property value.
    func addProperty(key: ContactPropertyKey, value: String) async
    
    /// Deletes a property.
    /// - Parameter id: Property ID.
    func deleteProperty(id: UUID) async
}

@Observable
final class DefaultContactPropertyService: ContactPropertyService {
    @ObservationIgnored private let repository: ContactPropertyRepository
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored let contact: Contact

    init(repository: ContactPropertyRepository, contact: Contact) {
        self.repository = repository
        self.contact = contact

        loadTask = Task {
            await reloadProperties()
        }
    }

    func load() async {
        await loadTask?.value
    }

    private(set) var properties: [ContactProperty] = []

    private func reloadProperties() async {
        do {
            properties = try await repository.getAll(for: contact)
        } catch {
            print("Failed to reload properties: \(error)")
        }
    }

    func addProperty(key: ContactPropertyKey, value: String) async {
        let property = ContactProperty(id: UUID(), contactID: contact.id, key: key, value: value)
        do {
            try await repository.insert(property)
            await reloadProperties()
        } catch {
            print("Failed to add property: \(error)")
        }
    }

    func deleteProperty(id: UUID) async {
        do {
            try await repository.delete(byID: id)
            await reloadProperties()
        } catch {
            print("Failed to delete property: \(error)")
        }
    }
}
