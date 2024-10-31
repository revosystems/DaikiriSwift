import CoreData

public class Villain : DaikiriObject, Codable  {
    
    var id:Int
    var name:String
    var age:Int
    
    var headquarter_id:Int?
    
    init(id:Int, name:String, age:Int){
        self.id = id
        self.name = name
        self.age = age
    }
    
}
