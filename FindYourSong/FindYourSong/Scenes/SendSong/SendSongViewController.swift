//
//  _SendSongViewController.swift
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
import AnimatableReload

protocol  SendSongDisplayLogic: class
{
    func sendSongToSearch(viewModel: SendSong.SendSong.ViewModel)
}

class SendSongViewController: UIViewController, UITextFieldDelegate, SendSongDisplayLogic
{
    var interactor:  SendSongBusinessLogic?
    var router: (NSObjectProtocol & SendSongRoutingLogic & SendSongDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor =  SendSongInteractor()
        let presenter =  SendSongPresenter()
        let router =  SendSongRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        //TODO: Fetch recent searches
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchTextField.text = ""
    }
    
    // MARK: Send song
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBAction func searchPressed(_ sender: Any) {
        if searchTextField.isEditing == false && searchTextField.text == "" {
            searchTextField.placeholder = "Type here what you want to search"
        } else {
            searchTextField.endEditing(true)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if isTextFieldEmpty(textField: textField){
            return false
        } else {
            return true
        }
        
        AnimatableReload.reload(tableView: cachedSongsTableView, animationDirection: "down")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func isTextFieldEmpty(textField: UITextField) -> Bool {
        if textField.text != "" {
            return false
        } else {
            textField.placeholder = "Type what you want to search"
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let songName = textField.text ?? ""
        let request = SendSong.SendSong.Request(songName: songName)
        interactor?.sendSong(request: request)
    }
    
    
    func sendSongToSearch(viewModel: SendSong.SendSong.ViewModel)
    {
        router?.routeToSendSong(segue: nil)
    }
}
