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
                
        //let _ = Hero(name:"Joker", age:16, id:1)
        
        Villain.truncate()
        
        let villain = Villain(id: 1, name:"Joker", age:45)
        villain.create()
        
        do {
            let fetched = try Villain.first()
            print(fetched)
        } catch {
            print(error)
        }
    }


}

