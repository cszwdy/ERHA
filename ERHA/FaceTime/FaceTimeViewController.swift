//
//  FaceTimeViewController.swift
//  ERHA
//
//  Created by Emiaostein on 05/02/2018.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

import UIKit

struct User {
    let uid: String
    let nickName: String
    let avatarUrl: URL
}

struct Song {
    let url: URL
    let name: String
    let lyricUrl: URL
    let duration: Float
}

struct Lyric {
    let url: URL
    let lines: [String]
}

class FaceTimeViewController: UIViewController {
    
    private var stateStore: StateStore<FaceTimeViewController.Event, FaceTimeViewController.State, FaceTimeViewController.Command>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stateStore = StateStore<Event, State, Command>.init(reduce: reduce)
        let state = State()
        stateStore.addObserver(initialState: state, command: nil, stateDidChanged: stateDidChanged(old:new:command:))
//        stateStore.dispatch(.searchReady)
    }
    
    // absolute value
    struct State: StateType {
        
        // Users
        var localUser: User?
        var remoteUser: User?
        
        // Song
        var willPlaySong: Song?
        
        struct SearchViewState: Equatable {
            static func ==(lhs: FaceTimeViewController.State.SearchViewState, rhs: FaceTimeViewController.State.SearchViewState) -> Bool {
                return lhs.hidden != rhs.hidden && lhs.hiddenWait != rhs.hiddenWait && lhs.hiddenAvatar != rhs.hiddenAvatar && lhs.title != rhs.title
            }
            
            let hidden: Bool
            let hiddenWait: Bool
            let hiddenAvatar: Bool
            let title: String
        }
        var searchViewState = SearchViewState(hidden: false, hiddenWait: false, hiddenAvatar: true, title: "Searching...")
        
        
        struct SongsViewState {
            let hidden: Bool
        }
        var songsViewState = SongsViewState(hidden: true)
        
        
        struct DownloadViewState {
            let hidden: Bool
            let progress: CGFloat
            let title: String
        }
        var downloadViewState = DownloadViewState(hidden: true, progress: 0.0, title: "")
        

        struct LyricViewState {
            let hidden: Bool
        }
        var lyricViewState = LyricViewState(hidden: true)
        
        
        struct PlayViewState {
            let hidden: Bool
            let progress: CGFloat
            let title0: String
            let title1: String
        }
        var playViewState = PlayViewState(hidden: true, progress: 0.0, title0: "", title1: "")
    }
    
    
    // Busniess
    enum Event: EventType {
        
        // Search
//        case searchReady
//        case searchMatched(User)
//        case searchDisappear
//
//        // Songs
//        case songsReady
//        case songsSelected(Song)
//        case songsNeedAgree(Song)
//
//        // Download
//        case downloadStart(Song)
//        case downloadedProgressTo(Float)
//        case downloadFinished(Song, Lyric)
//
//        // Play
//        case songPlay(Song)
//        case songProgressTo(Float)
//        case lyricReload(Lyric)
        
        case sync
        case async
    }
    
    enum Command: OperationType {
//        case searchRequest
//        case songsRequest
//        case songsSelectedTo(Song)
//        case download(Song)
//        case songPlay(Song)
        
        case sync
        case async
    }
    
    // (action, state) -> (state, command)
    func reduce(action: Event, old: State) -> (State, Command?) {
        var state = old
        var operation: Command?
        
        switch action {
//        case .searchReady:
//            state.searchViewState = State.SearchViewState(hidden: false, hiddenWait: false, hiddenAvatar: true, title: "Searching...")
//            state.songsViewState = State.SongsViewState(hidden: true)
//            state.downloadViewState = State.DownloadViewState(hidden: true, progress: 0.0, title: "")
//            state.lyricViewState = State.LyricViewState(hidden: true)
//            state.playViewState = State.PlayViewState(hidden: true, progress: 0.0, title0: "", title1: "")
//
//            operation = .searchRequest
//
//        case .searchUpdated(let user):
//            if old.remoteUser?.uid != user.uid {
//                state.remoteUser = user
//                state.searchViewState = State.SearchViewState(hidden: false, hiddenWait: true, hiddenAvatar: false, title: "\(user.nickName)")
//                state.songsViewState = State.SongsViewState(hidden: true)
//                state.downloadViewState = State.DownloadViewState(hidden: true, progress: 0.0, title: "")
//                state.lyricViewState = State.LyricViewState(hidden: true)
//                state.playViewState = State.PlayViewState(hidden: true, progress: 0.0, title0: "", title1: "")
//            }
//
//        case .searchConnected:
//            state.searchViewState = State.SearchViewState(hidden: true, hiddenWait: true, hiddenAvatar: false, title: old.searchViewState.title)
//            state.songsViewState = State.SongsViewState(hidden: false )
//            state.downloadViewState = State.DownloadViewState(hidden: true, progress: 0.0, title: "")
//            state.lyricViewState = State.LyricViewState(hidden: true)
//            state.playViewState = State.PlayViewState(hidden: true, progress: 0.0, title0: "", title1: "")
            
        case .sync:
            operation = .sync
            
        case .async:
            operation = .async
            
        }
        
        return (state, operation)
    }
    
    
    // Diff old state and new state to change UI and call method.
    func stateDidChanged(old: State?, new: State, command: Command?) {
        if old!.searchViewState != new.searchViewState {
            
        }
    }
}


// MARK: - Operations
extension FaceTimeViewController {
    
    func operationSync() {
        print("Hello World!")
    }
    
    func operationAsync() {
        
        
        
    }
}
