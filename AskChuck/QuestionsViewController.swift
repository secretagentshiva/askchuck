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
    var questionID: Int64 = 1
    
    // Outlets
    // Future version has these dynamically rendered but for testing with limited content hardcoded for now
    @IBOutlet weak var buttonQuestion1: UIButton!
    @IBOutlet weak var buttonQuestion2: UIButton!
    @IBOutlet weak var headerImgView: UIImageView!
    @IBOutlet weak var imgSpinner: UIImageView!
    
    
    func downloadplayTapped() {
        
        
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
                                    
                                            print("linking error")
                                            print(error)
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
    
    
    // Future version dynamically creates these Question Play buttons based on CK lookup
    // Hardcoded for testing currently
    
    @IBAction func playAnswer1(_ sender: Any) {
        
        questionID = 1
        downloadplayTapped()
    }
    
    
    @IBAction func playAnswer2(_ sender: Any) {
        
        questionID = 2
        downloadplayTapped()
    }
    
    // Save for "I'm feeling Chucky" RANDOM selection
    // var countAssets: UInt32 = 10 // will need to populate with lookup of available assets
    // let selectionSurprise = arc4random_uniform(countAssets+1)
      
    func loadChuckisms() {
        
        let questionIDArray = [1,2] // only 2 Q&A's in cloud right now so hardcoding for testing purposes
        
        
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
                    
                    // Now that CK records loaded let's unhide the buttons 
                    // Later we will dynamically produce these buttons based on CK records
                    self.buttonQuestion1.isHidden = false
                    self.buttonQuestion2.isHidden = false
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
        
        // debug
        // print(imgSize)
        // print(imgRect)
        // print(scale)
        
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
            // Perform an action that will only be done once
            startSpinning()
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}
