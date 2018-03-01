//
//  Config.swift
//  ERHA
//
//  Created by Emiaostein on 27/02/2018.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

import Foundation

struct Config {
    
    static var develop: Bool {
        #if DEBUG
         return true
        #else
         return false
        #endif
    }
    
    struct host {
        static let develop = URL(string: "https://dev.api.lianchang521.com")!
        static let release = URL(string: "https://api.lianchang521.com")!
        
        static var current: URL {
            return Config.develop ? develop : release
        }
    }
}
