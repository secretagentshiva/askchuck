//
//  QuestionsViewController.swift
//  AskChuck
//
//  Created by Shiva Rajaraman on 1/8/17.
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
    // Debug single question for testing end to end
    var questionID: Int64 = 1
    var indexRecordID: Int = 0
    
    
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
    
    func downloadplayTapped() {
        
        indexRecordID = questionID - 1
        print(questionID)
        self.chuckism.recordID = chuckisms[indexRecordID].recordID
        
        
        // Debug recording of recordID
        print("tapped it")
        // print(self.chuckism.recordID)
        print(self.chuckism.recordID)
        
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
                           
                            
                               // Debug
                               // print("now playing...")
                            
                            
                                // debug hardcode url
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
    
    @IBAction func playAnswer3(_ sender: Any) {
        
        questionID = 3
        downloadplayTapped()
    }
    
    @IBAction func playAnswer4(_ sender: Any) {
        
        questionID = 4
        downloadplayTapped()
        
    }
    
    @IBAction func playAnswer5(_ sender: Any) {
        
        questionID = 5
        downloadplayTapped()
    }
    
    @IBAction func playAnswer6(_ sender: Any) {
        
        questionID = 6
        downloadplayTapped()
        
    }
    
    func loadChuckisms() {
        
        // Need to update predicate to be six questionIDs (random 6)
        let questionIDArray = [1,2]
        
        
        let predicate = NSPredicate(format: "QuestionID IN %@", questionIDArray)
        let query = CKQuery(recordType: "Chuckisms", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        // remove Response here?
        operation.desiredKeys = ["Question", "Response", "QuestionID", "Thumb"]
        operation.resultsLimit = 10
        
        var newChuckisms = [Chuckism]()
        
        operation.recordFetchedBlock = { record in
            // let chuckism = Chuckism()
            self.chuckism.recordID = record.recordID
            self.chuckism.question = record["Question"] as! String
            self.chuckism.questionID = record["QuestionID"] as! Int64!
            
            
            newChuckisms.append(self.chuckism)
            
            // debug
            print(self.chuckism.recordID)
            
        }
        
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    
                    self.chuckisms = newChuckisms
                    
                    // Debug print final results object array
                    //    print(chuckisms)
                    
                } else {
                    
                    let ac = UIAlertController(title: "No Chuckisms!", message: "There was a problem getting Chuck's wisdom; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
        
        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
      // Do any additional setup after loading the view.
        
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
