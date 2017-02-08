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
    @IBOutlet weak var imageUnicorn: UIImageView!
    @IBOutlet weak var constraintTextPasswordOriginal: NSLayoutConstraint!
    
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
    
        
    @IBAction func buttonTapped(_ sender: Any) {
        
        
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
        
        
        textName.alpha = 0
        labelName.alpha = 0
        
        
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
        self.view.addSubview(buttonLegit)
        buttonLegit.center.y = UIScreen.main.bounds.maxY + 100
        buttonLegit.center.x = UIScreen.main.bounds.midX
        buttonLegit.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        
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
                                    
                                   //  UIScreen.main.bounds.maxY - (self.buttonLegit.frame.height + 5)
                                    
                                    self.buttonLegit.center.y = self.textPassword.frame.maxY + 20
                                    self.buttonLegit.center.x = UIScreen.main.bounds.midX
                                    
                                    
                                    // NSLayoutConstraint.activate([verticalSpacingConstraintButton])
                                    
                                    
        }, completion: nil)
        
        
        
        // Debug and testing: wipe UserDefaults local storage for username
        // UserDefaults.standard.removeObject(forKey: "name")
        
        let userNameObject = UserDefaults.standard.object(forKey:"name")
        if let userName = userNameObject as? String {
            
            if userMoms.contains(userName)  {
                
                labelName.text = "HI MOMMY!"
                labelName.alpha = 1
                
            } else if userDads.contains(userName) {
                
                labelName.text = "HI DAD!"
                labelName.alpha = 1
                
            } else if userPoo.contains(userName) {
                
                labelName.text = "POO BROTHER!"
                labelName.alpha = 1
                
            }   else {
            
            labelName.text = "HI " + userName.uppercased() + " !"
            labelName.alpha = 1
                
            }
            
        } else {
            
            textName.alpha = 1
            
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






