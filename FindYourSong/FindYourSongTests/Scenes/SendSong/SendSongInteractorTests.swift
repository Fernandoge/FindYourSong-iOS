//
//  SendSongInteractorTests.swift
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

class SendSongInteractorTests: XCTestCase
{
    // MARK: Subject under test
    
    var sut: SendSongInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupSendSongInteractor()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSendSongInteractor()
    {
        sut = SendSongInteractor()
    }
    
    // MARK: Test doubles
    
    class SendSongPresentationLogicSpy: SendSongPresentationLogic
    {
        var presentSomethingCalled = false
        
        func presentSomething(response: SendSong.Something.Response)
        {
            presentSomethingCalled = true
        }
    }
    
    // MARK: Tests
    
    func testDoSomething()
    {
        // Given
        let spy = SendSongPresentationLogicSpy()
        sut.presenter = spy
        let request = SendSong.Something.Request()
        
        // When
        sut.doSomething(request: request)
        
        // Then
        XCTAssertTrue(spy.presentSomethingCalled, "doSomething(request:) should ask the presenter to format the result")
    }
}