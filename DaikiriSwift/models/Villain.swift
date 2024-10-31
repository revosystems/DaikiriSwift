import CoreData

public class Villain : DaikiriObject, DaikiriId, Codable   {
    
    public var id:Int
    public var name:String
    public var age:Int
    
    public var headquarter_id:Int?
    
    init(id:Int, name:String, age:Int){
        self.id = id
        self.name = name
        self.age = age
    }
    
    public func friends() throws -> [VillainFriend] {
        try hasMany(VillainFriend.self, "villain_id")
    }
    
}

public class VillainFriend : DaikiriObject, DaikiriId, Codable {
    public var id:Int
    public var name:String
    public var villain_id:Int
    
    init(id:Int, name:String, age:Int, villain_id:Int){
        self.id = id
        self.name = name
        self.villain_id = villain_id
    }
    
    convenience init(id:Int, name:String, age:Int, villain:Villain){
        self.init(id: id, name: name, age: age, villain_id: villain.id)
    }
    
}
