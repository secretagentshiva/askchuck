//
//  ArrayExtensions.swift
//  AskChuck
//
//  Created by Litter Box Labs on 2/5/17.
//  
//

import UIKit


    extension Collection where Index == Int {
        
       // Picks and returns a random element of the collection
        
        func randomElement() -> Iterator.Element? {
            return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(endIndex)))]
        }
        
    }


