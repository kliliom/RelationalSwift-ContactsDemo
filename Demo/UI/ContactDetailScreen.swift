import SwiftUI

struct ContactDetailScreen: View {
    var service: any ContactPropertyService

    @State private var showAddPropertySheet = false

    var body: some View {
        List {
            if service.properties.isEmpty {
                Text("No properties")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }

            ForEach(service.properties) { property in
                HStack {
                    Text(property.key.displayName)
                        .font(.headline)
                    Text(property.value)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            await service.deleteProperty(id: property.id)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
            }
        }
        .navigationTitle(service.contact.name)
        .toolbar {
            ToolbarItem() {
                Button("Add") {
                    showAddPropertySheet = true
                }
            }
        }
        .sheet(isPresented: $showAddPropertySheet) {
            AddPropertySheet(service: service)
        }
    }
}

#Preview {
    struct Preview: View {
        @State var service: (any ContactPropertyService)?

        var body: some View {
            if let service {
                ContactDetailScreen(service: service)
            } else {
                ProgressView()
                    .task {
                        let contactService = try! await DefaultContactService(
                            repository: DefaultContactRepository(
                                database: DefaultDatabaseProvider.shared.getDatabase()
                            )
                        )

                        await contactService.load()

                        if contactService.contacts.isEmpty {
                            await contactService.addContact(name: "John Doe")
                        }

                        guard let contact = contactService.contacts.first else {
                            return
                        }
                        service = contactService.getPropertyService(for: contact)
                    }
            }
        }
    }

    return NavigationStack {
        Preview()
    }
}
