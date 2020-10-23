import Foundation
import DaikiriSwift

public class FriendFactory : Factory2<Friend> {
    
    override public func definition() -> NSMutableDictionary {
        [
            "name"  : "Robin",
            "hero_id" : Hero.factory(),
        ]
    }
    
}

extension Friend {
    public static func factory() -> FriendFactory {
        return Friend.makeFactory() as! FriendFactory
    }
}

