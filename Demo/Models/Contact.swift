import Foundation
import RelationalSwift

@Table struct Contact: Hashable, Identifiable {
    @Column(primaryKey: true) var id: UUID
    @Column var name: String
}
