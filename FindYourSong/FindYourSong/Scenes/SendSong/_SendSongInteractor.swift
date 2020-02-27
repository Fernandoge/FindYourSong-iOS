//
//  _SendSongInteractor.swift
//  FindYourSong
//
//  Created by Fernando Garcia on 27-02-20.
//  Copyright (c) 2020 Fernando Garcia. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol  SendSongBusinessLogic
{
    func doSomething(request:  SendSong.Something.Request)
}

protocol SendSongDataStore
{
    //var name: String { get set }
}

class SendSongInteractor: SendSongBusinessLogic, SendSongDataStore
{
    var presenter:  SendSongPresentationLogic?
    var worker:  SendSongWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func doSomething(request:  SendSong.Something.Request)
    {
        worker =  SendSongWorker()
        worker?.doSomeWork()
        
        let response =  SendSong.Something.Response()
        presenter?.presentSomething(response: response)
    }
}