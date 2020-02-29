//
//  SongSearchInteractorTests.swift
//  FindYourSong
//
//  Created by Fernando Garcia on 27-02-20.
//  Copyright (c) 2020 Fernando Garcia. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import FindYourSong
import XCTest

class SongSearchInteractorTests: XCTestCase
{
    // MARK: Subject under test
    
    var sut: SongSearchInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupSongSearchInteractor()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSongSearchInteractor()
    {
        sut = SongSearchInteractor()
    }
    
    // MARK: Test doubles
    
    class SongSearchWorkerSpy: SongSearchWorker
    {
        let songs = [Song(name: "test", artistName: "test", albumArtworkUrl100: "test", previewUrl: "test", albumId: 0)]
        var fetchSongsCalled = false
        
        override func fetch(songName: String) {
            fetchSongsCalled = true
            delegate?.songSearchWorker(songSearchWorker: self, didFetchSongs: songs)
        }
    }
    
    
    class SongSearchPresentationLogicSpy: SongSearchPresentationLogic
    {
        var presentFetchedSongsCalled = false
        
        func presentFetchedSongs(response: SongSearch.FetchSongs.Response) {
            presentFetchedSongsCalled = true
        }
        
        
    }
    
    // MARK: Tests
    
    func testFetchSongsShouldAskWorkerToFetchSongsWithDelegate()
    {
        // Given
        let songSearchWorkerSpy = SongSearchWorkerSpy()
        sut.worker = songSearchWorkerSpy
        let request = SongSearch.FetchSongs.Request()
        
        // When
        sut.fetchSongs(request: request)
        
        // Then
        XCTAssertTrue(songSearchWorkerSpy.fetchSongsCalled, "fetchSongs(request:) should ask the worker to fetch the songs")
        XCTAssertNotNil(sut.worker.delegate, "fetchSongs(request:) should set itself to be delegate to be notified of fetch results")
    }
}
