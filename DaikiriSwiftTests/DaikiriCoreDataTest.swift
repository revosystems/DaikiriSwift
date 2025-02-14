//
//  DaikiriCoreDataTest.swift
//  DaikiriSwiftTests
//
//  Created by Jordi Puigdellívol on 14/01/2020.
//  Copyright © 2020 Jordi Puigdellívol. All rights reserved.
//

import XCTest
@testable import DaikiriSwift

class DaikiriCoreDataTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_transaction_works() throws {
        
        DaikiriCoreData.manager.beginTransaction()
        let _ = try Hero(id:1, name:"Spiderman", age:16).create()
        var results = try Hero.all()
        XCTAssertEqual(1, results.count)
        DaikiriCoreData.manager.rollback()
        
        results = try Hero.all()
        XCTAssertEqual(0, results.count)
    }
    
    func test_tast_test_databaseWorks() throws {
        
        DaikiriCoreData.manager.useTestDatabase(bundle: Bundle.main)
        DaikiriCoreData.manager.beginTransaction()
        let _ = try Hero(id:1, name:"Spiderman", age:16).create()
        var results = try Hero.all()
        XCTAssertEqual(1, results.count)
        DaikiriCoreData.manager.rollback()
        
        results = try Hero.all()
        XCTAssertEqual(0, results.count)
    }


}
