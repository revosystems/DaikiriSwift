import Foundation

public class HeroHeadquarterPivot: Daikiri, DaikiriId, Codable {    
    public var id: Int?
    public var hero_id:   Int
    public var headquarter_id: Int
    public var level:   Int
    
    init(id: Int, hero_id: Int, headquarter_id: Int, level: Int) {
        self.id = id
        self.hero_id = hero_id
        self.headquarter_id = headquarter_id
        self.level = level
    }
    
    convenience init(id: Int, hero: Hero, headquarter: Headquarter, level: Int) {
        self.init(id: id, hero_id: hero.id!, headquarter_id: headquarter.id!, level: level)
    }
}
