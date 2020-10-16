//
//  Util.swift
//  VamoLogo
//
//  Created by Leonardo Malheiros de Mello on 16/10/20.
//  Copyright © 2020 Leonardo Mello. All rights reserved.
//

import Foundation
import UIKit

class Util {
    
    
    
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

