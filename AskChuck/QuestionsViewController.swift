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
    
    @IBAction func playAnswer1(_ sender: Any) {
        
        // test video code
        let videoURL = NSURL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        
       
        let player = AVPlayer(url: videoURL! as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        
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
        
       let questionID: Int64 = 1
      // maybe moot -> let container = CKContainer.default()
      // maybe moot ->  let publicDB = container.publicCloudDatabase
        
        
        var Chuckisms = [Chuckism]()
       
        func loadChuckisms() {
            let predicate = NSPredicate(format: "QuestionID = %ld", questionID)
            let query = CKQuery(recordType: "Chuckisms", predicate: predicate)
            let operation = CKQueryOperation(query: query)
            operation.desiredKeys = ["Question", "Response", "QuestionID", "Thumb"]
            operation.resultsLimit = 10
            
            var newChuckisms = [Chuckism]()
         
         operation.recordFetchedBlock = { record in
            let chuckism = Chuckism()
            chuckism.recordID = record.recordID
            chuckism.question = record["Question"] as! String
            chuckism.questionID = record["QuestionID"] as! Int64!
            
            
            newChuckisms.append(chuckism)
            
            
            
         }
        
         operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
            
                // note had to take self. out of this line for some reason (vs. tutorial). change if class Chuckism moved to a separate file later per hacking with swift instructions
                    Chuckisms = newChuckisms
                    
                // Debug print final results object array
                    print(Chuckisms)
       
         } else {
         
         let ac = UIAlertController(title: "No Chuckisms", message: "There was a problem getting Chuck's wisdom; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
                }
            }
         }
         
            CKContainer.default().publicCloudDatabase.add(operation)
            
           
            
         }
 
      
       
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
