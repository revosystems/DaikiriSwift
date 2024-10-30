import CoreData

class Villain {

    //var managed:NSManagedObject
    
    
    static func fetch() throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Hero")
        let result = try DaikiriCoreData.manager.context.fetch(request)
        
        print(result)
        
    }
    
    
    
}
