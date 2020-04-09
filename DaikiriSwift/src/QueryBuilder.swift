import Foundation
import CoreData

public class QueryBuilder<T:NSManagedObject>{
    
    let fetchRequest:NSFetchRequest<T>
    
    var andPredicates   = [NSPredicate]()
    var sortPredicates  = [NSSortDescriptor]()
    
    public init(_ fetchRequest:NSFetchRequest<T>){
        self.fetchRequest = fetchRequest
    }
        
    func doQuery() -> [T]{
        preparePredicates()
        do {
            return try DaikiriCoreData.manager.context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Couldn't load \(error), \(error.userInfo)")
            return []
        }
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
    public func whereKey<T:CVarArg>(_ key:String, _ value:T) -> Self{
        if value is Int || value is Int32 || value is Int16 {
            andPredicates.append(NSPredicate(format:"%K=%d", key, value))
        } else {
            andPredicates.append(NSPredicate(format:"%K=%@", key, value))
        }
        return self
    }
    
    @discardableResult
    public func whereIn<T>(_ key:String, _ values:[T]) -> Self{
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
    
    public func get() -> [T]{
        doQuery()
    }
    
    public func first() -> T? {
        take(1)
        return doQuery().first
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
    
    public func max(_ key:String) -> T? {
        orderBy(key, ascendig: false).first()
    }
    
    public func min(_ key:String) -> T? {
        orderBy(key, ascendig: true).first()
    }
    
}
