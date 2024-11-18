import Foundation
import RelationalSwift

@Table struct ContactProperty: Identifiable {
    @Column(primaryKey: true) var id: UUID
    @Column var contactID: UUID
    @Column var key: ContactPropertyKey
    @Column var value: String
}

enum ContactPropertyKey: String, Bindable, CaseIterable {
    case phoneNumber
    case email
    case address
}
