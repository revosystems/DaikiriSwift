import CoreData

/**
 [] Rename create to insert?
 [] Add upsert method?
 [] Treure els throws del query builder?
 */

public protocol DaikiriId {
    var id:Int { get }
}

public class DaikiriObject: Daikiriable {
    @NonCodable
    public var managed:NSManagedObject?
    
    var context:NSManagedObjectContext {
        DaikiriCoreData.manager.context
    }
    
    public static var entityName:String {
        String(describing: Self.self)
    }

    
    @discardableResult
    public func toManaged() -> NSManagedObject {
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
    
}

public extension Daikiriable where Self: Codable & DaikiriObject {
    //MARK: - CRUD
    @discardableResult
    func create() -> Self {
        context.performAndWait {
            if let identifiable = self as? DaikiriId {
                let old = try? Self.find(identifiable.id)
                try? old?.delete()
            }
        
            toManaged()
            try? context.save()
        }
        return self
    }
    
    /** Deletes the object from the coredata*/
    func delete() throws {
        if let managed {
            context.delete(managed)
        } else if let identifiable = self as? DaikiriId {
            try Self.find(identifiable.id)?.delete()
        }
    }
    
    //MARK: - Query Builder
    static var query:Query<Self> {
        Query(entityName: Self.entityName)
    }
    
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
        try query.whereIn("id", ids).get().forEach { try $0.delete() }
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
    static func truncate(daikiriCoreData:DaikiriCoreData = DaikiriCoreData.manager ) {
        daikiriCoreData.truncate(entityName)
    }
}

// MARK: Relationships
public extension Daikiriable where Self: Codable & DaikiriObject & DaikiriId {
    func hasMany<T:Codable & DaikiriObject & DaikiriId>(_ type:T.Type, _ foreignKey:String) throws -> [T]{
        try type.query.whereKey(foreignKey, id).get()
    }
    
    func belongsTo<T:DaikiriIdentifiable, T2:CVarArg>(_ type:T.Type, _ foreignKeyId:T2) -> T?{
        type.query.whereKey("id", foreignKeyId).first()
    }
    
    /*func belongsToMany<T:DaikiriWithPivot, Z:DaikiriId>(_ type:T.Type, _ pivotType:Z.Type, _ localKey:String, _ foreignKey:KeyPath<Z, Int32>, order:String? = nil) -> [T]{
        let pivots      = pivotType.query.whereKey(localKey, self.id).orderBy(order).get()
        return pivots.compactMap {
            guard let final:T = type.find($0[keyPath: foreignKey]) else { return nil }
            final.pivot = $0
            return final
        }
    }*/
}
