//
//  DaikiriSwiftTests.swift
//  DaikiriSwiftTests
//
//  Created by Jordi Puigdellívol on 13/01/2020.
//  Copyright © 2020 Jordi Puigdellívol. All rights reserved.
//

import XCTest

@testable import DaikiriSwift

class DaikiriSwiftTestsV2: XCTestCase {

    override func setUp() {
        DaikiriCoreData.manager.useTestDatabase()
        DaikiriCoreData.manager.beginTransaction()
    }

    override func tearDown() {
        DaikiriCoreData.manager.rollback()
    }
    
    func test_create_and_retrieve_with_find() throws {
        let _ = Villain(id:1, name:"Joker", age:18).create()
        let _ = Villain(id:2, name:"Dr Octopus", age:45).create()
                    
        XCTAssertEqual(2, try Villain.count())
        
        let results = [
            try Villain.find(1)!,
            try Villain.find(2)!,
        ]
        
        XCTAssertEqual(2, results.count)
        
        XCTAssertEqual("Joker", results.first!.name)
        XCTAssertEqual(18, results.first!.age)
        XCTAssertEqual(1, results.first!.id)
                
        XCTAssertEqual("Dr Octopus", results.last!.name)
        XCTAssertEqual(45, results.last!.age)
        XCTAssertEqual(2, results.last!.id)
    }
    
    func test_create_and_retrieve_all() throws {
        let _ = Villain(id:1, name:"Joker", age:18).create()
        let _ = Villain(id:2, name:"Dr Octopus", age:45).create()

                    
        XCTAssertEqual(2, try Villain.count())
        
        let results = try Villain.all().sorted { (a, b) -> Bool in
            a.id < b.id
        }
        
        XCTAssertEqual(2, results.count)
        
        XCTAssertEqual("Joker", results.first!.name)
        XCTAssertEqual(18, results.first!.age)
        XCTAssertEqual(1, results.first!.id)
                
        XCTAssertEqual("Dr Octopus", results.last!.name)
        XCTAssertEqual(45, results.last!.age)
        XCTAssertEqual(2, results.last!.id)
    }

    
    func test_can_find_with_multiples_ids() throws {
        
        let _ = Villain(id:1, name:"Green goblin",  age:16).create()
        let _ = Villain(id:2, name:"Joker",         age:54).create()
        let _ = Villain(id:3, name:"Sandman",       age:54).create()
        let _ = Villain(id:4, name:"Red Hulk",      age:54).create()
        
        let all   = try Villain.all()
        let found = try Villain.find([1, 3, 6])
        
        XCTAssertEqual(4, all.count)
        XCTAssertEqual(2, found.count)
        
    }
    
    func test_can_create_from_json() throws {
        let jsonData = """
            {
                "id" : 12,
                "name" : "Ironman",
                "age"  : 44
            }
        """.data(using: .utf8)!
        try! JSONDecoder().decode(Villain.self, from:jsonData).create()
        
        let results = try Villain.all()
        XCTAssertEqual(1, results.count)
        XCTAssertEqual("Ironman", results.first!.name)
        XCTAssertEqual(44, results.first!.age)
        XCTAssertEqual(12, results.first!.id)
    }
    
    func test_create_updates_if_already_exists() throws {
        
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
        
        let correct  = try? JSONDecoder().decode(Villain.self, from:jsonData).create()
        let updated  = try? JSONDecoder().decode(Villain.self, from:jsonData2).create()
        
        XCTAssertNotNil(correct)
        XCTAssertNotNil(updated)
        
        let results = try Villain.all()
        XCTAssertEqual(1, results.count)
        XCTAssertEqual("Ironman 2", results.first!.name)
        XCTAssertEqual(44, results.first!.age)
        XCTAssertEqual(12, results.first!.id)
        XCTAssertEqual(1, results.count)
    }
    
    func test_can_delete_object() throws {
        
        let villain    = Villain(id:1, name:"Spiderman", age:16).create()
        XCTAssertEqual(1, try Villain.count())
        
        try villain.delete()
        XCTAssertEqual(0, try Villain.count())
    }
    
    func test_can_append_custom_predicate() throws {
        let a = Villain(id:1, name:"Spiderman", age:16).create()
        let _ = Villain(id:2, name:"Batman",    age:54).create()
        let _ = Villain(id:3, name:"Ironman",   age:44).create()
        let _ = Villain(id:4, name:"Hulk",      age:49).create()
        
        let predicate = NSPredicate(format:"name = %@", "Spiderman")
        let results = try Villain.query.addAndPredicate(predicate).get().map { $0.id }
        
        XCTAssertEqual([a.id], results)
    }
    
