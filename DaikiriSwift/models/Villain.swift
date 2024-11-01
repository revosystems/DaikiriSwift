import CoreData

public class Villain : DaikiriObject, DaikiriId, Codable   {
    
    public var id:Int
    public var name:String
    public var age:Int
    
    public var hideout_id:Int?
    
    init(id:Int, name:String, age:Int, hideout_id:Int? = nil){
        self.id = id
        self.name = name
        self.age = age
        self.hideout_id = hideout_id
    }
    
    convenience init(id:Int, name:String, age:Int, hideout:Hideout? = nil){
        self.init(id: id, name: name, age: age, hideout_id: hideout?.id)
    }
    
    public func friends() throws -> [VillainFriend] {
        try hasMany(VillainFriend.self, "villain_id")
    }
    
    public func hideout() throws -> Hideout? {
        try belongsTo(Hideout.self, "hideout_id")
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

public class Hideout : DaikiriObject, DaikiriId, Codable {
    public var id:Int
    public var name:String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    public func villains() throws -> [Villain] {
        try hasMany(Villain.self, "hideout_id")
    }
}
