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

class ItunesManager: ItunesManagerProtocol {
    
    let itunesURL = "https://itunes.apple.com/search?mediaType=music"
    
    var delegate: ItunesManagerDelegate?

    func fetchSongs(songName: String) {
        let urlString = "\(itunesURL)&term=\(songName)"
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters:  .urlQueryAllowed)!
        let url = URL(string: encodedUrlString)!
    }
}
