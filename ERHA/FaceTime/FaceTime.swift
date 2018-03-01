//
//  FaceTime.swift
//  ERHA
//
//  Created by Emiaostein on 05/02/2018.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

import Foundation
import UIKit

class FaceTime {
    
    class func viewController(token: String, rid: String) -> UIViewController {
        return FaceTimeViewController.viewController(token: token, rid: rid)
    }
    
}