    func test_can_sort() throws {
        let _ = Villain(id:1, name:"Spiderman", age:16).create()
        let _ = Villain(id:2, name:"Batman",    age:54).create()
        let _ = Villain(id:3, name:"Ironman",   age:44).create()
        let _ = Villain(id:4, name:"Hulk",      age:49).create()
        
        let results = try Villain.query.orderBy("age").get()
        
        XCTAssertEqual(1, results[0].id)
        XCTAssertEqual(3, results[1].id)
        XCTAssertEqual(4, results[2].id)
        XCTAssertEqual(2, results[3].id)
    }
    
    func test_can_get_max() throws {
        let _ = Villain(id:1, name:"Spiderman", age:16).create()
        let _ = Villain(id:2, name:"Batman",    age:54).create()
        let _ = Villain(id:3, name:"Ironman",   age:44).create()
        let _ = Villain(id:4, name:"Hulk",      age:49).create()
        
        let result = try Villain.query.max("age")
        
        XCTAssertEqual(2, result!.id)
    }
    
    func test_can_get_min() throws {
        let _ = Villain(id:1, name:"Spiderman", age:16).create()
        let _ = Villain(id:2, name:"Batman",    age:54).create()
        let _ = Villain(id:3, name:"Ironman",   age:44).create()
        let _ = Villain(id:4, name:"Hulk",      age:49).create()
        
        let result = try Villain.query.min("age")
        
        XCTAssertEqual(1, result!.id)
    }
    
    func test_has_many_relationship_works(){
        let spiderman = Villain(id:1, name:"Spiderman", age:16).create()
        let batman    = Villain(id:2, name:"Batman",    age:54).create()
        
        let _ = VillainFriend(id:1, name:"Flash",      age:10, villain:spiderman).create()
        let _ = VillainFriend(id:2, name:"Mj",         age:10, villain:spiderman).create()
        
        let _ = VillainFriend(id:3, name:"Robin",      age:10, villain:batman).create()
        let _ = VillainFriend(id:4, name:"Nightwing",  age:10, villain:batman).create()
        let _ = VillainFriend(id:5, name:"Batgirl",    age:10, villain:batman).create()
        
        XCTAssertEqual(2, try spiderman.friends().count)
        XCTAssertEqual(3, try batman.friends().count)
    }
    
    func test_belongs_to_relationship_works(){
        
        let batcave     = Hideout(id: 1, name: "Batcave").create()
        let starkTower  = Hideout(id: 2, name: "Stark Tower").create()
        
        let spiderman = Villain(id:1, name:"Spiderman", age:16, hideout: nil).create()
        let batman    = Villain(id:2, name:"Batman",    age:54, hideout: batcave).create()
        let ironman   = Villain(id:3, name:"Ironman",   age:54, hideout: starkTower).create()
        
        XCTAssertNil(try spiderman.hideout())
        XCTAssertEqual("Batcave",     try batman.hideout()?.name)
        XCTAssertEqual("Stark Tower", try ironman.hideout()?.name)
        
        XCTAssertEqual("Batman", try batcave.villains().first?.name)
    }
    
    func test_belongs_to_many_relationship_works() throws {
        
        let batcave     = Hideout(id: 1, name: "Batcave").create()
        
        let batman      = Villain(id:1, name:"Batman",    age:16).create()
        let robin       = Villain(id:2, name:"Robin",     age:16).create()
        let nightWing   = Villain(id:3, name:"NightWing", age:16).create()
        
        let _ = HideoutVillain(id:1, hideout:batcave, villain:batman, level:100).create()
        let _ = HideoutVillain(id:2, hideout:batcave, villain:robin, level:45).create()
        let _ = HideoutVillain(id:3, hideout:batcave, villain:nightWing, level:56).create()
                
        let villains = try batcave.villainsWithPivot()
        
        XCTAssertEqual(3, villains.count)
        let firstVillain = villains.first!
        XCTAssertEqual(45, (firstVillain.pivot as! HideoutVillain).level)
    }
    
    func test_can_morph_to() throws {
        let batman = Villain(id:1, name:"Batman",    age:16).create()
        let image  = Image(id: 1, url: "http://image.com", imageable_id: 1, imageable_type: "Villain").create()
        
        let imageable = try image.imageable()
        
        XCTAssertEqual("Batman", (imageable as! Villain).name)
        
        let fetchedImage = try batman.image()
        XCTAssertEqual("http://image.com", fetchedImage!.url)
    }
}
