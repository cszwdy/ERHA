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

    @IBAction func action_success(_ sender: Any) {
        methodSuccess?.cancel()
        let item = DispatchWorkItem { print("success!") }
        methodSuccess = item
        let timeoutItem = DispatchWorkItem { print("timetout") }

        run(concurrent: {[weak self] (group) in
            guard let sf = self else {return}
            group.enter()
            sf.queue1.asyncAfter(deadline: .now()+1, execute: {
                group.leave()
            })

            print("start")

            group.enter()
            sf.queue1.asyncAfter(deadline: .now()+2, execute: {
                group.leave()
            })
        }, timeout: .now() + 3, success: item, timeoutItem: timeoutItem)
        
    }
    
    @IBAction func action_done(_ sender: Any) {
        guard let  success = methodSuccess, success.isCancelled == false else {
            methodSuccess = nil
            return
        }
        success.perform()
        success.cancel()
    }
    
    @IBAction func action_timeout(_ sender: Any) {
        
        methodSuccess?.cancel()
        
        let item = DispatchWorkItem {
            print("success!")
        }
        
        methodSuccess = item
        
        let timeoutItem = DispatchWorkItem {
            print("timetout")
        }
        
        run(concurrent: {[weak self] (group) in
            guard let sf = self else {return}
            group.enter()
            sf.queue1.asyncAfter(deadline: .now()+1, execute: { group.leave() })
            print("start")
            group.enter()
            sf.queue1.asyncAfter(deadline: .now()+2, execute: { group.leave() })
            },
            timeout: .now() + 1.5,
            success: item,
            timeoutItem: timeoutItem)
    }
    
    
    func run(concurrent:@escaping (DispatchGroup)->(), timeout: DispatchTime, success: DispatchWorkItem, timeoutItem: DispatchWorkItem? = nil) {
        queue0.async {
            let group = DispatchGroup()
            concurrent(group)
            let result = group.wait(timeout: timeout)
            switch result {
            case .success:
                if success.isCancelled == false {
                    group.notify(queue: DispatchQueue.main, work: success)
                }
            case .timedOut:
                success.cancel()
                if let t = timeoutItem, t.isCancelled == false {
                    group.notify(queue: DispatchQueue.main, work: t)
                }
            }
        }
    }
}

