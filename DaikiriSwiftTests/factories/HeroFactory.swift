import Foundation
import DaikiriSwift

public class HeroFactory : Factory2<Hero> {
    
    override public func definition() -> NSMutableDictionary {
        [
            "name" : "Ironman",
            "age"  : 44
        ]
    }
    
    func young(_ overrides:NSDictionary = [:]) -> Self {
        state([
            "age" : 12
        ], overrides:overrides)
    }
    
    override public func afterMaking(_ model:Hero){
        if model.headquarter_id == 0 {
            model.headquarter_id = 666
        }
    }
}


extension Hero {
    public static func factory() -> HeroFactory {
        return Hero.makeFactory() as! HeroFactory
    }
}
