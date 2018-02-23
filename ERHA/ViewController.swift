//
//  ViewController.swift
//  ERHA
//
//  Created by Emiaostein on 21/02/2018.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let queue0 = DispatchQueue(label:".concurrentQueue", qos: .utility, attributes: .concurrent)
    let queue1 = DispatchQueue(label: "1")
    var methodSuccess: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func action_click(_ sender: Any) {
        method()
    }
    
    func method() {
        queue0.async {[weak self] in
            guard let sf = self else {return}
            sf.methodSuccess?.cancel()
            
            let group = DispatchGroup()
            
            group.enter()
            sf.queue1.asyncAfter(deadline: .now()+2, execute: {
                group.leave()
            })
            
            print("start")
            
            group.enter()
            sf.queue1.asyncAfter(deadline: .now()+4, execute: {
                group.leave()
            })
            let success = DispatchWorkItem {
                print("success")
            }
            sf.methodSuccess = success
            let result = group.wait(timeout: .now()+10)
            
            switch result {
            case .timedOut:
                success.cancel()
            default:
                ()
            }
            
            group.notify(queue: DispatchQueue.main, work: success)
        }
    }
}

