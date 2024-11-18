import Foundation

public class Friend: Daikiri, DaikiriId, Codable, Factoriable {
    public var id: Int
    public var hero_id: Int
    public var name: String
    
    public required init(id: Int, hero_id: Int, name: String) {
        self.id = id
        self.hero_id = hero_id
        self.name = name
    }
    
    convenience init(id:Int, name:String, hero:Hero) {
        self.init(id: id, hero_id: hero.id, name: name)
    }
    
    
    public func hero() throws -> Hero? {
        try belongsTo(\.hero_id)
    }
}
