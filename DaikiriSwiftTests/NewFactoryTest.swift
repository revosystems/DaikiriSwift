import XCTest
import DaikiriSwift
import Fakery

class NewFactoryTest: XCTestCase {

    override func setUp() {
        DaikiriCoreData.manager.useTestDatabase()
        DaikiriCoreData.manager.beginTransaction()
    }

    override func tearDown() {
        DaikiriCoreData.manager.rollback()
    }
    
    
    func test_model_can_provide_factory() {
        let factory = Hero.factory()
        
        XCTAssertNotNil(factory)
        XCTAssertEqual("DaikiriSwiftTests.HeroFactory", "\(factory!)")
    }
    
    func test_can_make_a_model() {
        let hero = Hero.factory()!.make()
        XCTAssertNotNil(hero)
        XCTAssertEqual("Ironman", hero.name)
        XCTAssertEqual(44, hero.age)
        XCTAssertNotNil(hero.id)
    }
    
    func test_can_make_a_model_with_overrides() {
        let hero = Hero.factory()!.make([
            "id" : 44,
            "name" : "Spiderman"
        ])
        XCTAssertNotNil(hero)
        XCTAssertEqual("Spiderman", hero.name)
        XCTAssertEqual(44, hero.age)
        XCTAssertEqual(44, hero.id)
    }

}
