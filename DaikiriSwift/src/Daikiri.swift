import Foundation
import CoreData

@available(*, deprecated, renamed: "DaikiriId", message: "Use the new class")
public protocol DaikiriIdentifiable: NSManagedObject {
    var id:Int32 { get }
    static var entityName:String { get }    //So it can be overrided in final class
}

@available(*, deprecated, renamed: "DaikiriId", message: "Use the new class")
public protocol DaikiriWithPivot: DaikiriIdentifiable {
    var pivot:DaikiriIdentifiable? { get set }
}

enum DaikiriError: Error {
    case objectAlreadyInDatabase
    case morphClassNotFound(className:String)
}

@available(*, deprecated, renamed: "DaikiriId", message: "Use the new class")
public extension DaikiriIdentifiable {
    
    static var query:QueryBuilder<Self>{
        QueryBuilder(Self.fetchRequest())
    }
    
    static var entityName:String {
        String(describing: Self.self)
    }
    
    static func fetchRequest() -> NSFetchRequest<Self> {
        NSFetchRequest<Self>(entityName: self.entityName)
    }
    
    /**
     Finds the object with id
     */
    static func find(_ id:Int32) -> Self? {
        self.query.whereKey("id", Int(id)).first()
    }
    
    /** Finds all the objects that have the id in ids */
    static func find(_ ids:[Int32]) -> [Self] {
        self.query.whereIn("id", ids).get()
    }
    
    /** Deletes the object with id */
    static func delete(_ id:Int32){
        self.query.whereKey("id", Int(id)).first()?.delete()
    }
    
    /** Deletes the objects that its id is in ids*/
    static func delete(_ ids:[Int32]) {
        self.query.whereIn("id", ids).get().forEach { $0.delete() }
    }
    
    /** Fetches all the records of the class */
    static func all(_ orderBy:String? = nil) -> [Self] {
        self.query.orderBy(orderBy).get()
    }
    
    /** Fetches the count of records of the class*/
    static func count() -> Int {
        self.query.count()
    }
    
    /** Deletes all the records of the object */
    static func truncate() {
        DaikiriCoreData.manager.truncate(entityName)
    }
    
    // MARK: Object's
    /** Deletes the object from the coredata*/
    func delete() {
        DaikiriCoreData.manager.context.delete(self)
    }
    
    // MARK: Relationships
    func hasMany<T:DaikiriIdentifiable>(_ type:T.Type, _ foreignKey:String) -> [T]{
        type.query.whereKey(foreignKey, Int(self.id)).get()
    }
    
    func belongsTo<T:DaikiriIdentifiable, T2:CVarArg>(_ type:T.Type, _ foreignKeyId:T2) -> T?{
        type.query.whereKey("id", foreignKeyId).first()
    }
    
    func belongsToMany<T:DaikiriWithPivot, Z:DaikiriIdentifiable>(_ type:T.Type, _ pivotType:Z.Type, _ localKey:String, _ foreignKey:KeyPath<Z, Int32>, order:String? = nil) -> [T]{
        let pivots      = pivotType.query.whereKey(localKey, self.id).orderBy(order).get()
        return pivots.compactMap {
            guard let final:T = type.find($0[keyPath: foreignKey]) else { return nil }
            final.pivot = $0
            return final
        }
    }
    
}

