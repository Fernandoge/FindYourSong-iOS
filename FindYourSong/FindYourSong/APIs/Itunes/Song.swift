//
//  Sonng.swift
//  FindYourSong
//
//  Created by Fernando Garcia on 28-02-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import Foundation

struct Song: Codable {
    var name: String
    var artistName: String
    var albumArtworkUrl100: String
    var previewUrl: String
    var albumId: Int
}
