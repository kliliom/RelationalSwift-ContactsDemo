extension ContactPropertyKey {
    var displayName: String {
        switch self {
        case .email:
            return "Email"
        case .phoneNumber:
            return "Phone Number"
        case .address:
            return "Address"
        }
    }
}
