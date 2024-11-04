import Foundation
import CoreData

public class Hero: Daikiri, Codable, DaikiriId, Factoriable {
    
    public var id:   Int
    public var name: String
    public var age:  Int
    public var headquarter_id:  Int?
    
    init(id: Int, name: String, age: Int, headquarter_id: Int? = nil) {
        self.id = id
        self.name = name
        self.age = age
        self.headquarter_id = headquarter_id
    }
    
    convenience init(id: Int, name: String, age: Int, headquarter: Headquarter) {
        self.init(id: id, name: name, age: age, headquarter_id: headquarter.id)        
    }
    
    public func friends() throws -> [Friend] {
        try hasMany(\.hero_id)
    }
    
    public func headquarter() throws -> Headquarter? {
        try belongsTo(\.headquarter_id)
    }
}
