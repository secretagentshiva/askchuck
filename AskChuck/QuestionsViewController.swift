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
    let playerViewController = AVPlayerViewController()
    
    
    // Debug single question for testing end to end
    // var questionID: Int64 = 1
    
    // Outlets
    // Future version has these dynamically rendered but for testing with limited content hardcoded for now
    @IBOutlet weak var buttonQuestion1: UIButton!
    @IBOutlet weak var buttonQuestion2: UIButton!
    @IBOutlet weak var headerImgView: UIImageView!
    @IBOutlet weak var imgSpinner: UIImageView!
    
    
    func downloadplayTapped(sender:UIButton) {
        
        let questionID = sender.tag
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
    
    
    
    
    // Save for "I'm feeling Chucky" RANDOM selection
    // var countAssets: UInt32 = 10 // will need to populate with lookup of available assets
    // let selectionSurprise = arc4random_uniform(countAssets+1)
      
    func loadChuckisms() {
        
        let questionIDArray = [1,2,3] // only 3 Q&A's in cloud right now so hardcoding for testing purposes
        
        
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
                        questionButton.setTitle("\(chuckQuestion.question!)",for: UIControlState.normal)
                        questionButton.titleLabel?.font =  UIFont(name: "AvenirNext-Heavy", size: 20)
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
                    
                    
                    // create stackView of buttons
                   
                    let stackView = UIStackView(arrangedSubviews: buttons)
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
                    
                } else {
                    
                    let ac = UIAlertController(title: "No Chuckisms!", message: "There was a problem getting Chuck's wisdom; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
        
        
        CKContainer.default().publicCloudDatabase.add(operation)
        
    
        
        // Need code here to dynamically populate the Question Buttons
        // Will need to create non-action versions of buttons for reference
        // Will need to possibly just create and assign them entirely in code?
        
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

    
    
    func startSpinning() {
        self.imgSpinner.isHidden = false
        self.imgSpinner.startRotating(duration: 1)
    }
    
    func stopSpinning() {
        
        self.imgSpinner.stopRotating()
        self.imgSpinner.isHidden = true
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Resize image
        let imgHeader = UIImage(named: "ChuckAskMeFull.JPG")
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        self.headerImgView.image = resizeImage(image: imgHeader!, newWidth: screenWidth)
       
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
