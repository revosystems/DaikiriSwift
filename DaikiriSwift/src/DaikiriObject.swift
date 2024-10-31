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
            let managed = toManaged()
            try? context.save()
        }
    }
    
    private func toManaged() -> NSManagedObject {
        if let managed {
            context.delete(managed)
        }
        
        let newManaged = NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: context)
        
        let mirror = Mirror(reflecting: self)
        mirror.children.forEach { (label, value) in
            newManaged.setValue(value, forKey: label!)
        }
        self.managed = managed
        
        return newManaged
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
    
    /**
     Finds the object with id
     */
    static func find(_ id:Int) throws -> Self? {
        try query.whereKey("id", Int(id)).first()
    }
    
    /** Finds all the objects that have the id in ids */
    static func find(_ ids:[Int]) throws -> [Self] {
        try query.whereIn("id", ids).get()
    }
    
    /** Deletes the object with id */
    static func delete(_ id:Int) throws {
        try query.whereKey("id", id).first()?.delete()
    }
    
    /** Deletes the objects that its id is in ids*/
    static func delete(_ ids:[Int]) throws {
        try query.whereIn("id", ids).get().forEach { $0.delete() }
    }
    
    /** Fetches all the records of the class */
    static func all(_ orderBy:String? = nil) throws -> [Self] {
        try query.orderBy(orderBy).get()
    }
    
    /** Fetches the count of records of the class*/
    static func count() throws -> Int {
        try query.count()
    }
    
    /** Deletes all the records of the object */
    static func truncate() {
        DaikiriCoreData.manager.truncate(entityName)
    }
    
    // MARK: Object's
    /** Deletes the object from the coredata*/
    func delete() {
        DaikiriCoreData.manager.context.delete(managed)
    }
}
