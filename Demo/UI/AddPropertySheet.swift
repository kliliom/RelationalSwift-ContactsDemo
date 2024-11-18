import SwiftUI

struct AddPropertySheet: View {
    var service: any ContactPropertyService

    @State private var key: ContactPropertyKey = .address
    @State private var value = ""
    @State private var isSaving = false
    @FocusState private var valueFieldFocus: Bool

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Picker("Key", selection: $key) {
                    ForEach(ContactPropertyKey.allCases, id: \.self) { key in
                        Text(key.displayName)
                    }
                }
                TextField("Value", text: $value)
                    .focused($valueFieldFocus)
            }
            .navigationTitle("Add Property")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isSaving = true
                            await service.addProperty(key: key, value: value)
                            dismiss()
                            isSaving = false
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .onChange(of: key) {
                valueFieldFocus = true
            }
            .onAppear {
                valueFieldFocus = true
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var service: (any ContactPropertyService)?

        var body: some View {
            if let service {
                Color.clear
                    .sheet(isPresented: .constant(true)) {
                        AddPropertySheet(service: service)
                    }
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

    return Preview()
}
