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

       let questionID: Int64 = 1
       let container = CKContainer.default()
       let publicDB = container.publicCloudDatabase
        

        let predicate = NSPredicate(format: "QuestionID = %ld", questionID)
       
        print(predicate)
       
        
        let query = CKQuery(recordType: "Chuckisms", predicate: predicate)
        
        
        publicDB.perform(query, inZoneWith: nil) { (results, error) -> Void in
            if error != nil {
                print(error!)
                // need some error handling here
            } else if results?.count == 0 {
           
                print("No results for this QuestionID")
                
            } else {
                
                
                print(results!)
                
            }
 

        // Do any additional setup after loading the view.
       
        }
 
 
       
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
