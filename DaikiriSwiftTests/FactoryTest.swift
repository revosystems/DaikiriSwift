import XCTest
import DaikiriSwift
import Fakery

class FactoryTest: XCTestCase {

    override func setUp() {
        DaikiriCoreData.manager.useTestDatabase(bundle: Bundle.main)
        DaikiriCoreData.manager.beginTransaction()
    }

    override func tearDown() {
        DaikiriCoreData.manager.rollback()
    }
    
    
    func test_model_can_provide_factory() {
        let factory = Hero.factory()
        
        XCTAssertNotNil(factory)
        XCTAssertEqual("DaikiriSwiftTests.HeroFactory", "\(factory)")
    }
    
    func test_can_make_a_model_with_automatic_id() throws {
        let hero = try Hero.factory().make()
        XCTAssertNotNil(hero)
        XCTAssertEqual("Ironman", hero.name)
        XCTAssertEqual(44, hero.age)
        XCTAssertNotNil(hero.id)
    }
    
    func test_can_make_a_model_with_overrides() throws{
        let hero = try Hero.factory().make([
            "id" : 44,
            "name" : "Spiderman"
        ])
        XCTAssertNotNil(hero)
        XCTAssertEqual("Spiderman", hero.name)
        XCTAssertEqual(44, hero.age)
        XCTAssertEqual(44, hero.id)
    }
    
    func test_factory_can_have_states() throws{
        let hero = try Hero.factory().young().make()
        XCTAssertNotNil(hero)
        XCTAssertEqual("Ironman", hero.name)
        XCTAssertEqual(12, hero.age)
        XCTAssertNotNil(hero.id)
    }
    
    func test_states_can_be_overrided() throws {
        let hero = try Hero.factory().young([
            "age" : 14
        ]).make()
        XCTAssertNotNil(hero)
        XCTAssertEqual("Ironman", hero.name)
        XCTAssertEqual(14, hero.age)
        XCTAssertNotNil(hero.id)
    }
    
    func test_can_create_more_than_one() throws {
        let heroes = try Hero.factory()!.make(count:4)
        XCTAssertEqual(4, heroes.count)
    }
    
    func test_configure_is_called_for_the_model() throws {
        let hero = try Hero.factory()!.make()
        XCTAssertEqual(666, hero.headquarter_id)
    }
    
    func test_can_create_relationships_with() throws {
        let friend = try Friend.factory()!.make()
        XCTAssertNotNil(friend)
        XCTAssertNotNil(try friend.hero())
    }

}
