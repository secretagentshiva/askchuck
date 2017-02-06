//
//  QuestionsViewController.swift
//  AskChuck
//
//  Created by Litter Box Labs on 1/8/17.
//  Copyright © 2017 Chucklet Labs. All rights reserved.
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
    let playerViewController = AVPlayerViewController()
    
    // spinner image view
    let imgSpinnerView = UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 48, height: 48))

    
    // adding identifier tag for StackView to access later w/ I'm Feeling Chucky
    let tagStackView: Int = 1000
    
    // boolean in case we need to expose all buttons again in case I'm Feeling Chucky selected
    // given that will hide some questions
    var resetQuestionsView = false
    
    
    // Debug single question for testing end to end
    // var questionID: Int64 = 1
    
    // Outlets
    // Future version has these dynamically rendered but for testing with limited content hardcoded for now
    @IBOutlet weak var buttonQuestion1: UIButton!
    @IBOutlet weak var buttonQuestion2: UIButton!
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

        if questionID == 0 {
            
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
    
        indexRecordID = questionID - 1
    
        self.chuckism.recordID = self.chuckisms[indexRecordID].recordID
        self.chuckism.questionID = self.chuckisms[indexRecordID].questionID
       
        
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
    

      
    func loadChuckisms() {
        
        // Capping questions to display but picking from PublicDB a random set of what is available
        
        var questionIDArray: [Int] = []
        
        // max questions on screen
        // currently set to be max 3 questions
        let countMaxQuestions = 3
        
        // total questions to pick from
        // should be total count of questions in PublicDB
        // hardcoded for now but will eventually be dynamic based on avail questions in Public DB
        // note: a bit brittle, because if question IDs are not continuous to totalAvailQuestion, you may generate random question IDs that aren't in the DB so # of questions you display will be less than countMaxQuestions
        
        let totalAvailQuestions = 3
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
        
        // remove Response here?
        operation.desiredKeys = ["Question", "Response", "QuestionID"]
        operation.resultsLimit = 5 // capping this during testing + removed cursor code; add later
        
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
                        // questionButton.translatesAutoresizingMaskIntoConstraints = false
                       
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
                        questionButton.setTitleShadowColor(UIColor.red, for: UIControlState.normal)
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
                    
                    // Create I'm Feeling Chucky Unicorn buton
                    
                    let questionButton = UIButton(frame: CGRect(x: 0, y: 0, width: widthButton, height: 30))
                    let imageChuckyButton = UIImage(named: "WoodchuckHead.png") as UIImage?
                    let imageChuckyButtonSelected = UIImage(named: "WoodchuckHead.png") as UIImage?
                   
                    buttons.append(questionButton)
                    
                    // currently same image for normal and highlighted, may switch up
                    questionButton.setImage(imageChuckyButton, for: .normal)
                    questionButton.setImage(imageChuckyButtonSelected, for: .highlighted)
                    questionButton.setTitle(String("I'm feeling chucky?")?.uppercased(), for:UIControlState.normal)
                    questionButton.titleLabel?.font =  UIFont(name: "AvenirNext-Heavy", size: 16)
                    questionButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    questionButton.titleLabel?.numberOfLines = 2
                    questionButton.titleLabel?.textAlignment = NSTextAlignment.center
                    questionButton.setTitleColor(UIColor.white, for: UIControlState.normal)
                    questionButton.setTitleColor(UIColor.purple, for: UIControlState.highlighted)
                    questionButton.setTitleShadowColor(UIColor.red, for: UIControlState.normal)
                    questionButton.setTitleShadowColor(UIColor.magenta, for: UIControlState.highlighted)
                    questionButton.titleLabel?.shadowOffset = CGSize(width: 0, height: 1)

                   
                    
                    // employ tag property to pass question ID and set target
                    // note for I'm Feeling Chucky action, tag set to 0
                    // make sure Question ID != 0 for any question
                    questionButton.tag = 0
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
                    
                    self.stopSpinning()
                   
                    self.animateSpinnerToBottomCenter()
                   
                    stackView.isHidden = false
                    
                } else {
                    
                    self.stopSpinning()
                    self.imgSpinnerView.isHidden = true
                    
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
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        let imgSize = CGSize(width: newWidth, height: newHeight)
        let imgRect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContext(imgSize)
        image.draw(in: imgRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    func playerDidFinishPlaying(note: NSNotification){
        //Called when player finished playing
        
      
        // Dismiss AVPlayerViewController given video finished
        self.playerViewController.dismiss(animated: true, completion: nil)
        
        // remove observer waiting for AVPlayer to finish
        NotificationCenter.default.removeObserver(self)
        
    }

    
    func animateSpinnerToBottomCenter() {
        
        
        
        // animate chuck spinner graphic to bottom of screen
       
        // Need to remove constrainst before animating
        // self.imgSpinnerView.removeConstraints(imgSpinnerView.constraints)
        
        self.imgSpinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = false
        self.imgSpinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = false
        
        self.imgSpinnerView.isHidden = false
       
        // let origY = self.imgSpinnerView.center.y
        
        // self.imgSpinnerView.center.y = self.view.bounds.midY
        // self.imgSpinnerView.center.x = self.view.bounds.midX
        // self.view.bringSubview(toFront: self.imgSpinnerView)
        
        let destY = CGFloat(1 - (view.bounds.height - self.imgSpinnerView.frame.height))
        print(destY)
        
        UIView.animate(withDuration: 1, delay: 0, animations: {
            
            self.imgSpinnerView.center.y = 0
            
            
        }, completion: nil)
        
        
        
    }
    
    
    func startSpinning() {
        
        self.imgSpinnerView.isHidden = false
        self.imgSpinnerView.startRotating(duration: 1)
    }
    
    func stopSpinning() {
        
        self.imgSpinnerView.stopRotating()
        // self.imgSpinnerView.isHidden = true
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
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

        self.imgSpinnerView.isHidden = true
        
        
        loadChuckisms()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isBeingPresented || self.isMovingToParentViewController {
       
            // Spinner during initial CK load
            startSpinning()
            
        }
        
       
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}
