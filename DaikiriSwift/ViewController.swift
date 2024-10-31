//
//  ViewController.swift
//  DaikiriSwift
//
//  Created by Jordi Puigdellívol on 13/01/2020.
//  Copyright © 2020 Jordi Puigdellívol. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let _ = Hero(name:"Joker", age:16, id:1)
        
        do {
            //let fetched = try Villain.query.first<Villain>()
            print(fetched)
        }catch {
            print(error)
        }
    }


}

