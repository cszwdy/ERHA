//
//  Server.swift
//  ERHA
//
//  Created by Emiaostein on 27/02/2018.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

import Foundation
import Moya

class Server {
    
    
    
}

extension Server {
    
    
}

extension Server {
    
    struct Request {
        enum Funny {
            case search(token: String)
            case disconnect(token: String, rid: String, manual: Bool)
            case newSongs(token: String, rid: String)
            case notifyNeedAgreeSelectedSong(token: String, rid: String, songId: String)
            case notifyDidAgreeSelectedSong(token: String, rid: String), notifyDidDisagreeSelectedSong(token: String, rid: String)
            case notifyNeedPlay(token: String, rid: String) // downloaded songs
            case notifyNeedAgreeNewSongs(token: String, rid: String)
            case notifyDidAgreeNewSongs(token: String, rid: String), notifyDidDisagreeNewSongs(token: String, rid: String)
            case notifyDirectlyNewSongs(token: String, rid: String)
            case notifyFailToDownloadSong(token: String, rid: String)
        }
    }
}




// MARK: - Funny API

extension Server.Request.Funny: TargetType {
    var baseURL: URL {
        return Config.host.current
    }
    
    var path: String {
        switch self {
        case .search:
            return "/funny/funnyConnect"
        case .disconnect:
            return "/funny/funnyDisconnect"
        case .newSongs:
            return "/funny/funnyMusicList"
        case .notifyNeedAgreeSelectedSong:
            return "/funny/chooseMusic"
        case .notifyDidAgreeSelectedSong, .notifyDidDisagreeSelectedSong:
            return "/funny/agreestChoosenMusic"
        case .notifyNeedPlay:
            return "/funny/downloadedMusic"
        case .notifyNeedAgreeNewSongs:
            return "/funny/changeFunnyMusicList"
        case .notifyDidAgreeNewSongs, .notifyDidDisagreeNewSongs:
            return "/funny/answerChangeMusicList"
        case .notifyDirectlyNewSongs:
            return "/funny/changeMusicList"
        case .notifyFailToDownloadSong:
            return "/funny/downloadMusicError"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        var data = Data()
        switch self {
        case .newSongs:
            let path = Bundle.main.path(forResource: "newSongsData", ofType: "")!
            do {
                data = try Data(contentsOf: URL(fileURLWithPath: path))
            } catch let error {
                print(error)
            }
            
        case .search:
            let path = Bundle.main.path(forResource: "searchSampleData", ofType: "")!
            do {
                data = try Data(contentsOf: URL(fileURLWithPath: path))
            } catch let error {
                print(error)
            }
        default:
            ()
        }
        return data
    }
    
    var task: Task {
        
        let tokenKey = "token"
        let ridKey = "rid"
        let songIdKey = "singId"
        let stateKey = "state"
        let statusKey = "status"
        
        let encoding = URLEncoding.queryString
        
        switch self {
        case .search(let token):
            return .requestParameters(parameters: [tokenKey: token], encoding: encoding)
        case .disconnect(let token, let rid, let manual):
            return .requestParameters(parameters: [tokenKey: token, ridKey: rid, statusKey: manual ? "0" : "1"], encoding: encoding)
        case .newSongs(let token, let rid):
            return .requestParameters(parameters: [tokenKey: token, ridKey: rid], encoding: encoding)
        case .notifyNeedAgreeSelectedSong(let token, let rid, let songId):
            return .requestParameters(parameters: [tokenKey: token, ridKey: rid, songIdKey: songId], encoding: encoding)
        case .notifyDidAgreeSelectedSong(let token, let rid): // state = 0, agree
            return .requestParameters(parameters: [tokenKey: token, ridKey: rid, stateKey: "0"], encoding: encoding)
        case .notifyDidDisagreeSelectedSong(let token, let rid): // state = 1, disagree
            return .requestParameters(parameters: [tokenKey: token, ridKey: rid, stateKey: "1"], encoding: encoding)
        case .notifyNeedPlay(let token, let rid):
            return .requestParameters(parameters: [tokenKey: token, ridKey: rid], encoding: encoding)
        case .notifyNeedAgreeNewSongs(let token, let rid):
            return .requestParameters(parameters: [tokenKey: token, ridKey: rid], encoding: encoding)
        case .notifyDidAgreeNewSongs(let token, let rid): // status = 0, agree
            return .requestParameters(parameters: [tokenKey: token, ridKey: rid, statusKey: "0"], encoding: encoding)
        case .notifyDidDisagreeNewSongs(let token, let rid): // status = 1, disagree
            return .requestParameters(parameters: [tokenKey: token, ridKey: rid, stateKey: "1"], encoding: encoding)
        case .notifyDirectlyNewSongs(let token, let rid):
            return .requestParameters(parameters: [tokenKey: token, ridKey: rid], encoding: encoding)
        case .notifyFailToDownloadSong(let token, let rid):
            return .requestParameters(parameters: [tokenKey: token, ridKey: rid], encoding: encoding)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}









// MARK: - Server Model

extension Server {
    
    public struct SearchResult: Codable {
        public let code: Int
        public struct Data: Codable {
            public struct Databody: Codable {
                public let rid: String
                public let pushUrl: String
                public let userId: String
                public let nickname: String
                public let avatarUrl: String
                public let province: String
                public let city: String
                public let sex: String
            }
            public let databody: Databody
        }
        public let data: Data
        public let message: String
    }
    
    
    struct NewSongsResult: Codable {
        let code: Int
        struct Data: Codable {
            struct Databody: Codable {
                let singName: String
                let rowNo: Int
                let singTime: String
                let author: String
                let timeSlice: String
                let accompanyUrl: String
                let singCount: Int
                let duration: String
                let singId: String
                let singUrl: URL
                let imageUrl: URL
                let singType: String
                let name: String
                let bcurl: String
                let lyricurl: URL
            }
            let databody: [Databody]
        }
        let data: Data
        let message: String
    }
    
    public struct SelectedSongResult: Codable {
        public let code: Int
        public struct Data: Codable {
            public struct Databody: Codable {
                public let singId: String
                public let singName: String
                public let singUrl: String
                public let lyricurl: String
                public let timeSlice: String
                public let singTime: String
            }
            public let databody: Databody
        }
        public let data: Data
        public let message: String
    }
    
    
    public struct AgreeSelectedSongResult: Codable {
        public let code: Int
        public struct Data: Codable {
            public struct Databody: Codable {
                public let state: Int
            }
            public let databody: Databody
        }
        public let data: Data
        public let message: String
    }
}
