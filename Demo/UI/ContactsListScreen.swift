import SwiftUI

struct ContactsListScreen: View {
    var service: any ContactService

    @State private var showAddContactSheet = false

    var body: some View {
        List {
            if service.contacts.isEmpty {
                Text("No contacts")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }

            ForEach(service.contacts) { contact in
                NavigationLink(value: contact) {
                    Text(contact.name)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            await service.deleteContact(id: contact.id)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
            }
        }
        .navigationDestination(for: Contact.self, destination: { contact in
            ContactDetailScreen(service: service.getPropertyService(for: contact))
        })
        .navigationTitle("Contacts")
        .toolbar {
            ToolbarItem() {
                Button("Add") {
                    showAddContactSheet = true
                }
            }
        }
        .sheet(isPresented: $showAddContactSheet) {
            AddContactSheet(service: service)
        }
    }
}

#Preview {
    struct Preview: View {
        @State var service: (any ContactService)?

        var body: some View {
            if let service {
                ContactsListScreen(service: service)
            } else {
                ProgressView()
                    .task {
                        service = try! await DefaultContactService(
                            repository: DefaultContactRepository(
                                database: DefaultDatabaseProvider.shared.getDatabase()
                            )
                        )
                    }
            }
        }
    }

    return NavigationStack {
        Preview()
    }
}
