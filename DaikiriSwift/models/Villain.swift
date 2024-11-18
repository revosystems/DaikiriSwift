import CoreData

public class Villain : Daikiri, DaikiriId, Codable   {
    
    public var id:Int
    public var name:String
    public var age:Int
    
    public var hideout_id:Int?
    
    public required init(id:Int, name:String, age:Int, hideout_id:Int? = nil){
        self.id = id
        self.name = name
        self.age = age
        self.hideout_id = hideout_id
    }
    
    convenience init(id:Int, name:String, age:Int, hideout:Hideout?){
        self.init(id: id, name: name, age: age, hideout_id: hideout?.id)
    }
    
    public func friends() throws -> [VillainFriend] {
        try hasMany(\.villain_id)
    }
    
    public func hideout() throws -> Hideout? {
        try belongsTo(\.hideout_id)
    }
    
    public func image() throws -> Image? {
        try morphOne(\.imageable_type, \.imageable_id)
    }
    
    public func images() throws -> [Image] {
        try morphMany(\.imageable_type, \.imageable_id)
    }
    
    public func tags() throws -> [Tag] {
        try morphToMany(
            Taggable.self,
            foreingKey: \.tag_id,
            relatedKey: \.taggable_id,
            relatedType: \.taggable_type
        )
    }
}

public class VillainFriend : Daikiri, DaikiriId, Codable {
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
    
    public func tags() throws -> [Tag] {
        try morphToMany(
            Taggable.self,
            foreingKey: \.tag_id,
            relatedKey: \.taggable_id,
            relatedType: \.taggable_type
        )
    }
    
}

public class Hideout : Daikiri, DaikiriId, Codable {
    public var id:Int
    public var name:String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    public func villains() throws -> [Villain] {
        try hasMany(\.hideout_id)
    }
    
    public func villainsWithPivot() throws -> [Villain] {
        try belongsToMany(pivot:HideoutVillain.self, \.hideout_id, \.villain_id)
    }
}


class HideoutVillain : Daikiri, DaikiriId, Codable {
    public var id:Int
    public var hideout_id:Int
    public var villain_id:Int
    public var level:Int
    
    init(id:Int, hideout_id:Int, villain_id:Int, level:Int){
        self.id = id
        self.hideout_id = hideout_id
        self.villain_id = villain_id
        self.level = level
    }
    
    convenience init(id:Int, hideout:Hideout, villain:Villain, level:Int){
        self.init(id: id, hideout_id: hideout.id, villain_id: villain.id, level: level)
    }
}
