import CoreData

class Villain {

    //var managed:NSManagedObject
    
    var id:Int!
    
    static func fetch() throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Hero")
        let result = try DaikiriCoreData.manager.context.fetch(request).first!
        
        print(result)

        let villain = Villain()
        villain.id = result.value(forKey: "id") as? Int
        
        
        print(villain)
        
    }
    
    
    
}
