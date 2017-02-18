//
//  QuestionsViewController.swift
//  AskChuck
//
//  Created by Litter Box Labs on 1/8/17.
//  
//

import UIKit
import CloudKit
import AVKit
import AVFoundation

class QuestionsViewController: UIViewController {

    
    var chuckism = Chuckism()
    var chuckisms = [Chuckism]()
    var chuckismPlayer: AVAudioPlayer!
    var indexRecordID: Int = 0
    var selectedQuestionIDs: [Int] = []
    
    
    // total questions to pick from
    // should be total count of questions in PublicDB
    // hardcoded for now but will eventually be dynamic based on avail questions in Public DB
    // note: a bit brittle, because if question IDs are not continuous to totalAvailQuestion, you may generate random question IDs that aren't in the DB so # of questions you display will be less than countMaxQuestions
    var totalAvailQuestions = 5

    
    let playerViewController = AVPlayerViewController()
    
    // spinner image view
    let imgSpinnerView = UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 48, height: 48))
    
    
    // adding identifier tag for StackView to access later w/ I'm Feeling Chucky
    let tagStackView: Int = 1000
    
    // adding identifier tag for I'm Feeling Chucky Button
    let tagChuckyButton: Int = 0
    
    // boolean in case we need to expose all buttons again in case I'm Feeling Chucky selected
    // given that will hide some questions
    var resetQuestionsView = false
    
    
    // Debug single question for testing end to end
    // var questionID: Int64 = 1
    
    // Outlets
   @IBOutlet weak var headerImgView: UIImageView!
    
    
    // Delay function
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    
    func downloadplayTapped(sender:UIButton) {
        
        var questionID = sender.tag
        
        // questionIDs start at 1 with the exception of the I'm Feeling Chucky special questionID==0
        // for correct array indexing, substracting 1; however, special I'm Feeling Chucky, already handled above
        // I'm Feeling Chucky action will instead just be assigned to a random available Question ID

        if questionID == tagChuckyButton {
            
            // need to reset view with questions given I'm Feeling Chucky will hide some questions
            resetQuestionsView = true
            
            // I'm Feeling Chucky random video
           //  Select a random Question ID from selectedQuestionIDs populated earlier
            questionID = selectedQuestionIDs.randomElement()!
            
            // make invisible non-selected Question IDs so you know which one you were 'lucky with'
            let stackViewButtons = self.view.viewWithTag(tagStackView)
            
            
            for view in (stackViewButtons?.subviews)!  {
                // print("Button found: ", view.tag)
                if view.tag != questionID  {
                    
                    //    print("Button matched: ", view.tag)
                        view.isHidden = true
                    //    print("I'm Feeling Chucky revealed!")
                    
                    } else {
                    
                        // set random question chosen to selected color scheme
                        if let button = view as? UIButton {
                            button.setTitleColor(UIColor.purple, for: UIControlState.highlighted)
                            button.setTitleShadowColor(UIColor.magenta, for: UIControlState.highlighted)
                            //      print("I'm Feeling Chucky Highlighted!")
                    }
                    
                }
            }
            
            
            delayWithSeconds(2) {
                // just hanging out for 2 second so you can see altered questions
            }
            
        }
    
        // lookup record for the chosen Question ID
        let matchedChuckism = self.chuckisms.filter{ $0.questionID == Int64(questionID) }.first
        self.chuckism.recordID = matchedChuckism?.recordID
        
         CKContainer.default().publicCloudDatabase.fetch(withRecordID: self.chuckism.recordID) { record, error in
            if error != nil {
                
                DispatchQueue.main.async {
         
         
                    //copy and pasted this error message to see if it works.
                    let ac = UIAlertController(title: "Chuck's not at home.", message: "There was a problem reaching Chuck; please try again later.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
         
                }
            } else {
                if let record = record {
                    if let asset = record["Response"] as? CKAsset {
                        self.chuckism.response = asset.fileURL
                        
                        // Debug
                        // print(self.chuckism.response)
         
                        DispatchQueue.main.async {
                           
                            
                                // debug hardcode localfile
                                // self.chuckism.response = NSURL(string: "file:///Users/shiva/Desktop/filepath.mov") as URL!
                            
                                let realURL: URL = self.chuckism.response as URL!
                                let linkedURL = self.chuckism.response.appendingPathExtension("mov")
                            
                            
                                let fileManager = FileManager.default
                                do {
                                        try fileManager.linkItem(at: realURL, to: linkedURL)
                                
                                        } catch {
                                    
                                            let ac = UIAlertController(title: "Having trouble saving Chuck's wisdom for your viewing pleasure", message: "Please try again later.", preferredStyle: .alert)
                                            ac.addAction(UIAlertAction(title: "OK", style: .default))
                                            self.present(ac, animated: true)
                                }
                            

                                self.chuckism.response = linkedURL as URL!
                                let player = AVPlayer(url: self.chuckism.response! as URL)
                            
                                self.playerViewController.player = player
                                self.present(self.playerViewController, animated: true) {
                                    

                                    self.playerViewController.videoGravity = AVLayerVideoGravityResizeAspectFill
                                    
                                    self.playerViewController.player!.play()
                                    
                                    
                                    if self.resetQuestionsView == true {
                                        
                                        // make invisible non-selected Question IDs visible again if hidden prior to playback for I'm Feeling Chucky use case
                                        let stackViewButtons = self.view.viewWithTag(self.tagStackView)
                                        
                                        for view in (stackViewButtons?.subviews)!  {
                                            
                                            view.isHidden = false
                                            
                                        }
                                        
                                        self.resetQuestionsView = false
                                        
                                    }

                                    
                                    NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                                    
                                    
                                }
                           
                                // Error handling for playback failure, unclear if below ever triggers
                            
                               if player.error != nil {
                             
                                let ac = UIAlertController(title: "Chuck's unavailable now.", message: "There was a problem playing Chuck's video; please try again later.", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(ac, animated: true)
                             
                                }
                            
                        }
                        
         
                        
                    }
                }
            }
         }
    }

   /* Want to count available questions to make totalAvailQuestions dynamic vs hard coded */
   // may need to rewrite this after testing it to move to .operation framework as this may load all responses and waste bandwidth
     
   func countAvailQuestions() {
        let defaultContainer = CKContainer.default()
        let publicDB = defaultContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Chuckisms", predicate: predicate)
    
        publicDB.perform(query, inZoneWith: nil) {
        (records, error) -> Void in
        guard let records = records else {
            self.notifyUser("Error counting Chuckisms", message: "Chuck's wisdom has been thwarted")
            return
            }
        self.totalAvailQuestions = records.count
        // print("Found \(records.count) records matching query")
     
        }
     
        
    }
 
 
    
    func loadChuckisms() {
        
        // Capping questions to display but picking from PublicDB a random set of what is available
        
        var questionIDArray: [Int] = []
        
        // max questions displayed on screen (in addition to I'm Feeling Chucky)
        // currently set to be max 3 questions
        let countMaxQuestions = 4
        
        
        // build array of random question IDs to query later
        // Note: assumption is question IDs are integers in continuous sequential order
        var count = 1
        var randomQuestionID = 1
        
        while count <= countMaxQuestions {
            
            
                randomQuestionID = Int(arc4random_uniform(UInt32(totalAvailQuestions)))
                // eliminating 0 value (question IDs start with 1)
                randomQuestionID += 1
            
                if !questionIDArray.contains(randomQuestionID) {
                    questionIDArray.append(randomQuestionID)
                
                    count += 1
                    
                    
                }
        }
        
        // storing selected Question IDs into a global var for I'm Feeling Chuck access later
        selectedQuestionIDs = questionIDArray
       
        
        let predicate = NSPredicate(format: "QuestionID IN %@", questionIDArray)
        let query = CKQuery(recordType: "Chuckisms", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        // removed Response here
        // operation.desiredKeys = ["Question", "Response", "QuestionID"]
        operation.desiredKeys = ["Question", "QuestionID"]
        operation.resultsLimit = 5 // capping this during testing
        
        var newChuckisms = [Chuckism]()
       
       
        // debug for array append issues
        
        operation.recordFetchedBlock = { record in
            
            let tmpChuckism = Chuckism()
            tmpChuckism.recordID = record.recordID
            tmpChuckism.question = record["Question"] as! String
            tmpChuckism.questionID = record["QuestionID"] as! Int64!
    
            newChuckisms.append(tmpChuckism)
            
        }
        
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    
                    self.chuckisms = newChuckisms
                    
                    // list out questions as buttons
                    let screenSize = UIScreen.main.bounds
                    var buttons = [UIButton()]
                    let widthButton = screenSize.width - 20
                    
                    for chuckQuestion in self.chuckisms {
                        
                        // create and format buttons
                        let questionButton = UIButton(frame: CGRect(x: 0, y: 0, width: widthButton, height: 30))
                        questionButton.translatesAutoresizingMaskIntoConstraints = false
                       
                        // add to buttons array for stackview
                        buttons.append(questionButton)
                
                        // format buttons
                        questionButton.setTitle("\(chuckQuestion.question!.uppercased())",for: UIControlState.normal)
                        questionButton.titleLabel?.font =  UIFont(name: "AvenirNext-Heavy", size: 16)
                        questionButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                        questionButton.titleLabel?.numberOfLines = 2
                        questionButton.titleLabel?.textAlignment = NSTextAlignment.center
                        questionButton.setTitleColor(UIColor.white, for: UIControlState.normal)
                        questionButton.setTitleColor(UIColor.purple, for: UIControlState.highlighted)
                        questionButton.setTitleShadowColor(UIColor.blue, for: UIControlState.normal)
                        questionButton.setTitleShadowColor(UIColor.magenta, for: UIControlState.highlighted)
                        questionButton.titleLabel?.shadowOffset = CGSize(width: 0, height: 1)
                        
                        
                        // employ tag property to pass question ID and set target
                        questionButton.tag = Int(chuckQuestion.questionID)
                        questionButton.addTarget(self, action: #selector(self.downloadplayTapped), for: .touchUpInside)
                        
                        
                    }
                    
                    
                    
                    // MANUAL QUESTION TESTING -- BEG BLOCK
                    // Testing auto layout, creating manual buttons for testing constraints
                    /*
                    // Note: CK records not disabled so these are in addition to those in CK PublicDB
                    // 3 more questions
                    // let testQuestions = ["Another great question","And yet another one","And one more!"]
                    // 1 more question
                    let testQuestions = ["Another great question"]
                    
                    for testQuestion in testQuestions {
                        
                        let testQuestionButton = UIButton(frame: CGRect(x: 0, y: 0, width: widthButton, height: 30))
                        // questionButton.translatesAutoresizingMaskIntoConstraints = false
                        
                        testQuestionButton.setTitle("\(testQuestion)",for: UIControlState.normal)
                        testQuestionButton.titleLabel?.font =  UIFont(name: "AvenirNext-Heavy", size: 20)
                        testQuestionButton.setTitleColor(UIColor.white, for: UIControlState.normal)
                        testQuestionButton.setTitleColor(UIColor.purple, for: UIControlState.highlighted)
                        testQuestionButton.setTitleShadowColor(UIColor.purple, for: UIControlState.normal)
                        testQuestionButton.setTitleShadowColor(UIColor.white, for: UIControlState.highlighted)
                        testQuestionButton.titleLabel?.shadowOffset = CGSize(width: 0, height: 1)
                        buttons.append(testQuestionButton)
                    
                    }
                    */ 
                    // MANUAL QUESTION TESTING -- END BLOCK
                    
                    // Create "I'm Feeling Chucky" pick random question/answer button
                    
                    let questionButton = UIButton(frame: CGRect(x: 0, y: 0, width: widthButton, height: 30))
                    let imageChuckyButton = UIImage(named: "WoodchuckHead.png") as UIImage?
                    let imageChuckyButtonSelected = UIImage(named: "WoodchuckHead.png") as UIImage?
                   
                    buttons.append(questionButton)
                    
                    // currently same image for normal and highlighted, may switch up
                    questionButton.translatesAutoresizingMaskIntoConstraints = false
                    questionButton.setImage(imageChuckyButton, for: .normal)
                    questionButton.setImage(imageChuckyButtonSelected, for: .highlighted)
                    questionButton.setTitle(String("I'm feeling chucky!")?.uppercased(), for:UIControlState.normal)
                    questionButton.titleLabel?.font =  UIFont(name: "AvenirNext-Heavy", size: 16)
                    questionButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    questionButton.titleLabel?.numberOfLines = 2
                    questionButton.titleLabel?.textAlignment = NSTextAlignment.center
                    questionButton.setTitleColor(UIColor.white, for: UIControlState.normal)
                    questionButton.setTitleColor(UIColor.purple, for: UIControlState.highlighted)
                    questionButton.setTitleShadowColor(UIColor.blue, for: UIControlState.normal)
                    questionButton.setTitleShadowColor(UIColor.magenta, for: UIControlState.highlighted)
                    questionButton.titleLabel?.shadowOffset = CGSize(width: 0, height: 1)
                    
                    // these are to enable animateFeelingChucky transition effect
                    questionButton.alpha = 0
                    
                    // employ tag property to pass question ID and set target
                    // note for I'm Feeling Chucky action, tag set to 0
                    // make sure Question ID != 0 for any question
                    questionButton.tag = self.tagChuckyButton
                    questionButton.addTarget(self, action: #selector(self.downloadplayTapped), for: .touchUpInside)
                
                    
                    // create stackView of buttons
                   
                    let stackView = UIStackView(arrangedSubviews: buttons)
                    stackView.isHidden = true
                    stackView.tag = self.tagStackView
                    stackView.axis = .vertical
                    stackView.distribution = .fillEqually
                    stackView.alignment = .fill
                    stackView.spacing = 1
                    stackView.translatesAutoresizingMaskIntoConstraints = false
                    
                    self.view.addSubview(stackView)
                   
                    //autolayout the stack view - pin 10 left 10 right 50 down
                    let viewsDictionary = ["stackView":stackView]
                    let stackView_H = NSLayoutConstraint.constraints(
                        withVisualFormat: "H:|-10-[stackView]-10-|",  //horizontal constraint 10 points from left and right side
                        options: NSLayoutFormatOptions(rawValue: 0),
                        metrics: nil,
                        views: viewsDictionary)
                    
                    // need to play with this constraint - hardcoded setting ideal as will need to vary w/ number of questions but also don't want <3 question edge case to break
                    
                    let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]-0-|",                   options: NSLayoutFormatOptions(rawValue:0),metrics: nil, views: viewsDictionary)
                    self.view.addConstraints(stackView_H)
                    self.view.addConstraints(stackView_V)
                    stackView.isHidden = false
                    
                    self.stopSpinning()
                   
                    self.animateFeelingChucky()
                   
                    
                    
                } else {
                    
                    self.stopSpinning()
                    
                    
                    let ac = UIAlertController(title: "No Chuckisms!", message: "There was a problem getting Chuck's wisdom; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
        
        
        CKContainer.default().publicCloudDatabase.add(operation)
        
        
    }

    
    func notifyUser(_ title: String, message: String) -> Void
    {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true,
                     completion: nil)
    }
    
       
    
    func playerDidFinishPlaying(note: NSNotification){
        //Called when player finished playing
        
      
        // Dismiss AVPlayerViewController given video finished
        self.playerViewController.dismiss(animated: true, completion: nil)
        
        // remove observer waiting for AVPlayer to finish
        NotificationCenter.default.removeObserver(self)
        
    }

    
    func animateFeelingChucky() {
        
        
       
        // animate Chuck Spinner to I'm Feeling Chucky button (middle to bottom left)
        // and
        // animate I'm Feeling Chucky button in UIStackView
        
        // create new instance of image to animate, original spinner for some reason is buggy and flies to center
        let imgAnimatingSpinnerView = UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 48, height: 48))
        imgAnimatingSpinnerView.image = UIImage(named: "WoodchuckSpinner.png")
        self.view.addSubview(imgAnimatingSpinnerView)
        
        // Identify stack view containing all buttons
        let stackViewButtons = self.view.viewWithTag(tagStackView)
        
        // Identify I'm Feeling chucky button to fade in
        for button in (stackViewButtons?.subviews)! {
            
            // I'm feeling chuck button is one with tag == 0 (tagChuckyButton)
            if button.tag == self.tagChuckyButton {
                
                
                let destX = UIScreen.main.bounds.minX + 30
                let destY = UIScreen.main.bounds.maxY + 150
               
                
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    // animate chuck to new destination
                   imgAnimatingSpinnerView.frame = CGRect(x: destX , y: destY , width: 48, height: 48)
                   imgAnimatingSpinnerView.alpha = 0
                   // button.alpha = 1
                    
                }) {_ in
                    // this closure should be called post-animation
                    // however not using this approach now b/c of some errors
                    // that said, animation sync choppy so would like to figure this out
                    // button.alpha = 1
                   // imgAnimatingSpinnerView.removeFromSuperview()
                
                }
                
                // given above closure not working well, doing separate animation sequence to make this work
                UIView.animate(withDuration: 1.0, animations: {
                    
                    // reveal I'm Feeling Chucky Button
                        button.alpha = 1
                  
                })
                
                
            }
        
        }
        
    }
    
    
    func startSpinning() {
        
        
        self.imgSpinnerView.alpha = 1
        self.imgSpinnerView.startRotating(duration: 1)
    }
    
    func stopSpinning() {
        
       
        self.imgSpinnerView.stopRotating()
        self.imgSpinnerView.alpha = 0
        self.imgSpinnerView.removeFromSuperview()
    
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Setup Reachability to check for network connection type
        let reachability = Reachability()!
        
        
        // reachability tests
        /* BEGIN TESTS
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async() {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                self.notifyUser("Why no Internets?", message: "Chuck's wisdom is restricted to WiFi")

            }
        }
 
        END TESTS */
        
        do {
            try reachability.startNotifier()
        } catch {
            self.notifyUser("Trouble checking WiFi", message: "Chuck needs to know or Chuck won't talk")
        }
    
       
        // Resize image
        let imgHeader = UIImage(named: "ChuckAskMeFull.JPG")
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        self.headerImgView.image = resizeImage(image: imgHeader!, newWidth: screenWidth)
       
        
        // Render imgSpinner view
        self.imgSpinnerView.image = UIImage(named: "WoodchuckSpinner.png")
        self.view.addSubview(imgSpinnerView)
        self.imgSpinnerView.translatesAutoresizingMaskIntoConstraints = false
        self.imgSpinnerView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        self.imgSpinnerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        self.imgSpinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.imgSpinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        self.imgSpinnerView.alpha = 0
        

        // only proceed if on WiFi connection
        if reachability.isReachableViaWiFi {
            
            // print("WiFi detected")
            
            // WiFi detected, Chuck FTW!
            reachability.stopNotifier()
            countAvailQuestions()
            loadChuckisms()
           
        } else {
            
            // No WiFi detected so No Chuck :(
            // Note: need a slight delay here to work properly
            delayWithSeconds(1) {
                
                self.stopSpinning()
                reachability.stopNotifier()
                self.notifyUser("Why no WiFi?", message: "Chuck's wisdom is restricted to WiFi")
                
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        
            if self.isBeingPresented || self.isMovingToParentViewController {
                // print("view is being presented")
                
                // Spinner during initial CK load
                    startSpinning()
               
               
            }
        
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}

/* Cheat Sheets
 
 Constraints 
 
 func setupConstraints() {
 let centerX = NSLayoutConstraint(item: self.cenBut, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
 let centerY = NSLayoutConstraint(item: self.cenBut, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
 let height = NSLayoutConstraint(item: self.cenBut, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 22)
 self.cenBut.translatesAutoresizingMaskIntoConstraints = false
 self.view.addConstraints([centerX, centerY, height])
 }
 
 // Other random settings
 self.imgSpinnerView.translatesAutoresizingMaskIntoConstraints = false
 self.imgSpinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = false
 self.imgSpinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = false
 self.imgSpinnerView.widthAnchor.constraint(equalToConstant: 48).isActive = false
 self.imgSpinnerView.heightAnchor.constraint(equalToConstant: 48).isActive = false
 self.imgSpinnerView.removeConstraints(imgSpinnerView.constraints)
 self.imgSpinnerView.frame.size.width = 48
 self.imgSpinnerView.frame.size.height = 48

 
 */
