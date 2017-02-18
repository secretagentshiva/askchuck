//
//  ViewController.swift
//  AskChuck
//
//  Created by Litter Box Labs on 1/1/17.
//  
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var labelWelcome: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var buttonRotateImage: UIButton!
    
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
    
    // hardcode toggle for switching images
    // will make dynamic once have array of hazel images
    var imageChuckToggle = true
    
    
    func loadQuestionsUI() {
        self.performSegue(withIdentifier: "goToQuestionsUI", sender: self)
        
    }
    
        
    func buttonRotateImageTapped(_ sender: Any) {
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        
        if imageChuckToggle {
            // set to alternative chuckImages
            let imgToSwap = UIImage(named: "chuckLoad.png")
            
            imageBackground.image = resizeImage(image: imgToSwap!, newWidth: screenWidth)
            
            imageChuckToggle = false
        } else {
            
             // set to standard chuckImage
            let imgToSwap = UIImage(named: "hazelcover3.jpg")
            imageBackground.image = resizeImage(image: imgToSwap!, newWidth: screenWidth)
            imageChuckToggle = true
            
        }
        
    }
    
    
    func buttonLegitTapped(_ sender: Any) {
        
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
    
    // functions to switch position of password / button when keyboard displayed
    func keyboardWillShow(sender: NSNotification) {
        
        // for some reason this fires multiple times; later needs debugging 
        // multiple fire means I can't just shift -= and have to position absolute which is annoying
       
       //  self.textPassword.frame.origin.y -= 150
        // self.buttonLegit.frame.origin.y -= 150
        
        /*
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        */
        
        self.textPassword.frame.origin.y = self.view.center.y - 20
        self.buttonLegit.center.y = self.textPassword.frame.maxY + 25
        
       // debug position duplicate fires
       // print("origin y changed")
       //  print(self.textPassword.frame.origin.y)

    }
    
    func keyboardWillHide(sender: NSNotification) {
        
        
        // for some reason this fires multiple times; later needs debugging
        // multiple fire means I can't just shift += and have to position absolute which is annoying

        /*
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        self.textPassword.frame.origin.y += keyboardHeight
        self.buttonLegit.frame.origin.y +=  keyboardHeight
        */
        
       // self.buttonLegit.removeConstraints(self.buttonLegit.constraints)
       // self.textPassword.removeConstraints(self.buttonLegit.constraints)
        
        self.textPassword.center.y = self.view.frame.maxY - 100
        self.buttonLegit.center.y = self.textPassword.frame.maxY + 25

        // self.textPassword.frame.origin.y += 150
        // self.buttonLegit.frame.origin.y += 150
        
      
        
    }
    
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        // hide Name label
        labelName.alpha = 0
        
        // set Rotate Image button target
        // diasabling this rotate image option for now
        buttonRotateImage.isHidden = true
        buttonRotateImage.alpha = 0
        buttonRotateImage.addTarget(self, action: #selector(self.buttonRotateImageTapped), for: .touchUpInside)
        
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
        
       
        textPassword.alpha = 1
        textPassword.font = UIFont(name: "System", size: 14)
        textPassword.adjustsFontSizeToFitWidth = true
        textPassword.minimumFontSize = 14
        textPassword.backgroundColor = UIColor.white
        textPassword.textAlignment = NSTextAlignment.center
        textPassword.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        textPassword.borderStyle = UITextBorderStyle.roundedRect
        textPassword.placeholder = "secret word"
        textPassword.autocapitalizationType = .none
        textPassword.autocorrectionType = .no
        textPassword.keyboardType = UIKeyboardType.default
        textPassword.autocorrectionType = .no
        // textPassword.isSecureTextEntry = true
        textPassword.center.x += UIScreen.main.bounds.width
        
        // hardcode not preferred
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
        
        // hardcode not preferred
        buttonLegit.center.y = UIScreen.main.bounds.maxY - 100
        buttonLegit.addTarget(self, action: #selector(self.buttonLegitTapped), for: .touchUpInside)
        
          self.view.addSubview(buttonLegit)
        
        // declare vertical spacing constraint between textPassword and buttonLegit
        
        // Constraints below not working w/ animation
        /*
        let verticalSpacingConstraintButton = NSLayoutConstraint(item: textPassword, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: buttonLegit, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
       
        let verticalSpacingConstraintBottom = NSLayoutConstraint(item: buttonLegit, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: bottomLayoutGuide, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 20)
        */
        
        // maybe need this at view level too?
       // buttonLegit.translatesAutoresizingMaskIntoConstraints = false
       //  self.view.translatesAutoresizingMaskIntoConstraints = false
        
        // remove existing constraints
        // self.buttonLegit.removeConstraints(self.buttonLegit.constraints)
       
       
        
        UIView.animate(withDuration: 1.5, delay: 0.5,
                                   usingSpringWithDamping: 0.3,
                                   initialSpringVelocity: 0.4,
                                   options: [], animations: {
                                    
                                    
                                    // need to do this with constraints for different screen sizes
                                    // Display name disabled for now
                                    // self.textName.center.x = UIScreen.main.bounds.midX
                                    
                                    self.textPassword.center.x = UIScreen.main.bounds.midX
                                    self.buttonLegit.center.y = self.textPassword.frame.maxY + 25
                                    
                                    /* constraints below not working
                                    NSLayoutConstraint.activate([verticalSpacingConstraintButton])
                                    NSLayoutConstraint.activate([verticalSpacingConstraintBottom])
                                    
                                    self.textPassword.center.x = UIScreen.main.bounds.midX
                                    self.buttonLegit.center.x = UIScreen.main.bounds.midX
                                    */
                                    
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
        
        
        
        // Listeners for keyboard to push up password field
        
        NotificationCenter.default.addObserver(self, selector:#selector((self.keyboardWillShow(sender:))), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        
        NotificationCenter.default.addObserver(self, selector:#selector((self.keyboardWillHide(sender:))), name:NSNotification.Name.UIKeyboardWillHide, object: nil);

        
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






