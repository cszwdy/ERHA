//
//  FaceTimeViewController.swift
//  ERHA
//
//  Created by Emiaostein on 05/02/2018.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

import UIKit
import Moya

struct User: Codable {
    let uid: String
    let nickName: String
    let avatarUrl: URL
}

struct Song {
    let remoteUrl: URL
    let remoteLrcUrl: URL
    let title: String
    let duration: Float
}

struct Lyric {
    struct Lrcline {
        enum LrclineTyle {
            case lrc
            case tl
        }
        let offset: TimeInterval
        let duration: TimeInterval
        let content: String
        let type: LrclineTyle
    }
    
    let duration: TimeInterval
    let lines: [Lrcline]
}



class FaceTimeModel {
    let token: String
    let rid: String
    let client = MoyaProvider<Server.Request.Funny>(stubClosure: MoyaProvider.immediatelyStub)
    
    init(token: String, rid: String) {
        self.token = token
        self.rid = rid
    }
    
    enum Result<T> {
        case success(T)
        case failture
    }
    
    func paramerters(append: [String: String] = [:]) -> [String: String] {
        return ["token": token, "rid": rid].merging(append, uniquingKeysWith: { (old, new) -> String in
            return old
        })
    }
    
    
    func search(completed:@escaping (Result<Server.SearchResult.Data.Databody>)->()) {
        client.request(.search(token: token)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let decoder = JSONDecoder()
                    let response = try response.filterSuccessfulStatusCodes()
                    let user = try response.map(Server.SearchResult.Data.Databody.self, atKeyPath: "data.databody", using: decoder, failsOnEmptyData: true)
                    completed(.success(user))
                } catch {
                    completed(.failture)
                }
                
            case .failure:
                completed(.failture)
            }
        }
    }
    
    func disconnect(manual: Bool, completed:@escaping (Result<()>)->()) {
        client.request(.disconnect(token: token, rid: rid, manual: manual)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    completed(.success(()))
                } catch {
                    completed(.failture)
                }
            case .failure:
                completed(.failture)
            }
        }
    }
    
    func newSongs(completed:@escaping (Result<[Server.NewSongsResult.Data.Databody]>)->()) {
        client.request(.newSongs(token: token, rid: rid)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let jsonDecoder = JSONDecoder()
                    let any = try response.map([Server.NewSongsResult.Data.Databody].self, atKeyPath: "data.databody", using: jsonDecoder, failsOnEmptyData: true)
//                    print(json)
                    completed(.success(any))
                } catch let error {
                    print(error)
                    completed(.failture)
                }
            case .failure:
                completed(.failture)
            }
        }
    }
    
//    func notifyNeedAgreeSelectedSong(songId: String, completed:(Result<()>)->()) {
//        client.request(.notifyNeedAgreeSelectedSong(token: token, rid: rid, songId: songId)) { (result) in
//            <#code#>
//        }
//    }
//    
//    func notifyDidAgreeSelectedSong(agree: Bool, completed:(Result<()>)->()) {
//        if agree {
//            client.request(.notifyDidAgreeSelectedSong(token: token, rid: rid), completion: { (result) in
//                <#code#>
//            })
//        } else {
//            client.request(.notifyDidDisagreeSelectedSong(token: token, rid: rid), completion: { (result) in
//                <#code#>
//            })
//        }
//    }
//    
//    func notifyNeedPlay(completed:(Result<()>)->()) {
//        client.request(.notifyNeedPlay(token: token, rid: rid)) { (result) in
//            <#code#>
//        }
//    }
//    
//    func notifyNeedAgreeNewSongs(completed:(Result<()>)->()) {
//        client.request(.notifyNeedAgreeNewSongs(token: token, rid: rid)) { (result) in
//            <#code#>
//        }
//    }
//    
//    func notifyDidAgreeNewSongs(agree: Bool, completed:(Result<()>)->()) {
//        if agree {
//            client.request(.notifyDidAgreeNewSongs(token: token, rid: rid)) { (result) in
//                <#code#>
//            }
//        } else {
//            client.request(.notifyDidDisagreeNewSongs(token: token, rid: rid), completion: { (result) in
//                <#code#>
//            })
//        }
//    }
//    
//    func notifyDirectlyNewSongs(completed:(Result<()>)->()) {
//        client.request(.notifyDirectlyNewSongs(token: token, rid: rid)) { (reuslt) in
//            <#code#>
//        }
//    }
//    
//    func notifyFailToDownloadSong(completed:(Result<()>)->()) {
//        client.request(.notifyFailToDownloadSong(token: token, rid: rid)) { (result) in
//            <#code#>
//        }
//    }
    
}


