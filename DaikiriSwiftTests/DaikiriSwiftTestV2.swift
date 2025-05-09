//
//  DaikiriSwiftTests.swift
//  DaikiriSwiftTests
//
//  Created by Jordi Puigdellívol on 13/01/2020.
//  Copyright © 2020 Jordi Puigdellívol. All rights reserved.
//

import XCTest
import CoreData

@testable import DaikiriSwift

class DaikiriSwiftTestsV2: XCTestCase {

    override func setUp() {
        DaikiriCoreData.manager.useTestDatabase(bundle: Bundle.main)
        DaikiriCoreData.manager.beginTransaction()
    }

    override func tearDown() {
        DaikiriCoreData.manager.rollback()
    }
    
    func test_create_and_retrieve_with_find() throws {
        let _ = try Villain(id:1, name:"Joker", age:18).create()
        let _ = try Villain(id:2, name:"Dr Octopus", age:45).create()
                    
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
        let _ = try Villain(id:1, name:"Joker", age:18).create()
        let _ = try Villain(id:2, name:"Dr Octopus", age:45).create()

                    
        XCTAssertEqual(2, try Villain.count())
        
        let results = try Villain.all().sorted { (a, b) -> Bool in
            a.id! < b.id!
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
        
        let _ = try Villain(id:1, name:"Green goblin",  age:16).create()
        let _ = try Villain(id:2, name:"Joker",         age:54).create()
        let _ = try Villain(id:3, name:"Sandman",       age:54).create()
        let _ = try Villain(id:4, name:"Red Hulk",      age:54).create()
        
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
    
    func test_create_fails_if_already_exists() throws {
        
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
        
        let _ = try? JSONDecoder().decode(Villain.self, from:jsonData).create()
        do {
            let _ = try JSONDecoder().decode(Villain.self, from:jsonData2).create()
        } catch {
            XCTAssertEqual(1, try Villain.count())
            XCTAssertEqual("Ironman", try Villain.first()!.name)
            return
        }
        XCTFail("Exception should have been throw")
    }
    

    
    func test_can_delete_object() throws {
        
        let villain    = try Villain(id:1, name:"Spiderman", age:16).create()
        XCTAssertEqual(1, try Villain.count())
        
        try villain.delete()
        XCTAssertEqual(0, try Villain.count())
    }
    
    func test_can_append_custom_predicate() throws {
        let a = try Villain(id:1, name:"Spiderman", age:16).create()
        let _ = try Villain(id:2, name:"Batman",    age:54).create()
        let _ = try Villain(id:3, name:"Ironman",   age:44).create()
        let _ = try Villain(id:4, name:"Hulk",      age:49).create()
        
        let predicate = NSPredicate(format:"name = %@", "Spiderman")
        let results = try Villain.query.addAndPredicate(predicate).get().map { $0.id }
        
        XCTAssertEqual([a.id], results)
    }
    
    func test_can_sort() throws {
        let _ = try Villain(id:1, name:"Spiderman", age:16).create()
        let _ = try Villain(id:2, name:"Batman",    age:54).create()
        let _ = try Villain(id:3, name:"Ironman",   age:44).create()
        let _ = try Villain(id:4, name:"Hulk",      age:49).create()
        
        let results = try Villain.query.orderBy("age").get()
        
        XCTAssertEqual(1, results[0].id)
        XCTAssertEqual(3, results[1].id)
        XCTAssertEqual(4, results[2].id)
        XCTAssertEqual(2, results[3].id)
    }
    
    func test_can_get_max() throws {
        let _ = try Villain(id:1, name:"Spiderman", age:16).create()
        let _ = try Villain(id:2, name:"Batman",    age:54).create()
        let _ = try Villain(id:3, name:"Ironman",   age:44).create()
        let _ = try Villain(id:4, name:"Hulk",      age:49).create()
        
        let result = try Villain.query.max("age")
        
        XCTAssertEqual(2, result!.id)
    }
    
    func test_can_get_min() throws {
        let _ = try Villain(id:1, name:"Spiderman", age:16).create()
        let _ = try Villain(id:2, name:"Batman",    age:54).create()
        let _ = try Villain(id:3, name:"Ironman",   age:44).create()
        let _ = try Villain(id:4, name:"Hulk",      age:49).create()
        
        let result = try Villain.query.min("age")
        
        XCTAssertEqual(1, result!.id)
    }
    
    func test_can_use_other_query_operators() throws {
        let _ = try Villain(id:1, name:"Spiderman", age:16).create()
        let _ = try Villain(id:2, name:"Batman",    age:54).create()
        let _ = try Villain(id:3, name:"Ironman",   age:44).create()
        let _ = try Villain(id:4, name:"Hulk",      age:49).create()
        
        let results = try Villain.query.whereKey("id", ">", 2).get()
        
        XCTAssertEqual([3, 4], results.sorted { $0.id! < $1.id! }.map { $0.id })
    }
    
    func test_has_many_relationship_works() throws {
        let spiderman = try Villain(id:1, name:"Spiderman", age:16).create()
        let batman    = try Villain(id:2, name:"Batman",    age:54).create()
        
        let _ = try VillainFriend(id:1, name:"Flash",      age:10, villain:spiderman).create()
        let _ = try VillainFriend(id:2, name:"Mj",         age:10, villain:spiderman).create()
        
        let _ = try VillainFriend(id:3, name:"Robin",      age:10, villain:batman).create()
        let _ = try VillainFriend(id:4, name:"Nightwing",  age:10, villain:batman).create()
        let _ = try VillainFriend(id:5, name:"Batgirl",    age:10, villain:batman).create()
        
        XCTAssertEqual(2, try spiderman.friends().count)
        XCTAssertEqual(3, try batman.friends().count)
    }
    
    func test_belongs_to_relationship_works() throws {
        
        let batcave     = try Hideout(id: 1, name: "Batcave").create()
        let starkTower  = try Hideout(id: 2, name: "Stark Tower").create()
        
        let spiderman = try Villain(id:1, name:"Spiderman", age:16, phone:nil, hideout: nil).create()
        let batman    = try Villain(id:2, name:"Batman",    age:54, phone:nil, hideout: batcave).create()
        let ironman   = try Villain(id:3, name:"Ironman",   age:54, phone:nil, hideout: starkTower).create()
        
        XCTAssertNil(try spiderman.hideout())
        XCTAssertEqual("Batcave",     try batman.hideout()?.name)
        XCTAssertEqual("Stark Tower", try ironman.hideout()?.name)
        
        XCTAssertEqual("Batman", try batcave.villains().first?.name)
    }
    
    func test_belongs_to_many_relationship_works() throws {
        
        let batcave     = try Hideout(id: 1, name: "Batcave").create()
        
        let batman      = try Villain(id:1, name:"Batman",    age:16).create()
        let robin       = try Villain(id:2, name:"Robin",     age:16).create()
        let nightWing   = try Villain(id:3, name:"NightWing", age:16).create()
        
        let _ = try HideoutVillain(id:1, hideout:batcave, villain:batman, level:100).create()
        let _ = try HideoutVillain(id:2, hideout:batcave, villain:robin, level:45).create()
        let _ = try HideoutVillain(id:3, hideout:batcave, villain:nightWing, level:56).create()
                
        let villains = try batcave.villainsWithPivot()
        
        XCTAssertEqual(3, villains.count)
        let firstVillain = villains.first!
        XCTAssertEqual(45, (firstVillain.pivot as! HideoutVillain).level)
    }
    
    func test_can_morph_to() throws {
        let batman = try Villain(id:1, name:"Batman",    age:16).create()
        let image  = try Image(id: 1, url: "http://image.com", imageable_id: 1, imageable_type: "Villain").create()
        
        let imageable = try image.imageable()
        
        XCTAssertEqual("Batman", (imageable as! Villain).name)
        
        let fetchedImage = try batman.image()
        XCTAssertEqual("http://image.com", fetchedImage!.url)
    }
    
    func test_can_morph_to_many() throws {
        let batman = try Villain(id:1, name:"Batman",    age:16).create()
        let _ = try Image(id: 1, url: "http://image1.com", imageable: batman).create()
        let _ = try Image(id: 2, url: "http://image2.com", imageable: batman).create()
        let _ = try Image(id: 3, url: "http://image3.com", imageable: batman).create()
        
                
        let fetchedImages = try batman.images().sorted { $0.id! < $1.id! }
        XCTAssertEqual(3, fetchedImages.count)
        XCTAssertEqual("http://image1.com", fetchedImages[0].url)
        XCTAssertEqual("http://image2.com", fetchedImages[1].url)
        XCTAssertEqual("http://image3.com", fetchedImages[2].url)
    }
    
    func test_can_morph_to_many_with_pivot() throws {
        let batman = try Villain(id:1, name:"Batman",    age:16).create()
        let robin = try VillainFriend(id: 1, name: "Robin", age: 15, villain: batman).create()
        
        let tag1 = try Tag(id: 1, name: "Black").create()
        let tag2 = try Tag(id: 2, name: "Cape").create()
        let tag3 = try Tag(id: 3, name: "Batmobile").create()
        
        try Taggable(id: 1, tag: tag1, taggable: batman).create()
        try Taggable(id: 2, tag: tag1, taggable: robin).create()
        try Taggable(id: 3, tag: tag2, taggable: batman).create()
        try Taggable(id: 4, tag: tag3, taggable: robin).create()
        
        let batmanTags = try batman.tags()
        let robinTags = try robin.tags()
        
        XCTAssertEqual(2, batmanTags.count)
        XCTAssertEqual(2, robinTags.count)
        XCTAssertEqual(["Black", "Cape"], batmanTags.sorted { $0.id! < $1.id! }.map { $0.name } )
        XCTAssertEqual(["Black", "Batmobile"], robinTags.sorted { $0.id! < $1.id! }.map {$0.name} )
        
        XCTAssertEqual(["Batman"], try tag1.villains().map { $0.name })
        XCTAssertEqual(["Robin"], try tag1.villainFriends().map { $0.name })

    }
    
    func test_can_get_a_fresh_instance() throws {
        let batman = try Villain(id:1, name:"Batman",    age:16).create()
        batman.name = "Patata"
        
        XCTAssertEqual("Patata", batman.name)
        XCTAssertEqual("Batman", try batman.fresh().name)
    }
    
    func test_can_update_an_instance() throws {
        
        let batman = try Villain(id:1, name:"Batman",    age:16).create()
        batman.name = "Patata"
        try batman.save()
        
        XCTAssertEqual(1, try Villain.count())
        XCTAssertEqual("Patata", batman.name)
        XCTAssertEqual("Patata", try batman.fresh().name)
    }
    
    func test_can_not_update_a_non_existing_instance() throws {
        let batman = Villain(id:1, name:"Batman",    age:16)
        batman.name = "Patata"
        do {
            try batman.save()
        } catch {
            XCTAssertTrue(true)
            return
        }
        XCTFail("Exception should have been thrown")
    }
    
    func test_can_update_or_create() throws {
        let batman = Villain(id:1, name:"Batman", age:16)
        try batman.updateOrCreate()
        
        XCTAssertEqual(1, try Villain.count())
        XCTAssertEqual("Batman", try Villain.first()!.name)
        
    }
    
    func test_can_delete_an_instance() throws {
        let batman = try Villain(id:1, name:"Batman",    age:16).create()
        
        XCTAssertEqual(1, try Villain.count())
        try batman.delete()
        
        XCTAssertEqual(0, try Villain.count())
    }
    
    func test_can_user_another_core_model() throws {
        let modelURL = Bundle.main.url(forResource: "AnotherSQL", withExtension: "momd")!
        let customModel = NSManagedObjectModel(contentsOf: modelURL)!
        
        DaikiriCoreData.manager = DaikiriCoreData(name: "DaikiriSwift", model:customModel)
        
        //DaikiriCoreData.manager.useTestDatabase()
        DaikiriCoreData.manager.beginTransaction()
        
        let vehicle = try Vehicle(id:1, name:"Batmobile").create()
                
    }
    
    func test_can_query_for_nil_value() throws {
        let batcave     = try Hideout(id: 1, name: "Batcave").create()
        
        let batman      = try Villain(id:1, name:"Batman",    age:16, hideout_id: batcave.id).create()
        let robin       = try Villain(id:2, name:"Robin",     age:16, hideout_id: batcave.id).create()
        let nightWing   = try Villain(id:3, name:"NightWing", age:16).create()
        
        let villainsWithoutHideout = try Villain.query.whereKey("hideout_id", nil as Int?).get()
        
        XCTAssertEqual(1, villainsWithoutHideout.count)
        XCTAssertEqual("NightWing", villainsWithoutHideout.first?.name)
    }
    
    func test_can_query_for_multiple_fields() throws {
        let batman      = try Villain(id:1, name:"Batman",    age:16, phone: "123456789").create()
        let robin       = try Villain(id:2, name:"Robin",     age:16, phone: "Bat56").create()
        let nightWing   = try Villain(id:3, name:"NightWing", age:16).create()
        
        let batVillains = try Villain.query.whereAny(["name", "phone"], like: "Bat").get()
        
        XCTAssertEqual(2, batVillains.count)
        XCTAssertEqual("Robin", batVillains[0].name)
        XCTAssertEqual("Batman", batVillains[1].name)
    }
    
}
