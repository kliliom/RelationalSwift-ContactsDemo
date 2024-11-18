import SwiftUI

struct AddContactSheet: View {
    var service: any ContactService

    @State private var name = ""
    @State private var isSaving = false
    @FocusState private var nameFieldFocus: Bool

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .focused($nameFieldFocus)
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            isSaving = true
                            await service.addContact(name: name)
                            dismiss()
                            isSaving = false
                        }
                    } label: {
                        Text("Save")
                    }
                    .disabled(name.isEmpty)
                }
            }
            .disabled(isSaving)
            .onAppear {
                nameFieldFocus = true
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var service: (any ContactService)?

        var body: some View {
            if let service {
                Color.clear
                    .sheet(isPresented: .constant(true)) {
                        AddContactSheet(service: service)
                    }
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

    return Preview()
}
