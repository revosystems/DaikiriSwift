import XCTest
import DaikiriSwift

class FactoryTest: XCTestCase {

    override func setUp() {
        DaikiriCoreData.manager.useTestDatabase()
        DaikiriCoreData.manager.beginTransaction()
    }

    override func tearDown() {
        DaikiriCoreData.manager.rollback()
    }

    func test_simple_factory_works() {
        Factory.register(Hero.self) {[
            "id"   : 12,
            "name" : "Ironman",
            "age"  : 44
        ]}
        
        let hero = Factory.make(Hero.self)!
        
        XCTAssertEqual(12,        hero.id)
        XCTAssertEqual("Ironman", hero.name)
        XCTAssertEqual(44,        hero.age)
    }
    
    func test_factory_automatically_puts_id() {
        Factory.register(Hero.self) {[
            "name" : "Ironman",
            "age"  : 44
        ]}
        
        let hero  = Factory.make(Hero.self)!
        let hero2 = Factory.make(Hero.self)!
        
        XCTAssertTrue(hero.id > 1)
        XCTAssertEqual("Ironman", hero.name)
        XCTAssertEqual(44,        hero.age)
        
        XCTAssertTrue(hero2.id > 1)
        XCTAssertEqual("Ironman", hero2.name)
        XCTAssertEqual(44,        hero2.age)
    }
    
    func test_factory_can_be_overloaded(){
        Factory.register(Hero.self) {[
            "name" : "Ironman",
            "age"  : 44
        ]}
        
        let hero  = Factory.make(Hero.self, ["name" : "Mr Potatoe"])!
        
        XCTAssertTrue(hero.id > 1)
        XCTAssertEqual("Mr Potatoe", hero.name)
        XCTAssertEqual(44,        hero.age)
    }

}
