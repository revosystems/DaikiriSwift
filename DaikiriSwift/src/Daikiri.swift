import CoreData

/**
 [] Rename create to insert?
 [] Add upsert method?
 [] Treure els throws del query builder?
 [] Add the sort key on relationships
 [] Should relationships return an object so it can have things done on it?
 [] Add convenience keys for relationhsips
 [] Query -> min, max, wherekey.. fer-los amb keypaths?
 
 [] Update
 []
 */

enum DaikiriError: Error {
    case objectAlreadyInDatabase
    case objectNotInTheDatabase
    case morphClassNotFound(className:String)
}

public protocol DaikiriId {
    var id:Int { get }
}

open class Daikiri: Daikiriable {
    @NonCodable
    public var managed:NSManagedObject?
    
    @NonCodable
    var pivot:DaikiriId?
    
    public init(){
        
    }
    
    open var context:NSManagedObjectContext {
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

public extension Daikiriable where Self: Codable & Daikiri {
    
    //MARK: - CRUD
    @discardableResult
    func create() throws -> Self {
        if let identifiable = self as? DaikiriId, try Self.find(identifiable.id) != nil {
            throw DaikiriError.objectAlreadyInDatabase
        }
        context.performAndWait {
            toManaged()
            try? context.save()
        }
        return self
    }
    
    @discardableResult
    func save() throws -> Self {
        guard let identifiable = self as? DaikiriId, let old = try? Self.find(identifiable.id) else {
            throw DaikiriError.objectNotInTheDatabase
        }
        context.performAndWait {
            try? old.delete()
            toManaged()
            try? context.save()
        }
        return self
    }
    
    @discardableResult
    func updateOrCreate() throws -> Self {
        context.performAndWait {
            if let identifiable = self as? DaikiriId{
                if let old = try? Self.find(identifiable.id) {
                    try? old.delete()
                }
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
public extension Daikiriable where Self: Codable & Daikiri & DaikiriId {

    func fresh() throws -> Self {
        try Self.find(id)!
    }
    
    func hasMany<T:Codable & Daikiri & DaikiriId>(_ foreignKey:KeyPath<T, Int?>) throws -> [T] {
        let foreignKeyName = String(describing: foreignKey).components(separatedBy: ".").last!
        return try T.query.whereKey(foreignKeyName, id).get()
    }
    
    func hasMany<T:Codable & Daikiri & DaikiriId>(_ foreignKey:KeyPath<T, Int>) throws -> [T] {
        let foreignKeyName = String(describing: foreignKey).components(separatedBy: ".").last!
        return try T.query.whereKey(foreignKeyName, id).get()
    }
    
    func belongsTo<T:Codable & Daikiri & DaikiriId>(_ foreignKey:KeyPath<Self, Int?>) throws -> T?{
        guard let foreingId = self[keyPath: foreignKey] else { return nil }
        return try T.find(foreingId)
    }
    
    func belongsTo<T:Codable & Daikiri & DaikiriId>(_ foreignKey:KeyPath<Self, Int>) throws -> T?{
        let foreingId = self[keyPath: foreignKey]
        return try T.find(foreingId)
    }    
    
    func belongsToMany<T:Codable & Daikiri & DaikiriId, Z:Codable & Daikiri & DaikiriId>(pivot:Z.Type, _ localKey:KeyPath<Z,Int>, _ foreignKey:KeyPath<Z, Int>, order:String? = nil) throws -> [T] {
        let localKeyName = String(describing: localKey).components(separatedBy: ".").last!
        let pivots       = try pivot.query.whereKey(localKeyName, self.id).orderBy(order).get()
        
        return try pivots.compactMap {
            guard let final:T = try T.find($0[keyPath: foreignKey]) else { return nil }
            final.pivot = $0
            return final
        }
    }
    
    //https://laravel.com/docs/11.x/eloquent-relationships#polymorphic-relationships
    func morphTo(id:Int, type:String) throws -> (Codable & Daikiri & DaikiriId)? {
        let moduleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        let className = "\(moduleName).\(type)"
        guard let type = Bundle.main.classNamed(className) as? (Codable & Daikiri & DaikiriId).Type else {
            throw DaikiriError.morphClassNotFound(className: className)
        }

        return try type.find(id)
    }
    
    func morphOne<T:Codable & Daikiri & DaikiriId>(_ typeKey:KeyPath<T,String>, _ foreingKey:KeyPath<T,Int>) throws -> T? {
        let typeString          = String(describing: Self.self).components(separatedBy: ".").last!
        let typeKeyString       = String(describing: typeKey).components(separatedBy: ".").last!
        let foreingKeyString    = String(describing: foreingKey).components(separatedBy: ".").last!
        
        return try T.query.whereKey(typeKeyString, typeString)
                          .whereKey(foreingKeyString, self.id)
                          .first()
    }
    
    func morphMany<T:Codable & Daikiri & DaikiriId>(_ typeKey:KeyPath<T,String>, _ foreingKey:KeyPath<T,Int>) throws -> [T] {
        let typeString          = String(describing: Self.self).components(separatedBy: ".").last!
        let typeKeyString       = String(describing: typeKey).components(separatedBy: ".").last!
        let foreingKeyString    = String(describing: foreingKey).components(separatedBy: ".").last!
        
        return try T.query.whereKey(typeKeyString, typeString)
                          .whereKey(foreingKeyString, self.id)
                          .get()
    }
    
    func morphToMany<T:Codable & Daikiri & DaikiriId, PIVOT:Codable & Daikiri & DaikiriId>(
        _ pivotType:PIVOT.Type,
        foreingKey:KeyPath<PIVOT, Int>,
        relatedKey:KeyPath<PIVOT, Int>,
        relatedType:KeyPath<PIVOT, String>
    ) throws -> [T] {
     
        let typeString        = String(describing: Self.self).components(separatedBy: ".").last!
        let relatedKeyString  = String(describing: relatedKey).components(separatedBy: ".").last!
        let relatedTypeString = String(describing: relatedType).components(separatedBy: ".").last!
        
        let pivots = try pivotType.query
            .whereKey(relatedKeyString, self.id)
            .whereKey(relatedTypeString, typeString)
            .get()

        return try pivots.compactMap {
            let r = try T.find($0[keyPath: foreingKey])
            r?.pivot = $0
            return r
        }
    }
    
    func morphedByMany<T:Codable & Daikiri & DaikiriId, PIVOT:Codable & Daikiri & DaikiriId>(
        _ pivotType:PIVOT.Type,
        foreingKey:KeyPath<PIVOT, Int>,
        relatedKey:KeyPath<PIVOT, Int>,
        relatedType:KeyPath<PIVOT, String>
    ) throws -> [T] {
        let typeString         = String(describing: T.self).components(separatedBy: ".").last!
        let foreingKeyString   = String(describing: foreingKey).components(separatedBy: ".").last!
        let relatedTypeString  = String(describing: relatedType).components(separatedBy: ".").last!
        
        let pivots = try pivotType.query
            .whereKey(foreingKeyString, self.id)
            .whereKey(relatedTypeString, typeString)
            .get()

        return try pivots.compactMap {
            let r = try T.find($0[keyPath: relatedKey])
            r?.pivot = $0
            return r
        }
    }
    
}
