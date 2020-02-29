//
//  ItunesManager.swift
//  FindYourSong
//
//  Created by Fernando Garcia on 28-02-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import Foundation

protocol ItunesManagerProtocol {
    func fetchSongs(songName: String)
    var delegate: ItunesManagerDelegate? { get set }
}

protocol ItunesManagerDelegate {
    func itunesManager(itunesManager: ItunesManagerProtocol, didFetchSongs songs: [Song])
}

class ItunesManager: NSObject, ItunesManagerProtocol, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    let itunesURL = "https://itunes.apple.com/search?mediaType=music"
    
    var delegate: ItunesManagerDelegate?

    lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        if let delegate = self.delegate {
            return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        } else {
            return URLSession(configuration: config)
        }
    }()
    
    private var dataTask: URLSessionDataTask!
    var results = [String: NSMutableData]()
    
    func fetchSongs(songName: String) {
        let urlString = "\(itunesURL)&term=\(songName)"
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters:  .urlQueryAllowed)!
        let url = URL(string: encodedUrlString)!
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let key = String(dataTask.taskIdentifier)
        var result = results[key]
        if result == nil {
            result = NSMutableData(data: data)
            results[key] = result
        } else {
            result?.append(data)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let _ = error {
            delegate?.itunesManager(itunesManager: self, didFetchSongs: [])
        } else {
            let key = String(task.taskIdentifier)
            if let result = results[key] as Data? {
                if let songs = self.parseJSONToSong(songsData: result) {
                    delegate?.itunesManager(itunesManager: self, didFetchSongs: songs)
                }
            } else {
                delegate?.itunesManager(itunesManager: self, didFetchSongs: [])
            }
        }
    }
    
    func parseJSONToSong(songsData: Data) -> [Song]? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(ItunesData.self, from: songsData)
            var songs = [Song]()
            
            for result in decodedData.results {
                let name = result.trackName
                let artistName = result.artistName
                let albumArtworkUrl100 = result.artworkUrl100
                let previewUrl = result.previewUrl
                let albumId = result.collectionId
                
                let songModel = Song(name: name, artistName: artistName, albumArtworkUrl100: albumArtworkUrl100, previewUrl: previewUrl, albumId: albumId)
                
                songs.append(songModel)
            }
            
            return songs
            
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
