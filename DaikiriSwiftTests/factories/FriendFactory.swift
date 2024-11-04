import Foundation
import DaikiriSwift

public class FriendFactory : Factory<Friend> {
    
    override public func definition() -> NSMutableDictionary {
        [
            "name"  : "Robin",
            "hero_id" : {
                try! Hero.factory().make().id
            },
        ]
    }
    
}

extension Friend {
    public static func factory() -> FriendFactory {
        return Friend.makeFactory() as! FriendFactory
    }
}

