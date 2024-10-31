import CoreData

public class DaikiriObject: Daikiriable {
    @NonCodable
    public var managed:NSManagedObject?
}

public protocol Daikiriable {
    var managed:NSManagedObject? { get set }
}

public extension Daikiriable where Self: Codable {
        
    static func from(managed:NSManagedObject) throws -> Self {
        var object = try JSONDecoder().decode(Self.self, from: managed.toJson())
        object.managed = managed
        return object
    }
}
