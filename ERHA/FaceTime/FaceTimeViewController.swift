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
    
    private var stateStore: StateStore<FaceTimeViewController.Event, FaceTimeViewController.State, FaceTimeViewController.Operation>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stateStore = StateStore<Event, State, Operation>.init(reduce: reduce)
        let state = State()
        stateStore.addObserver(initialState: state, command: nil, stateDidChanged: stateDidChanged(old:new:command:))
        stateStore.dispatch(.searchStart)
    }
    
    // absolute value
    struct State: StateType {
        // Users
        var localUser: User?
        var remoteUser: User?
        
        // Song
        var willPlaySong: Song?
        
        // SearchView
        var hiddenSearchView = false
        var hiddenSearchWaittingView = false
        var hiddenSearchRemoteUserAvatarView = true
        var textOfSearchTitle = "Searching..."
        
        // SongsView
        var hiddenSongsView = true
//        var dataSourceOfSongs = TableDataSourceWrapper.self
        
        // DownloadView
        var hiddenDownloadView = true
        var progressOfDownload: Float = 0.0
        var textOfDownloadTitle = ""
        
        // PlayView
        var hiddenPlayView = true
        var progressOfPlay: Float = 0.0
        var textOfPastTimeLabel = ""
        var textOfRemainTimeLabel = ""
//        var dataSourceOfLyric = TableDataSourceWrapper.self
    }
    
    
    // Busniess
    enum Event: EventType {
        
        // Search
        case searchStart  // reset UI, search command
        case searchMatched(User)
        case searchConnected // command, songsAppear
        
        // Songs
        case songsStart // command, request song
//        case songsReload(TableDataSource<String>)
        case songsSelectedTo(Song)
        case songsDidAgreeTo(Song) // command, download song
        
        // Download
        case downloadStart(Song)
        case downloadedProgressTo(Float)
        case downloadFinished(Song, Lyric)
        
        // Play
        case songPlay(Song)
        case songProgressTo(Float)
        case lyricReload(Lyric)
    }
    
    enum Operation: OperationType {
        case searchRequest
        case songsRequest
        case songsSelectedTo(Song)
        case download(Song)
        case songPlay(Song)
    }
    
    // (action, state) -> (state, command)
    func reduce(action: Event, old: State) -> (State, Operation?) {
        var state = old
        var operation: Operation?
        
        switch action {
        case .searchStart:
            // SearchView
            state.hiddenSearchView = false
            state.hiddenSearchWaittingView = false
            state.hiddenSearchRemoteUserAvatarView = true
            state.textOfSearchTitle = "Searching..."
            // SongsView
            state.hiddenSongsView = true
            // DownloadView
            state.hiddenDownloadView = true
            // PlayView
            state.hiddenPlayView = true
            operation = .searchRequest
            
        case .searchMatched(let user):
            if old.remoteUser?.uid != user.uid {
                state.remoteUser = user
                state.hiddenSearchView = false
                state.hiddenSearchWaittingView = true
                state.hiddenSearchRemoteUserAvatarView = false
                state.textOfSearchTitle = "\(user.nickName)"
                // SongsView
                state.hiddenSongsView = true
                // DownloadView
                state.hiddenDownloadView = true
                // PlayView
                state.hiddenPlayView = true
            }
            
        case .searchConnected:
            state.hiddenSearchView = true
            // SongsView
            state.hiddenSongsView = true
            // DownloadView
            state.hiddenDownloadView = true
            // PlayView
            state.hiddenPlayView = true
            
        default:
            ()
        }
        
        return (state, operation)
    }
    
    
    // Diff old state and new state to change UI and call method.
    func stateDidChanged(old: State?, new: State, command: Operation?) {
        
    }
}


// MARK: - Command
