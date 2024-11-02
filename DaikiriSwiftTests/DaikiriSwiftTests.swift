//
//  DaikiriSwiftTests.swift
//  DaikiriSwiftTests
//
//  Created by Jordi Puigdellívol on 13/01/2020.
//  Copyright © 2020 Jordi Puigdellívol. All rights reserved.
//

import XCTest

@testable import DaikiriSwift

class DaikiriSwiftTests: XCTestCase {

    override func setUp() {
        DaikiriCoreData.manager.useTestDatabase()
        DaikiriCoreData.manager.beginTransaction()
    }

    override func tearDown() {
        DaikiriCoreData.manager.rollback()
    }

    func test_create_and_retrieve() throws {
        let _ = Hero(id:1, name:"Spiderman", age:16)
        let _ = Hero(id:2, name:"Batman",    age:54)
        
        let results = try Hero.all().sorted { (a, b) -> Bool in
            return a.id < b.id
        }
        
        XCTAssertEqual(2, results.count)
        
        XCTAssertEqual("Spiderman", results.first!.name)
        XCTAssertEqual(16, results.first!.age)
        XCTAssertEqual(1, results.first!.id)
                
        XCTAssertEqual("Batman", results.last!.name)
        XCTAssertEqual(54, results.last!.age)
        XCTAssertEqual(2, results.last!.id)
    }
    
    func test_can_find_by_id() throws {
        
        let _ = Hero(id:1, name:"Spiderman", age:16)
        let _ = Hero(id:2, name:"Batman",    age:54)
        
        let recovered = try Hero.find(1)
        
        XCTAssertEqual("Spiderman", recovered!.name)
        XCTAssertEqual(16, recovered!.age)
        XCTAssertEqual(1, recovered!.id)
        
        let results = try Hero.all()
        XCTAssertEqual(2, results.count)    //To make sure find, does not create a new one
        
    }
    
    func test_can_find_with_multiples_ids() throws {
        
        let _ = Hero(id:1, name:"Spiderman", age:16)
        let _ = Hero(id:2, name:"Batman",    age:54)
        let _ = Hero(id:3, name:"Ironman",   age:54)
        let _ = Hero(id:4, name:"Hulk",      age:54)
        
        let all   = try Hero.all()
        let found = try Hero.find([1, 3, 6])
        
        XCTAssertEqual(4, all.count)
        XCTAssertEqual(2, found.count)
        
    }
    
    func test_can_create_from_json() throws{
        let jsonData = """
            {
                "id" : 12,
                "name" : "Ironman",
                "age"  : 44
            }
        """.data(using: .utf8)!
        let _ = try! JSONDecoder().decode(Hero.self, from:jsonData)
        
        let results = try Hero.all()
        XCTAssertEqual(1, results.count)
        XCTAssertEqual("Ironman", results.first!.name)
        XCTAssertEqual(44, results.first!.age)
        XCTAssertEqual(12, results.first!.id)
    }
    
    func test_create_updates_it_already_exists() throws {
        
        let jsonData = """
               {
                   "id" : 12,
                   "name" : "Ironman",
                   "age"  : 44
               }
           """.data(using: .utf8)!
        
        let jsonData2 = """
               {
                   "id" : 12,
                   "name" : "Ironman 2",
                   "age"  : 44
               }
           """.data(using: .utf8)!
        
        let correct  = try? JSONDecoder().decode(Hero.self, from:jsonData)
        let updated  = try? JSONDecoder().decode(Hero.self, from:jsonData2)
        
        XCTAssertNotNil(correct)
        XCTAssertNotNil(updated)
        
        let results = try Hero.all()
        XCTAssertEqual(1, results.count)
        XCTAssertEqual("Ironman 2", results.first!.name)
        XCTAssertEqual(44, results.first!.age)
        XCTAssertEqual(12, results.first!.id)
        XCTAssertEqual(1, results.count)
    }
    
    func test_can_delete_object() throws{
        
        let hero    = Hero(id:1, name:"Spiderman", age:16)
        XCTAssertEqual(1, try Hero.count())
        
        try hero.delete()
        XCTAssertEqual(0, try Hero.count())
    }
    
