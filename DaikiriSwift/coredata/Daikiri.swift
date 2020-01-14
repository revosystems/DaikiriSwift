import Foundation
import CoreData

public protocol DaikiriIdentifiable {
    var id:Int32 { get }
}

enum DaikiriError: Error {
    case objectAlreadyInDatabase
}

public extension DaikiriIdentifiable where Self:NSManagedObject{
    
    static var query:QueryBuilder<Self>{
        QueryBuilder(Self.fetchRequest())
    }
    
    static func fetchRequest() -> NSFetchRequest<Self> {
        return NSFetchRequest<Self>(entityName: String(describing: Self.self))
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
    
    // MARK: Object's
    /** Deletes the object from the coredata*/
    func delete() {
        DaikiriCoreData.manager.context.delete(self)
    }
    
    // MARK: Relationships
    func hasMany<T:DaikiriIdentifiable>(_ type:T.Type, _ foreignKey:String) -> [T] where T:NSManagedObject{
        type.query.whereKey(foreignKey, Int(self.id)).get()
    }
    
    func belongsTo<T:DaikiriIdentifiable, T2:CVarArg>(_ type:T.Type, _ foreignKeyId:T2) -> T? where T:NSManagedObject{
        type.query.whereKey("id", foreignKeyId).first()
    }
    
}