class FaceTimeViewController: UIViewController {
    
    private var token: String!
    private var rid: String!
    private let client = MoyaProvider<Server.Request.Funny>()
    private var stateStore: StateStore<FaceTimeViewController.Event, FaceTimeViewController.State, FaceTimeViewController.Command>!
    
    class func viewController(token: String, rid: String) -> UIViewController {
        let vc = UIStoryboard(name: "FaceTime", bundle: nil).instantiateInitialViewController() as! FaceTimeViewController
        vc.token = token
        vc.rid = rid
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stateStore = StateStore<Event, State, Command>.init(reduce: reduce)
        let state = State()
        stateStore.addObserver(initialState: state, command: nil, stateDidChanged: stateDidChanged(old:new:command:))
//        stateStore.dispatch(.searchReady)
    }
    
    
// MARK: - States
    struct State: StateType {
        
        // Users
        var localUser: User?
        var remoteUser: User?
        var selectedSong: Song?
        
        struct SearchViewState: Equatable {
            static func ==(lhs: FaceTimeViewController.State.SearchViewState, rhs: FaceTimeViewController.State.SearchViewState) -> Bool {
                return lhs.hidden == rhs.hidden && lhs.hiddenWait == rhs.hiddenWait && lhs.hiddenAvatar == rhs.hiddenAvatar && lhs.title == rhs.title
            }
            
            let hidden: Bool
            let hiddenWait: Bool
            let hiddenAvatar: Bool
            let title: String
        }
        var searchViewState = SearchViewState(hidden: false, hiddenWait: false, hiddenAvatar: true, title: "Searching...")
        
        
        struct SongsViewState: Equatable {
            static func ==(lhs: FaceTimeViewController.State.SongsViewState, rhs: FaceTimeViewController.State.SongsViewState) -> Bool {
                return lhs.hidden == rhs.hidden
            }
            
            let hidden: Bool
        }
        var songsDataSource: SongsDataSource = SongsDataSource(songs: [], owner: nil)
        var songsViewState = SongsViewState(hidden: true)
        
        
        struct InfoViewState: Equatable {
            static func ==(lhs: FaceTimeViewController.State.InfoViewState, rhs: FaceTimeViewController.State.InfoViewState) -> Bool {
                return lhs.title == rhs.title && lhs.subtitle == rhs.title && lhs.imgUrl == rhs.imgUrl
            }
            
            let title: String
            let subtitle: String
            let imgUrl: URL?
        }
        var infoViewState: InfoViewState = InfoViewState(title: "", subtitle: "", imgUrl: nil)
        
        
        struct DownloadViewState: Equatable {
            static func ==(lhs: FaceTimeViewController.State.DownloadViewState, rhs: FaceTimeViewController.State.DownloadViewState) -> Bool {
                return lhs.hidden == rhs.hidden && lhs.progress == rhs.progress && lhs.title == rhs.title
            }
            
            let hidden: Bool
            let progress: Float
            let title: String
        }
        var downloadViewState = DownloadViewState(hidden: true, progress: 0.0, title: "")
        

        struct LyricViewState: Equatable {
            static func ==(lhs: FaceTimeViewController.State.LyricViewState, rhs: FaceTimeViewController.State.LyricViewState) -> Bool {
                return lhs.hidden == rhs.hidden
            }
            
            let hidden: Bool
        }
        var lyricViewState = LyricViewState(hidden: true)
        
        
        struct PlayViewState: Equatable {
            static func ==(lhs: FaceTimeViewController.State.PlayViewState, rhs: FaceTimeViewController.State.PlayViewState) -> Bool {
                return lhs.hidden == rhs.hidden && lhs.progress == rhs.progress && lhs.title0 == rhs.title0 && lhs.title1 == rhs.title1
            }
            
