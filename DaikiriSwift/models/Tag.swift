import Foundation

public class Tag : DaikiriObject, Codable, DaikiriId {
    public let id: Int
    public let name:String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public class Taggable : DaikiriObject, Codable, DaikiriId {
    public let id: Int
    public let tag_id:Int
    public let taggable_id:Int
    public let taggable_type:String
    
    public init(id: Int, tag_id:Int, taggable_id: Int, taggable_type: String) {
        self.id = id
        self.tag_id = tag_id
        self.taggable_id = taggable_id
        self.taggable_type = taggable_type
    }
    
    convenience public init(id:Int, tag:Tag, taggable:DaikiriId){
        self.init(
            id: id,
            tag_id: tag.id,
            taggable_id: taggable.id,
            taggable_type: String(describing: taggable).components(separatedBy: ".").last!
        )
    }
}
