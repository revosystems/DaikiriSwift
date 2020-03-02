import Foundation
import CoreData

@objc(Headquarter)
public class Headquarter: NSManagedObject, DaikiriWithPivot {
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    
    public var pivot: DaikiriIdentifiable?
    
    enum CodingKeys: String, CodingKey {
          case id, name
       }
       
   convenience public init(name:String, id:Int32){
       self.init(context: DaikiriCoreData.manager.context)
       self.id         = id
       self.name       = name
   }
   
   required convenience public init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       let id        = try container.decode(Int32.self,  forKey: .id)
       Self.find(id)?.delete()
       
       self.init(context: DaikiriCoreData.manager.context)
       self.id       = id
       self.name     = try container.decode(String.self, forKey: .name)
   }
    
    func heroes() -> [Hero] {
        hasMany(Hero.self, "headquarter_id")
    }
    
    func heroesWithPivot() -> [Hero] {
        belongsToMany(Hero.self, HeroHeadquarterPivot.self, "headquarter_id", \.hero_id, order: "level")
    }
}