            let hidden: Bool
            let progress: CGFloat
            let title0: String
            let title1: String
        }
        var playViewState = PlayViewState(hidden: true, progress: 0.0, title0: "", title1: "")
    }
    
// MARK: - Events
    /*
        The logic event, optional contain UI state change.
     */
    enum Event: EventType {
        
        case search
        case connect(User)
        case connected
        case songsHidden(Bool)
        case songsGet
        case songsReload([Song])
        case songsSelectAt(Int)
        case songsNeedAgree
        case songDownload
        case songDownloadingTo(CGFloat)
        case songDownloaded
        case songPlay
        case songCancel
        case songFinished
    }
    
    
    
    enum Command: OperationType {
        
        case search(token: String)
        case songsGet(token: String, rid: String, completed: ([Song])->())
        case songsReloadData([Song])
        case songsSelect(Song)
        case songDownload(Song,(Song)->())
        case songPlay(Song)
    }
    
    // (action, state) -> (state, command)
    func reduce(action: Event, old: State) -> (State, Command?) {
        var state = old
        var command: Command?
        
//        switch action {
//
//        case .search:
//            <#code#>
//        case .connect(_):
//            <#code#>
//        case .connected:
//            <#code#>
//        case .songsHidden(_):
//            <#code#>
//        case .songsGet:
//            <#code#>
//        case .songsSelect(_):
//            <#code#>
//        case .songsNeedAgree:
//            <#code#>
//        case .songDownload:
//            <#code#>
//        case .songDownloading(_):
//            <#code#>
//        case .songDownloaded:
//            <#code#>
//        case .songPlay:
//            <#code#>
//        case .songCancel:
//            <#code#>
//        case .songFinished:
//            <#code#>
//        }
        
        return (state, command)
    }
    
    
    func stateDidChanged(old: State?, new: State, command: Command?) {
        
        let videos = childViewControllers.first{$0 is VideosViewController} as! VideosViewController
        
        if old == nil || old!.searchViewState != new.searchViewState {
            let search = childViewControllers.first{$0 is SearchViewController} as! SearchViewController
            search.update(state: new.searchViewState)
        }
        
        if old == nil || old!.songsViewState != new.songsViewState {
            let songs  = childViewControllers.first{$0 is SongsViewController } as! SongsViewController
            songs.hidden(new.songsViewState.hidden)
        }
        
        if old == nil || old!.songsDataSource.identifier != new.songsDataSource.identifier {
            let songs  = childViewControllers.first{$0 is SongsViewController } as! SongsViewController
            songs.songsView.dataSource = new.songsDataSource
            songs.songsView.reloadData()
        }
        
        if old == nil || old!.downloadViewState != new.downloadViewState {
            let dwload = childViewControllers.first{$0 is DownloadProgressViewController} as! DownloadProgressViewController
            dwload.update(state: new.downloadViewState)
        }
        
        if old == nil || old!.infoViewState != new.infoViewState {
            let info   = childViewControllers.first{$0 is UserInfoViewController} as! UserInfoViewController
            info.update(state: new.infoViewState)
        }
        
        if old == nil || old!.lyricViewState != new.lyricViewState {
            let lyric  = childViewControllers.first{$0 is LyricViewController} as! LyricViewController
            lyric.update(state: new.lyricViewState)
        }
        
        
        
        guard let command = command else {
            return
        }
        
//        switch command {
//        case .songsGet(_):
//            <#code#>
//        case .songsReload(_):
//            <#code#>
//        case .songsSelect(_):
//            <#code#>
//        case .songDownload(_, _):
//            <#code#>
//        case .songPlay(_):
//            <#code#>
//        }
        
    }
}


// MARK: - Commands
extension FaceTimeViewController {
    
