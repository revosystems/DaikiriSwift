import Foundation
import CoreData

@objc(Hero)
public class Hero: NSManagedObject, DaikiriIdentifiable, Decodable {
    @NSManaged public var id:   Int32
    @NSManaged public var name: String?
    @NSManaged public var age:  Int16
    
    enum CodingKeys: String, CodingKey {
       case id, name, age
    }
    
    convenience public init(name:String, age:Int16, id:Int32){
        self.init(context: DaikiriCoreData.manager.context)
        self.id     = id
        self.name   = name
        self.age    = age
    }
    
    required convenience public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id        = try container.decode(Int32.self,  forKey: .id)
        Self.find(id)?.delete()
        
        self.init(context: DaikiriCoreData.manager.context)
        self.id       = id
        self.name     = try container.decode(String.self, forKey: .name)
        self.age      = try container.decode(Int16.self,  forKey: .age)
    }
}
