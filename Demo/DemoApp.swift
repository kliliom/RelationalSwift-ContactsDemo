import SwiftUI

@main
struct DemoApp: App {
    @State private var service: (any ContactService)?

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if let service {
                    ContactsListScreen(service: service)
                } else {
                    ProgressView()
                }
            }
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
