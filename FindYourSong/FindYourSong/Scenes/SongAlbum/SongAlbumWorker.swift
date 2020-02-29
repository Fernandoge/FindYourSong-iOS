//
//  SongAlbumWorker.swift
//  FindYourSong
//
//  Created by Fernando Garcia on 28-02-20.
//  Copyright (c) 2020 Fernando Garcia. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SongAlbumWorkerDelegate {
    func songAlbumWorker(songAlbumWorker: SongAlbumWorker, didFetchAlbum album: Album)
}

class SongAlbumWorker
{
    var delegate: SongAlbumWorkerDelegate?
    
    func fetch(albumId: Int)
    {
    }
}
