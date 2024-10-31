import CoreData

public class Query {
    
    let fetchRequest:NSFetchRequest<NSManagedObject>
    let context:NSManagedObjectContext
    
    public var andPredicates   = [NSPredicate]()
    var sortPredicates  = [NSSortDescriptor]()
    
    init(entityName:String, context:NSManagedObjectContext = DaikiriCoreData.manager.context) {
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        self.context = context
    }
    
    public func doQuery() throws -> [NSManagedObject] {
        try context.fetch(fetchRequest)
    }
    
    @discardableResult
    public func take(_ howMany:Int) -> Self{
        fetchRequest.fetchLimit = howMany
        return self
    }
    
    @discardableResult
    public func skip(_ howMany:Int) -> Self{
        fetchRequest.fetchOffset = howMany
        return self
    }
        
    @discardableResult
    public func whereKey<Z:CVarArg>(_ key:String, _ value:Z) -> Self{
        if value is Int || value is Int32 || value is Int16 {
            andPredicates.append(NSPredicate(format:"%K=%d", key, value))
        } else {
            andPredicates.append(NSPredicate(format:"%K=%@", key, value))
        }
        return self
    }
    
    @discardableResult
    public func whereIn<Z>(_ key:String, _ values:[Z]) -> Self{
        andPredicates.append(NSPredicate(format:"%K IN %@", key, values))
        return self
    }
    
    @discardableResult
    public func orderBy(_ key:String?, ascendig:Bool = true) -> Self {
        guard key != nil else { return self }
        sortPredicates.append(NSSortDescriptor(key: key, ascending: ascendig))
        return self
    }
    
    @discardableResult
    public func addAndPredicate(_ predicate:NSPredicate) -> Self {
        andPredicates.append(predicate)
        return self
    }
    
    public func get<T:DaikiriObject & Codable>() throws -> [T] {
        try doQuery().map {
            try T.from(managed: $0)
        }
    }
    
    public func first<T:DaikiriObject & Codable>() throws -> T? {
        take(1)
        return try get().first
    }
    
    private func preparePredicates(){
        fetchRequest.predicate       = NSCompoundPredicate(andPredicateWithSubpredicates: andPredicates)
        fetchRequest.sortDescriptors = sortPredicates
    }
    
    func count() -> Int {
        preparePredicates()
        do {
            return try DaikiriCoreData.manager.context.count(for: fetchRequest)
        } catch let error as NSError {
            print("Couldn't load \(error), \(error.userInfo)")
            return 0
        }
    }
    
    public func max<T:DaikiriObject & Codable>(_ key:String) throws -> T? {
        try orderBy(key, ascendig: false).first()
    }
    
    public func min<T:DaikiriObject & Codable>(_ key:String) throws -> T? {
        try orderBy(key, ascendig: true).first()
    }
    
}
