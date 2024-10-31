import CoreData

public class DaikiriObject: Daikiriable {
    @NonCodable
    public var managed:NSManagedObject?
    
    var context:NSManagedObjectContext {
        DaikiriCoreData.manager.context
    }
    
    public static var entityName:String {
        String(describing: Self.self)
    }
    
    func create() {
        context.performAndWait {
            let managed = NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: context)
            
            let mirror = Mirror(reflecting: self)
            mirror.children.forEach { (label, value) in
                managed.setValue(value, forKey: label!)
            }
            try? context.save()
        }
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


public extension Daikiriable where Self: Codable & DaikiriObject {
    
    static func first() throws -> Self? {
        try query.first()
    }
}
