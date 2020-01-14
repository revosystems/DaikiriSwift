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
        DaikiriCoreData.manager.beginTransaction()
    }

    override func tearDown() {
        DaikiriCoreData.manager.rollback()
    }

    func test_create_and_retrieve() {
        let _ = Hero(name:"Spiderman", age:16, id:1)
        let _ = Hero(name:"Batman",    age:54, id:2)
        
        let results = Hero.all().sorted { (a, b) -> Bool in
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
    
    func test_can_find_by_id(){
        
        let _ = Hero(name:"Spiderman", age:16, id:1)
        let _ = Hero(name:"Batman",    age:54, id:2)
        
        let recovered = Hero.find(1)
        
        XCTAssertEqual("Spiderman", recovered!.name)
        XCTAssertEqual(16, recovered!.age)
        XCTAssertEqual(1, recovered!.id)
        
        let results = Hero.all()
        XCTAssertEqual(2, results.count)    //To make sure find, does not create a new one
        
    }
    
    func test_can_find_with_multiples_ids(){
        
        let _ = Hero(name:"Spiderman", age:16, id:1)
        let _ = Hero(name:"Batman",    age:54, id:2)
        let _ = Hero(name:"Ironman",   age:54, id:3)
        let _ = Hero(name:"Hulk",      age:54, id:4)
        
        let all   = Hero.all()
        let found = Hero.find([1, 3, 6])
        
        XCTAssertEqual(4, all.count)
        XCTAssertEqual(2, found.count)
        
    }
    
    func test_can_create_from_json(){
        let jsonData = """
            {
                "id" : 12,
                "name" : "Ironman",
                "age"  : 44
            }
        """.data(using: .utf8)!
        let _ = try! JSONDecoder().decode(Hero.self, from:jsonData)
        
        let results = Hero.all()
        XCTAssertEqual(1, results.count)
        XCTAssertEqual("Ironman", results.first!.name)
        XCTAssertEqual(44, results.first!.age)
        XCTAssertEqual(12, results.first!.id)
    }
    
    func test_create_updates_it_already_exists(){
        
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
        
        let results = Hero.all()
        XCTAssertEqual(1, results.count)
        XCTAssertEqual("Ironman 2", results.first!.name)
        XCTAssertEqual(44, results.first!.age)
        XCTAssertEqual(12, results.first!.id)
        XCTAssertEqual(1, results.count)
    }
    
    func test_can_delete_object(){
        
        let hero    = Hero(name:"Spiderman", age:16, id:1)
        XCTAssertEqual(1, Hero.count())
        
        hero.delete()
        XCTAssertEqual(0, Hero.count())
    }
    
    func test_can_sort(){
        let _ = Hero(name:"Spiderman", age:16, id:1)
        let _ = Hero(name:"Batman",    age:54, id:2)
        let _ = Hero(name:"Ironman",   age:44, id:3)
        let _ = Hero(name:"Hulk",      age:49, id:4)
        
        let results = Hero.query.orderBy("age").get()
        XCTAssertEqual(1, results[0].id)
        XCTAssertEqual(3, results[1].id)
        XCTAssertEqual(4, results[2].id)
        XCTAssertEqual(2, results[3].id)
    }
    
    func test_has_many_relationship_works(){
        let spiderman = Hero(name:"Spiderman", age:16, id:1)
        let batman    = Hero(name:"Batman",    age:54, id:2)
        
        let _ = Friend(name:"Flash",      hero:spiderman, id:1)
        let _ = Friend(name:"Mj",         hero:spiderman, id:2)
        
        let _ = Friend(name:"Robin",      hero:batman, id:3)
        let _ = Friend(name:"Nightwing",  hero:batman, id:4)
        let _ = Friend(name:"Batgirl",    hero:batman, id:5)
        
        XCTAssertEqual(2, spiderman.friends().count)
        XCTAssertEqual(3, batman.friends().count)
    }
    
    func test_belongs_to_relationship_works(){
        
        let batcave     = Headquarter(name: "Batcave", id: 1)
        let starkTower  = Headquarter(name: "Stark Tower", id: 2)
        
        let spiderman = Hero(name:"Spiderman", age:16, id:1)
        let batman    = Hero(name:"Batman",    age:54, id:2, headquarter: batcave)
        let ironman   = Hero(name:"Ironman",    age:54, id:2, headquarter: starkTower)
        
        XCTAssertNil(spiderman.headquarter())
        XCTAssertEqual("Batcave",     batman.headquarter()?.name)
        XCTAssertEqual("Stark Tower", ironman.headquarter()?.name)
        
        XCTAssertEqual("Batman", batcave.heroes().first?.name)
    }
}
