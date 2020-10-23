import Foundation
import CoreData

@objc(Hero)
public class Hero: NSManagedObject, Factoriable, DaikiriWithPivot {
    
    @NSManaged public var id:   Int32
    @NSManaged public var name: String?
    @NSManaged public var age:  Int16
    @NSManaged public var headquarter_id:  Int32
    
    public var pivot: DaikiriIdentifiable?
    
    enum CodingKeys: String, CodingKey {
       case id, name, age, headquarter_id
    }
    
    convenience public init(name:String, age:Int16, id:Int32, headquarter:Headquarter? = nil){
        self.init(context: DaikiriCoreData.manager.context)
        self.id     = id
        self.name   = name
        self.age    = age
        self.headquarter_id = headquarter?.id ?? 0
    }
    
    required convenience public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id        = try container.decode(Int32.self,  forKey: .id)
        Self.find(id)?.delete()
        
        self.init(context: DaikiriCoreData.manager.context)
        self.id             = id
        self.name           = try container.decode(String.self, forKey: .name)
        self.age            = try container.decode(Int16.self,  forKey: .age)
        self.headquarter_id = try container.decodeIfPresent(Int32.self,  forKey: .headquarter_id) ?? 0
    }
    
    public func friends() -> [Friend] {
        hasMany(Friend.self, "hero_id")
    }
    
    public func headquarter() -> Headquarter?{
        belongsTo(Headquarter.self, self.headquarter_id)
    }
}
