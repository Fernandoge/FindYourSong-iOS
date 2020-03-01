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
    var player: AVPlayer!

    let diskConfig = DiskConfig(name: "DiskCache")
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

    lazy var storage: Cache.Storage? = {
        return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
    }()
    
    func play(with url: URL) {
        storage?.async.entry(forKey: url.absoluteString, completion: { result in
            let playerItem: CachingPlayerItem
            switch result {
            case .error:
                //Track is not cached
                playerItem = CachingPlayerItem(url: url)
            case .value(let entry):
                //Track is cached
                playerItem = CachingPlayerItem(data: entry.object, mimeType: "audio/mpeg", fileExtension: "mp3")
            }
            playerItem.delegate = self
            self.player = AVPlayer(playerItem: playerItem)
            self.player.automaticallyWaitsToMinimizeStalling = false
            self.player.play()
        })
    }

}

extension AudioPlayer: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        storage?.async.setObject(data, forKey: playerItem.url.absoluteString, completion: { _ in })
    }
}