    func test_can_append_custom_predicate() throws {
        let a = Hero(id:1, name:"Spiderman", age:16)
        let _ = Hero(id:2, name:"Batman",    age:54)
        let _ = Hero(id:3, name:"Ironman",   age:44)
        let _ = Hero(id:4, name:"Hulk",      age:49)
        
        let predicate = NSPredicate(format:"name = %@", "Spiderman")
        let results = try Hero.query.addAndPredicate(predicate).get()
        
        XCTAssertEqual([a.name], results.map { $0.name })
    }
    
    func test_can_sort() throws {
        let _ = Hero(id:1, name:"Spiderman", age:16)
        let _ = Hero(id:2, name:"Batman",    age:54)
        let _ = Hero(id:3, name:"Ironman",   age:44)
        let _ = Hero(id:4, name:"Hulk",      age:49)
        
        let results = try Hero.query.orderBy("age").get()
        XCTAssertEqual(1, results[0].id)
        XCTAssertEqual(3, results[1].id)
        XCTAssertEqual(4, results[2].id)
        XCTAssertEqual(2, results[3].id)
    }
    
    func test_can_get_max() throws {
        let _ = Hero(id:1, name:"Spiderman", age:16)
        let _ = Hero(id:2, name:"Batman",    age:54)
        let _ = Hero(id:3, name:"Ironman",   age:44)
        let _ = Hero(id:4, name:"Hulk",      age:49)
        
        let result = try Hero.query.max("age")
        
        XCTAssertEqual(2, result!.id)
    }
    
    func test_can_get_min() throws {
        let _ = Hero(id:1, name:"Spiderman", age:16)
        let _ = Hero(id:2, name:"Batman",    age:54)
        let _ = Hero(id:3, name:"Ironman",   age:44)
        let _ = Hero(id:4, name:"Hulk",      age:49)
        
        let result = try Hero.query.min("age")
        
        XCTAssertEqual(1, result!.id)
    }
    
    func test_has_many_relationship_works() throws {
        let spiderman = Hero(id:1, name:"Spiderman", age:16)
        let batman    = Hero(id:2, name:"Batman",    age:54)
        
        let _ = Friend(id:1, name:"Flash",      hero:spiderman)
        let _ = Friend(id:2, name:"Mj",         hero:spiderman)
        
        let _ = Friend(id:3, name:"Robin",      hero:batman)
        let _ = Friend(id:4, name:"Nightwing",  hero:batman)
        let _ = Friend(id:5, name:"Batgirl",    hero:batman)
        
        XCTAssertEqual(2, try spiderman.friends().count)
        XCTAssertEqual(3, try batman.friends().count)
    }
    
    func test_belongs_to_relationship_works() throws {
        
        let batcave     = Headquarter(id: 1, name: "Batcave")
        let starkTower  = Headquarter(id: 2, name: "Stark Tower")
        
        let spiderman = Hero(id:1, name:"Spiderman", age:16)
        let batman    = Hero(id:2, name:"Batman",    age:54, headquarter: batcave)
        let ironman   = Hero(id:2, name:"Ironman",   age:54, headquarter: starkTower)
        
        XCTAssertNil(try spiderman.headquarter())
        XCTAssertEqual("Batcave",     try batman.headquarter()?.name)
        XCTAssertEqual("Stark Tower", try ironman.headquarter()?.name)
        
        XCTAssertEqual("Batman", try batcave.heroes().first?.name)
    }
    
    func test_belongs_to_many_relationship_works() throws {
        
        let batcave     = Headquarter(id: 1, name: "Batcave")
        
        let batman      = Hero(id:1, name:"Batman",    age:16)
        let robin       = Hero(id:2, name:"Robin",     age:16)
        let nightWing   = Hero(id:3, name:"NightWing", age:16)
        
        let _ = HeroHeadquarterPivot(id:1, hero:batman,    headquarter:batcave, level:100)
        let _ = HeroHeadquarterPivot(id:2, hero:robin,     headquarter:batcave, level:45)
        let _ = HeroHeadquarterPivot(id:3, hero:nightWing, headquarter:batcave, level:56)
                
        let heroes = try batcave.heroesWithPivot()
        
        XCTAssertEqual(3, heroes.count)
        let firstHero = heroes.first!
        XCTAssertEqual(45, (firstHero.pivot as! HeroHeadquarterPivot).level)
    }
    
    func test_villain_works() throws {
        
        let _ = Villain(id:1, name:"Joker", age:16).create()
        
        let fetched = try Villain.first()!
        
        XCTAssertNotNil(fetched)
        XCTAssertEqual("Joker", fetched.name)
        XCTAssertNil(fetched.hideout_id)
    }
}
