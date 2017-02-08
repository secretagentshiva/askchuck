//
//  ViewController.swift
//  AskChuck
//
//  Created by Litter Box Labs on 1/1/17.
//  Copyright © 2017 Chucklet Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var labelWelcome: UILabel!
    @IBOutlet weak var labelName: UILabel!
    

    let textName = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
    let textPassword = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
    let buttonLegit = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    
    var intLoginAttempts: UInt! = 0
    
    // Hardcoded family who can use the app; later can provision through PublicDB for identities+roles
    let userFriends: Array = ["sari","sarah","eve","evie","andy","shiva","chuck","turtle","felix","polly"]
    let textPasswords: Array = ["poo","💩"]
    
    let userMoms: Array = ["sari","sarah"]
    let userDads: Array = ["andy"]
    let userPoo: Array = ["shiva"]
    
    func loadQuestionsUI() {
        self.performSegue(withIdentifier: "goToQuestionsUI", sender: self)
    }
    
        
    func buttonTapped(_ sender: Any) {
        
        // this part will never check for now as I've made textName.alpha always == 0 
        // textName display and entry eliminated for welcome message
        if textName.alpha == 1 {
            
            
            if userFriends.contains((textName.text?.lowercased())!) {
            
                UserDefaults.standard.set(textName.text?.lowercased(), forKey:"name")
                
            } else {
                
                labelWelcome.text = "STRANGER DANGER!"
                return
            }
            
        }
        
        // successful login
        
        
        if textPasswords.contains((textPassword.text?.lowercased())!) {
            
            labelWelcome.text = "I'M SO PROUD OF YOU!"
            
            labelWelcome.textColor = UIColor.magenta
            labelName.textColor = UIColor.cyan
            
            
            // increment login attempt counter for mockery
            
            intLoginAttempts = 0
            
            // load Question View after timer
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
        // hide Name label
        labelName.alpha = 0
        
        
        // Create username, password text elements and submission button
        
        
        // Create username entry
        
        textName.placeholder = "name please"
        textName.alpha = 0
        textName.font = UIFont(name: "System", size: 14)
        textName.adjustsFontSizeToFitWidth = true
        textName.minimumFontSize = 14
        textName.backgroundColor = UIColor.white
        textName.textAlignment = NSTextAlignment.center
        textName.borderStyle = UITextBorderStyle.roundedRect
        textName.autocapitalizationType = .none
        textName.autocorrectionType = .no
        textName.keyboardType = UIKeyboardType.alphabet
        textName.autocorrectionType = .no
        
        textName.center.x -= UIScreen.main.bounds.width
        textName.center.y = UIScreen.main.bounds.maxY - 150
        
        self.view.addSubview(textName)
       
        
        // Create password entry
        
        textPassword.placeholder = "secret word"
        textPassword.alpha = 1
        textPassword.font = UIFont(name: "System", size: 14)
        textPassword.adjustsFontSizeToFitWidth = true
        textPassword.minimumFontSize = 14
        textPassword.backgroundColor = UIColor.white
        textPassword.textAlignment = NSTextAlignment.center
        textPassword.borderStyle = UITextBorderStyle.roundedRect
        textPassword.autocapitalizationType = .none
        textPassword.autocorrectionType = .no
        textPassword.keyboardType = UIKeyboardType.default
        textPassword.autocorrectionType = .no
        // textPassword.isSecureTextEntry = true
        textPassword.center.x += UIScreen.main.bounds.width
        textPassword.center.y = UIScreen.main.bounds.maxY - 100
        
        self.view.addSubview(textPassword)
        
        
        // Submission Button
        buttonLegit.setTitle("I'M LEGIT", for: UIControlState.normal)
        buttonLegit.titleLabel?.font =  UIFont(name: "System-Bold", size: 19)
        buttonLegit.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        buttonLegit.titleLabel?.numberOfLines = 2
        buttonLegit.titleLabel?.textAlignment = NSTextAlignment.center
        buttonLegit.setTitleColor(UIColor.yellow, for: UIControlState.normal)
        buttonLegit.setTitleColor(UIColor.purple, for: UIControlState.highlighted)
        buttonLegit.setTitleShadowColor(UIColor.orange, for: UIControlState.normal)
        buttonLegit.setTitleShadowColor(UIColor.magenta, for: UIControlState.highlighted)
        buttonLegit.titleLabel?.shadowOffset = CGSize(width: 0, height: 1)

        buttonLegit.center.x = UIScreen.main.bounds.midX
        buttonLegit.center.y = UIScreen.main.bounds.maxY - 50
        buttonLegit.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        
          self.view.addSubview(buttonLegit)
        
        // declare vertical spacing constraint between textPassword and buttonLegit
        
        /*
        let verticalSpacingConstraintButton = NSLayoutConstraint(item: buttonLegit, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: textPassword, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 5)
       
        let verticalSpacingConstraintBottom = NSLayoutConstraint(item: buttonLegit, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: bottomLayoutGuide, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 10)
        
        // maybe need this at view level too?
        buttonLegit.translatesAutoresizingMaskIntoConstraints = false
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        // remove existing constraints
        self.buttonLegit.removeConstraints(self.buttonLegit.constraints)
        self.view.removeConstraint(self.constraintTextPasswordOriginal)
        
        */
        
       
        
        UIView.animate(withDuration: 1.5, delay: 0.5,
                                   usingSpringWithDamping: 0.3,
                                   initialSpringVelocity: 0.4,
                                   options: [], animations: {
                                    
                                    
                                    // need to do this with constraints for different screen sizes
                                    
                                    self.textName.center.x = UIScreen.main.bounds.midX
                                    self.textPassword.center.x = UIScreen.main.bounds.midX
                                    self.buttonLegit.center.y = self.textPassword.frame.maxY + 20
                                    
                                    
                                    
                                    // NSLayoutConstraint.activate([verticalSpacingConstraintButton])
                                    
                                    
        }, completion: nil)
        
        
        
        // Debug and testing: wipe UserDefaults local storage for username
        // UserDefaults.standard.removeObject(forKey: "name")
        
        let userNameObject = UserDefaults.standard.object(forKey:"name")
        if let userName = userNameObject as? String {
            
            if userMoms.contains(userName)  {
                
                labelName.text = "HI MOMMY!"
               
                // hiding labelName for now, too crowded
                // labelName.alpha = 1
                
            } else if userDads.contains(userName) {
                
                labelName.text = "HI DAD!"
                
                // hiding labelName for now, too crowded
                // labelName.alpha = 1
                
            } else if userPoo.contains(userName) {
                
    
                labelName.text = "HI POO BROTHER!"
                
                // hiding labelName for now, too crowded
                // labelName.alpha = 1
                
            }   else {
            
            labelName.text = "HI " + userName.uppercased() + " !"
            
                // hiding labelName for now, too crowded
                // labelName.alpha = 1
                
            }
            
        } else {
            
            // removing need for textName entry for now
            // textName.alpha = 1
            
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






