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
    let questionID: Int64 = 1
    
    
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
        
        // Debug recording of recordID
        print("tapped it")
        // print(self.chuckism.recordID)
        
        
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
                                self.chuckism.response = NSURL(string: "file:///Users/shiva/Desktop/chuckisms/movie.mov") as URL!
                            
                                // print(self.chuckism.response)
                            
                                // let linkedURL = self.chuckism.response.appendingPathExtension("mov")
                                // print("Linked URL")
                                // print(linkedURL)
                            
                                // syntax???
                                // FileManager.linkItem(atPath self.chuckism.response String, toPath linkedURL: String)
                            
                                // print(self.chuckism.response)
                            
                                let player = AVPlayer(url: self.chuckism.response! as URL)
                                let playerViewController = AVPlayerViewController()
                                playerViewController.player = player
                                self.present(playerViewController, animated: true) {
                                    playerViewController.player!.play()
 
                                }
                           
                            
                                // fileTypeHint AVFileTypeQuickTimeMovie

                                
                                // older Try code 
                               //  self.chuckismPlayer = try AVAudioPlayer(contentsOf: self.chuckism.response, fileTypeHint: AVFileTypeQuickTimeMovie)
                               //     self.chuckismPlayer.play()
         
                            
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
        
        
        downloadplayTapped()
        
        // test video code
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
    
    func loadChuckisms() {
        let predicate = NSPredicate(format: "QuestionID = %ld", self.questionID)
        let query = CKQuery(recordType: "Chuckisms", predicate: predicate)
        let operation = CKQueryOperation(query: query)
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
                    
                    // note had to take self. out of this line for some reason (vs. tutorial). change if class Chuckism moved to a separate file later per hacking with swift instructions
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
    
    @IBAction func playAnswer2(_ sender: Any) {
    }
    
    @IBAction func playAnswer3(_ sender: Any) {
    }
    
    @IBAction func playAnswer4(_ sender: Any) {
    }
    
    @IBAction func playAnswer5(_ sender: Any) {
    }
    
    @IBAction func playAnswer6(_ sender: Any) {
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
