import CoreData

class Villain : DaikiriObject, Codable  {
    
    var id:Int
    var age:Int
    var name:String
    var headquarter_id:Int?
    
    static func fetch() throws -> Villain? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Hero")
        let result = try DaikiriCoreData.manager.context.fetch(request).first!
        
        return try from(managed: result)
    }
}


