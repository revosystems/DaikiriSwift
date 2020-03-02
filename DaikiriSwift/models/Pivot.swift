import Foundation
import CoreData

@objc(HeroHeadquarterPivot)
public class HeroHeadquarterPivot: NSManagedObject, DaikiriIdentifiable, Decodable {
    @NSManaged public var id: Int32
    @NSManaged public var hero_id:   Int32
    @NSManaged public var headquarter_id: Int32
    @NSManaged public var level:   Int16
    
    enum CodingKeys: String, CodingKey {
       case id, hero_id, headquarter_id, level
    }
    
    convenience init(id:Int32, hero:Hero, headquarter:Headquarter, level:Int16){
        self.init(context: DaikiriCoreData.manager.context)
        self.id             = id
        self.hero_id        = hero.id
        self.headquarter_id = headquarter.id
        self.level          = level
    }
    
    required convenience public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id        = try container.decode(Int32.self,  forKey: .id)
        Self.find(id)?.delete()
        
        self.init(context: DaikiriCoreData.manager.context)
        self.id             = id
        self.hero_id        = try container.decode(Int32.self, forKey: .hero_id)
        self.headquarter_id = try container.decode(Int32.self, forKey: .headquarter_id)
        self.level          = try container.decode(Int16.self, forKey: .level)
    }
}
