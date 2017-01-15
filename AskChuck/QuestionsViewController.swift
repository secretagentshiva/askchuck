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
    
    // Debug single question for testing end to end
    var questionID: Int64 = 1
    
    
    @IBOutlet weak var headerImgView: UIImageView!
    
    
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
        print(imgSize)
        print(imgRect)
        print(scale)
        
        UIGraphicsBeginImageContext(imgSize)
        image.draw(in: imgRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    
    
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
                           
                            
                                // debug hardcode localfile MacOS url
                                // self.chuckism.response = NSURL(string: "file:///Users/shiva/Desktop/chuckisms/movie") as URL!
                            
                                let realURL: URL = self.chuckism.response as URL!
                                let linkedURL = self.chuckism.response.appendingPathExtension("mov")
                            
                                // Debug
                                // print("realURL")
                                // print(realURL)
                                // print("linkedURL")
                                // print(linkedURL)
                            
                            
                                let fileManager = FileManager.default
                                do {
                                        try fileManager.linkItem(at: realURL, to: linkedURL)
                                } catch {
                                    print("linking error")
                                    print(error)
                                
                                }
                            
                                // debug linkedURL correct
                                print(linkedURL)
                            

                                self.chuckism.response = linkedURL as URL!
                                let player = AVPlayer(url: self.chuckism.response! as URL)
                                let playerViewController = AVPlayerViewController()
                                playerViewController.player = player
                                self.present(playerViewController, animated: true) {
                                    playerViewController.player!.play()
 
                                }
                           
                            
                            
                                // Error handling for playback failure, need to figure out how to trigger
                                /*
                            
                               if player.error != nil {
                             
                                let ac = UIAlertController(title: "Chuck's unavailable now.", message: "There was a problem playing Chuck's video; please try again later.", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(ac, animated: true)
                             
                                }
                                */
                            
                        }
                        
         
                        
                        }
                }
            }
         }
    }
    
    
    @IBAction func playAnswer1(_ sender: Any) {
        
        questionID = 1
        downloadplayTapped()
        
        // hardcoded URL for player testing
        /*
        let videoURL = NSURL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        let player = AVPlayer(url: videoURL! as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        */
        
    }
    
    
    @IBAction func playAnswer2(_ sender: Any) {
        
        questionID = 2
        downloadplayTapped()
    }
    
    // Save for "I'm feeling chucky" RANDOM selection
    // var countAssets: UInt32 = 10 // will need to populate with lookup of available assets
    // let selectionSurprise = arc4random_uniform(countAssets+1)
      
    func loadChuckisms() {
        
        // Need to update predicate to be five questionIDs (random 5 of total if more given UI constraint)
        let questionIDArray = [1,2] // only 2 Q's in cloud right now
        
        
        let predicate = NSPredicate(format: "QuestionID IN %@", questionIDArray)
        let query = CKQuery(recordType: "Chuckisms", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        // remove Response here?
        operation.desiredKeys = ["Question", "Response", "QuestionID"]
        operation.resultsLimit = 5
        
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        
        // Resize image
        let imgHeader = UIImage(named: "ChuckAskMeFull.jpg")
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        
        self.headerImgView.image = resizeImage(image: imgHeader!, newWidth: screenWidth)
        
        // Load Chuckism responses 
        // Later will automate labels
        
        loadChuckisms()
       
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
