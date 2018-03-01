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
    let queue1 = DispatchQueue(label:".concurrentQueue1", qos: .utility, attributes: .concurrent)
    var methodSuccess: DispatchWorkItem?
    
    let model = FaceTimeModel(token: "eac17123356d9fd3b477b61ea57ac6e4da1e128bfe5ba23b6a01db11c7e3b859@6a0897ab631f8478fc3efdd4c9cd6961", rid: "1d8d02423db54dea8ceb0d858642a0e1")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.newSongs { (result) in
            switch result {
            case .success(let songs):
                ()
                print(songs)
            case .failture:
                print("failture")
            }
        }
        
        model.search { (result) in
            switch result {
            case .success(let search):
                print(search)
            case .failture:
                print("failture")
            }
        }
    }

    @IBAction func action_success(_ sender: Any) {
        
        syncData()
        
//        return
//
//            (methodSuccess?.cancel())!
//        let item = DispatchWorkItem { print("success!") }
//        methodSuccess = item
//        let timeoutItem = DispatchWorkItem { print("timetout") }
//
//        run(concurrent: {[weak self] (group) in
//            guard let sf = self else {return}
//            group.enter()
//            sf.queue1.asyncAfter(deadline: .now()+1, execute: {
//                group.leave()
//            })
//
//            print("start")
//
//            group.enter()
//            sf.queue1.asyncAfter(deadline: .now()+2, execute: {
//                group.leave()
//            })
//        }, timeout: .now() + 3, success: item, timeoutItem: timeoutItem)
        
    }
    
    @IBAction func action_notification(_ sender: Any) {
//        guard let  success = methodSuccess, success.isCancelled == false else {
//            methodSuccess = nil
//            return
//        }
//        success.perform()
//        success.cancel()
        
        
        notification()
    }
    
    @IBAction func action_timeout(_ sender: Any) {
        
        count += 1
        let uid = count
        interrupt(uid: uid)
        
//        methodSuccess?.cancel()
//
//        let item = DispatchWorkItem {
//            print("success!")
//        }
//
//        methodSuccess = item
//
//        let timeoutItem = DispatchWorkItem {
//            print("timetout")
//        }
//
//        run(concurrent: {[weak self] (group) in
//            guard let sf = self else {return}
//            group.enter()
//            sf.queue1.asyncAfter(deadline: .now()+1, execute: { group.leave() })
//            print("start")
//            group.enter()
//            sf.queue1.asyncAfter(deadline: .now()+2, execute: { group.leave() })
//            },
//            timeout: .now() + 1.5,
//            success: item,
//            timeoutItem: timeoutItem)
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
    
    struct Content {
        let name = "Eiaostein"
    }
    
    
    func syncData() {
        
        var contents: [Content] = []
        
         DispatchQueue.global(qos: .default).async {[weak self] in
            let group = DispatchGroup()
            group.enter()
            self?.queue1.asyncAfter(deadline: .now()+1) {[weak self] in
                contents += [Content()]
                //            group.leave()
            }
            let i = arc4random() % 3
            print(i)
            let result = group.wait(timeout: .now()+TimeInterval(i))
            print("end")
            switch result {
            case .success:
                print(contents)
            case .timedOut:
                print(contents)
                print("timeout")
            }
        }
        
        
        
//        queue0.async {[weak self] in
//            let group = DispatchGroup()
//            group.enter()
//            self?.queue1.asyncAfter(deadline: .now()+1) {
//                self?.contents += [Content()]
//                group.leave()
//            }
//
//            let result = group.wait(wallTimeout: .now()+2)
//
//            print("EMiaostein")
//
//            switch result {
//            case .success:
//                let item = DispatchWorkItem {
//                    print(self?.contents)
//                }
//
//                group.notify(queue: .main, work: item)
//
//            case .timedOut:
//                print("timeout")
//            }
//        }
    }

    
    let name = NSNotification.Name(rawValue: "Good")
    
    var count = 0
    
    func interrupt(uid: Int) {
        
        queue0.async {[weak self] in
            let group = DispatchGroup()
            
            print("start notification.")
            
            group.enter()
            var observer: NSObjectProtocol?
            observer = NotificationCenter.default.addObserver(forName: self!.name, object: uid, queue: .main) { (notification) in
                print(notification)
                NotificationCenter.default.removeObserver(observer as Any)
                group.leave()
            }
            
            let waitNoti = group.wait(timeout: .now()+4)
            
            if waitNoti == .timedOut {
                print("timeout")
                NotificationCenter.default.removeObserver(observer as Any)
                return
            }
            
            print("Done.")
        }
    }
    
    func notification() {
        let identifier = count
        NotificationCenter.default.post(name: name, object: identifier)
    }
    
    
    var atimer: DispatchSourceTimer!
    func timer() {
        let group = DispatchGroup()
        group.enter()
        
        queue0.sync {
            atimer = DispatchSource.makeTimerSource()
            atimer.schedule(deadline: .now(), repeating: 1.0)
            atimer.setEventHandler {
                print("Good")
            }
            queue0.asyncAfter(deadline:.now()+5) {
                group.leave()
            }
            atimer.resume()
            let result = group.wait(timeout: .now()+4)
            atimer.cancel()
            switch result {
            case .success:
                print("success")
            case .timedOut:
                print("timeout")
            }
        }
        
        
    }
}

