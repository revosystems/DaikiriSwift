import Foundation
import CoreData

@objc(Friend)
public class Friend: NSManagedObject, DaikiriIdentifiable, Decodable {
    @NSManaged public var id: Int32
    @NSManaged public var hero_id: Int32
    @NSManaged public var name: String?
    
    enum CodingKeys: String, CodingKey {
       case id, name, hero_id
    }
    
    convenience public init(name:String, hero:Hero, id:Int32){
        self.init(context: DaikiriCoreData.manager.context)
        self.id         = id
        self.name       = name
        self.hero_id    = hero.id
    }
    
    required convenience public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id        = try container.decode(Int32.self,  forKey: .id)
        Self.find(id)?.delete()
        
        self.init(context: DaikiriCoreData.manager.context)
        self.id       = id
        self.name     = try container.decode(String.self, forKey: .name)
        self.hero_id  = try container.decode(Int32.self,  forKey: .hero_id)
    }
    
    public func hero() -> Hero {
        belongsTo(Hero.self, self.hero_id)!
    }
}
