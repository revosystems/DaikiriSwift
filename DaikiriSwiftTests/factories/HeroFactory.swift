import Foundation
import DaikiriSwift

public class HeroFactory : Factory2<Hero> {
    
    override public func definition() -> NSMutableDictionary {
        [
            "name" : "Ironman",
            "age"  : 44
        ]
    }
}
