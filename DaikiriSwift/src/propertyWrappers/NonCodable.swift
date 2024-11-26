@propertyWrapper
public struct NonCodable<Value> {
    private var value: Value?
    
    public init(wrappedValue: Value?) {
        self.value = wrappedValue
    }
    
    public var wrappedValue: Value? {
        get { value }
        set { self.value = newValue }
    }
}

extension NonCodable: Codable {
    public func encode(to encoder: Encoder) throws {
        // Skip encoding the wrapped value.
    }
    
    public init(from decoder: Decoder) throws {
        // The wrapped value is simply initialised to nil when decoded.
        self.value = nil
    }
}
