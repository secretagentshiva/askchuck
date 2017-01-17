//
//  ViewController.swift
//  AskChuck
//
//  Created by Litter Box Labs on 1/1/17.
//  Copyright © 2017 Chucklet Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var labelWelcome: UILabel!
    @IBOutlet weak var labelName: UILabel!
    var intLoginAttempts: UInt! = 0
    
    // Hardcoded family who can use the app; later can provision through User DB for identities+roles
    let userFriends: Array = ["Sari","sari","sarah","Sarah","Evie","eve","evie","Andy","andy","Poo Brother","poo brother", "Poo Sister","chuck","turtle","felix","Felix","Chuck","Turtle","Auntie Polly","polly","auntie polly"]
    
    let userMoms: Array = ["Sari","sari","sarah","Sarah"]
    let userDads: Array = ["Andy","andy"]
    
    func loadQuestionsUI() {
        self.performSegue(withIdentifier: "goToQuestionsUI", sender: self)
    }
    
    
    @IBAction func buttonTapped(_ sender: Any) {
        
        
        if textName.isHidden == false {
            
            if userFriends.contains(textName.text!) {
            
                UserDefaults.standard.set(textName.text, forKey:"name")
                
            } else {
                
                labelWelcome.text = "STRANGER DANGER!"
                return
            }
            
        }
        
        
        if textPassword.text == "poo" {
            labelWelcome.text = "I'M SO PROUD OF YOU!"
            intLoginAttempts = 0
            
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(loadQuestionsUI), userInfo: nil, repeats: false)
            
        }
            
        else {
            intLoginAttempts = intLoginAttempts + 1
            
            if intLoginAttempts > 1 {
                labelWelcome.text = "POO ON YOU!"
            }
                
            else {
                labelWelcome.text = "THAT'S REALLY CREEPY!"
            }
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        textName.isHidden = true
        labelName.isHidden = true
        
        // Debug and tetsting: wipe UserDefaults local storage for username
        // UserDefaults.standard.removeObject(forKey: "name")
        
        let userNameObject = UserDefaults.standard.object(forKey:"name")
        if let userName = userNameObject as? String {
            
            if userMoms.contains(userName)  {
                
                labelName.text = "HI MOMMY!"
                labelName.isHidden = false
                
            } else if userDads.contains(userName) {
                
                labelName.text = "HI DAD!"
                labelName.isHidden = false
                
            } else {
            
            labelName.text = "HI " + userName.uppercased() + " !"
            labelName.isHidden = false
                
            }
            
        } else {
            
            textName.isHidden = false
            
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Close keyboard on return (name field) and any other touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    
    
}






