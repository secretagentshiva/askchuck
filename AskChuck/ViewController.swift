//
//  ViewController.swift
//  AskChuck
//
//  Created by Shiva Rajaraman on 1/1/17.
//  Copyright © 2017 Chucklet Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var labelWelcome: UILabel!
    var intLoginAttempts: UInt! = 0
    
    @IBAction func buttonTapped(_ sender: Any) {
        
        if textPassword.text == "poo" {
            labelWelcome.text = "I'M SO PROUD OF YOU!"
            intLoginAttempts = 0
        }
            
        else {
            intLoginAttempts = intLoginAttempts + 1
            
            if intLoginAttempts > 1 {
                labelWelcome.text = "POO ON YOU! HELP POO BROTHER!"
            }
                
            else {
                labelWelcome.text = "THAT'S REALLY CREEPY!"
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// Save for "I'm feeling chucky" RANDOM selection
// var countAssets: UInt32 = 10 // will need to populate with lookup of available assets
// let selectionSurprise = arc4random_uniform(countAssets+1)




