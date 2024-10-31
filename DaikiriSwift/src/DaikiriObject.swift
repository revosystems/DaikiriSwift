import CoreData

public class DaikiriObject: Daikiriable {
    @NonCodable
    public var managed:NSManagedObject?
    
    public static var entityName:String {
        String(describing: Self.self)
    }
    
}

public protocol Daikiriable {
    var managed:NSManagedObject? { get set }
    static var entityName:String { get }
}

public extension Daikiriable where Self: Codable {
        
    static func from(managed:NSManagedObject) throws -> Self {
        var object = try JSONDecoder().decode(Self.self, from: managed.toJson())
        object.managed = managed
        return object
    }
    
    static var query:Query {
        Query(entityName: Self.entityName)
    }

}
