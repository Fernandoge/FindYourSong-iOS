//
//  ItunesManager.swift
//  FindYourSong
//
//  Created by Fernando Garcia on 28-02-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import Foundation
import UIKit

protocol ItunesManagerProtocol {
    func fetchSongs(songName: String)
    var delegate: ItunesManagerDelegate? { get set }
}

protocol ItunesManagerDelegate {
    func itunesManager(itunesManager: ItunesManagerProtocol, didFetchSongs songs: [Song])
    func itunesManager(itunesManager: ItunesManagerProtocol, didFetchAlbum album: Album)
}

class ItunesManager: NSObject, ItunesManagerProtocol, URLSessionDataDelegate, URLSessionTaskDelegate {
    var fetchingSongs: Bool = false
    var fetchingAlbum: Bool = false
    
    let itunesURL = "https://itunes.apple.com/"
    var delegate: ItunesManagerDelegate?
    
    init(fetchingSongs: Bool) {
        self.fetchingSongs = fetchingSongs
    }
    
    init(fetchingAlbum: Bool) {
        self.fetchingAlbum = fetchingAlbum
    }
    
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
        let urlString = "\(itunesURL)search?media=music&limit=100&term=\(songName)"
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters:  .urlQueryAllowed)!
        let url = URL(string: encodedUrlString)!
        
        dataTask = session.dataTask(with: url)
        dataTask.resume()
    }
    
    func fetchAlbum(albumId: Int) {
        let urlString = "\(itunesURL)lookup?entity=song&id=\(albumId)"
        let url = URL(string: urlString)!
        dataTask = session.dataTask(with: url)
        dataTask.resume()
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
            if fetchingSongs {
                delegate?.itunesManager(itunesManager: self, didFetchSongs: [])
            } else if fetchingAlbum {
                delegate?.itunesManager(itunesManager: self, didFetchAlbum: Album(name: "", artistName: "", albumArtworkUrl100: "", songs: []))
            }
        } else {
            let key = String(task.taskIdentifier)
            if let result = results[key] as Data? {
                if fetchingSongs {
                    if let songs = self.parseJSONToSong(songsData: result) {
                        delegate?.itunesManager(itunesManager: self, didFetchSongs: songs)
                    }
                } else if fetchingAlbum {
                    if let album = self.parseJSONToAlbum(albumData: result) {
                        delegate?.itunesManager(itunesManager: self, didFetchAlbum: album)
                    }
                }
                
            } else {
                if fetchingSongs {
                    delegate?.itunesManager(itunesManager: self, didFetchSongs: [])
                } else if fetchingAlbum {
                    delegate?.itunesManager(itunesManager: self, didFetchAlbum: Album(name: "", artistName: "", albumArtworkUrl100: "", songs: []))
                }
            }
        }
    }
    
    func parseJSONToSong(songsData: Data) -> [Song]? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(ItunesData.self, from: songsData)
            let songs = loopDataForSongs(data: decodedData)
            
            return songs
            
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func parseJSONToAlbum(albumData: Data) -> Album? {
        let decoder = JSONDecoder()
        
        do {
            var decodedData = try decoder.decode(ItunesData.self, from: albumData)
            
            //JSON first element contains album data
            let name = decodedData.results[0].collectionCensoredName
            let artistName = decodedData.results[0].artistName
            let albumArtworkUrl100 = decodedData.results[0].artworkUrl100
            
            //Removing first element so now results are only songs
            decodedData.results.remove(at: 0)
            
            let songs = loopDataForSongs(data: decodedData)

            let album = Album(name: name, artistName: artistName, albumArtworkUrl100: albumArtworkUrl100, songs: songs)
            
            return album
            
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func loopDataForSongs(data: ItunesData) -> [Song] {
        var songs = [Song]()
        
        for result in data.results {
            var name = ""
            var previewUrl = ""
            if let safeName = result.trackCensoredName {
                name = safeName
            }
            if let safePreviewUrl = result.previewUrl {
                previewUrl = safePreviewUrl
            }
            let artistName = result.artistName
            let albumArtworkUrl100 = result.artworkUrl100
            
            let albumId = result.collectionId
            
            let songModel = Song(name: name, artistName: artistName, albumArtworkUrl100: albumArtworkUrl100, previewUrl: previewUrl, albumId: albumId)
            
            songs.append(songModel)
            
        }
        
        return songs
        
    }


}

extension ItunesManagerDelegate {
    func itunesManager(itunesManager: ItunesManagerProtocol, didFetchSongs songs: [Song]) {
        //Just to make the method optional
    }
    func itunesManager(itunesManager: ItunesManagerProtocol, didFetchAlbum album: Album) {
        //Just to make the method optional
    }
}

extension UIImageView {
    func downloadFromURL(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
