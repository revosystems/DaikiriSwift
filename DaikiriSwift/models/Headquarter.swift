import Foundation

public class Headquarter: Daikiri, DaikiriId, Codable {
    public var id: Int?
    public var name: String
        
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    func heroes() throws -> [Hero] {
        try hasMany(\.headquarter_id)
    }
    
    func heroesWithPivot() throws -> [Hero] {
        try belongsToMany(
            pivot: HeroHeadquarterPivot.self,
            \.headquarter_id,
            \.hero_id,
            order: "level")
    }
}