    func search(token: String, rid: String) {
        let group = DispatchGroup()
        //TODO: songs request
        client.request(.search(token: token)) { (response) in
        }
        
        //TODO: Add notification
        
        //TODO: Remove notificaton
        
        let waitSearch = group.wait(timeout: .now()+10)
        
        if waitSearch == .timedOut {
            stateStore.dispatch(.search)
            return
        }
        
        let remoteUser = User(uid: "", nickName: "remoteUser", avatarUrl: URL(string: "")!)
        stateStore.dispatch(.connect(remoteUser))
        
        let group1 = DispatchGroup()
        //TODO: Notification of remote user first frame
        group1.enter()
        group1.leave()
        
        let waitConnect = group1.wait(timeout: .now()+5)
        
        if waitConnect == .timedOut {
            stateStore.dispatch(.search)
            return
        }
        
        stateStore.dispatch(.connected)
        stateStore.dispatch(.songsHidden(false))
        stateStore.dispatch(.songsGet)
    }
    
    
    func songsGet(token: String, rid: String) {
        
        var songs: [Song] = []
        let group = DispatchGroup()
        group.enter()
        //TODO: songs request.
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            //TODO: get songs.
            songs = []
            group.leave()
        }
        
        let result = group.wait(timeout: .now()+3)
        
        switch result {
        case .success:
            stateStore.dispatch(.songsReload(songs))
        case .timedOut:
            ()
        }
    }
    
    func songsSelect(token: String, rid: String, song: Song) {
        
        let group = DispatchGroup()
        //TODO: Song select request
        
        //TODO: Add notification recieve agree or not message.
        
        let result = group.wait(timeout: .now() + 10)
        
        //TODO: remove notification.
        
        let agree = true
        
        switch agree {
        case true:
            stateStore.dispatch(.songDownload)
        default:
            ()
        }
    }
    
    func download(token: String, rid: String, song: Song) {
        
        let group = DispatchGroup()
        
        //TODO: Lyric from Cache or download  and cache
        group.enter()
        group.leave()
        
        //TODO: Song from Cache or download and cache
        group.enter()
        group.leave()
        
        let waitDownloadResult = group.wait(timeout: .now()+60)
        
        switch waitDownloadResult {
        case .success:
            //TODO: Play request
            
            //TODO: Add notification for play
            
            let waitPlayResult = group.wait(timeout: .now() + 60)
            
            // TODO: Remove notification
            
            switch waitPlayResult {
            case .success:
                stateStore.dispatch(.songPlay)
                
            case .timedOut:
                // TODO: disconnect and search
                stateStore.dispatch(.search)
                ()
            }
            
        case .timedOut:
            ()
        }
    }
}


class SongsDataSource: NSObject, UITableViewDataSource {
    
    private(set) var identifier = 0
    var songs: [Song]
    weak var tableView: UITableView?
    
    init(songs: [Song], owner: UITableView?) {
        self.songs = songs
        self.tableView = owner
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        
        return cell
    }
    
}





// MARK: - ViewControllers
class VideosViewController: UIViewController {
    @IBOutlet weak var videoView0: UIView! // bottom
    @IBOutlet weak var videoView1: UIView! // top
}

class SongsViewController: UIViewController {
    @IBOutlet weak var songsView: UITableView!
    func hidden(_ result: Bool, animated: Bool = true) {
        
    }
}

class SearchViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var waitView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func update(state: FaceTimeViewController.State.SearchViewState) {
        avatarView.isHidden = state.hiddenAvatar
        waitView.isHidden = state.hiddenWait
        titleLabel.text = state.title
        //TODO: Search view hidden and show animation.
        view.isHidden = state.hidden
    }
}

class UserInfoViewController: UIViewController {
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func update(state: FaceTimeViewController.State.InfoViewState) {
        //TODO: UserInfo avatar image view set image by state.imgUrl
        titleLabel.text = state.title
        subtitleLabel.text = state.subtitle
    }
}

class DownloadProgressViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    func update(state: FaceTimeViewController.State.DownloadViewState) {
        progressView.setProgress(state.progress, animated: true)
        titleLabel.text = state.title
        view.isHidden = state.hidden
    }
}

class LyricViewController: UIViewController {
    @IBOutlet weak var lyricContainerView: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    func update(state: FaceTimeViewController.State.LyricViewState) {
        view.isHidden = state.hidden
    }
}











