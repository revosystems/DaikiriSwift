struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
