//
//  ItunesData.swift
//  FindYourSong
//
//  Created by Fernando Garcia on 28-02-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import Foundation

struct ItunesData: Decodable {
    let results: [Results]
    
}

struct Results: Decodable {
    let trackName: String
    let artistName: String
    let collectionCensoredName: String
    let artworkUrl100: String
    let previewUrl: String
}
