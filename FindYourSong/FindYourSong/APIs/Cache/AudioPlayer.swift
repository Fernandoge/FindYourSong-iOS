//
//  StoredSong.swift
//  FindYourSong
//
//  Created by Fernando Garcia on 01-03-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import Foundation
import AVFoundation
import Cache
import AVKit


class AudioPlayer {
    var player = AVPlayer()
    var songPlaying: Song!
    
    let recentSongsLimit = 10
    
    let diskConfig = DiskConfig(name: "DiskCache")
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    
    lazy var storage: Cache.Storage? = {
        return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
    }()

    
    func play(song: Song, songStartedPlaying: @escaping () -> ()) {
        
        if let url = URL(string: song.previewUrl) {
            songPlaying = song
            storage?.async.entry(forKey: url.absoluteString, completion: { result in
                
                let playerItem: CachingPlayerItem
                switch result {
                case .error:
                    print("Playing song not cached")
                    playerItem = CachingPlayerItem(url: url)
                case .value(let entry):
                    print("Playing cached song")
                    playerItem = CachingPlayerItem(data: entry.object, mimeType: "audio/mpeg", fileExtension: "mp3")
                }
                
                playerItem.delegate = self
                self.player = AVPlayer(playerItem: playerItem)
                self.player.automaticallyWaitsToMinimizeStalling = false
                self.player.play()
                songStartedPlaying()
            })
        }
    }
}

extension AudioPlayer: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        storage?.async.setObject(data, forKey: playerItem.url.absoluteString, completion: { _ in })
        
        //TODO: use NSKeyedUnarchiver to transform Song class in data so we only use one user defaults key for the songs
        
        var songsNames: [String] = []
        var songsAlbums: [String] = []
        var songsArtists: [String] = []
        var songsPreviewUrl: [String] = []
        
        if let safeSongsNames = UserDefaults.standard.array(forKey: "SongsNames") as! [String]? {
            songsNames = safeSongsNames
        }
        
        if let safeSongsAlbums = UserDefaults.standard.array(forKey: "SongsAlbums") as! [String]? {
            songsAlbums = safeSongsAlbums
        }
        
        if let safeSongsArtists = UserDefaults.standard.array(forKey: "SongsArtists") as! [String]? {
            songsArtists = safeSongsArtists
        }
        
        if let safeSongsPreviewUrl = UserDefaults.standard.array(forKey: "SongsURLs") as! [String]? {
            songsPreviewUrl = safeSongsPreviewUrl
        }
        
        //Recent songs will be limited to 10
        let songCount = songsNames.count
        if songCount > recentSongsLimit {
            songsNames.removeFirst()
            songsAlbums.removeFirst()
            songsArtists.removeFirst()
            songsPreviewUrl.removeFirst()
        }
        
        songsNames.append(songPlaying.name)
        songsAlbums.append(songPlaying.albumArtworkUrl100)
        songsArtists.append(songPlaying.artistName)
        songsPreviewUrl.append(songPlaying.previewUrl)
        
        UserDefaults.standard.set(songsNames, forKey: "SongsNames")
        UserDefaults.standard.set(songsAlbums, forKey: "SongsAlbums")
        UserDefaults.standard.set(songsArtists, forKey: "SongsArtists")
        UserDefaults.standard.set(songsPreviewUrl, forKey: "SongsURLs")

    
    }
}

