//
//  RotateImage.swift
//  AskChuck
//
//  Created by Litter Box Labs on 2/11/17.
//
//

import Foundation
import UIKit

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
