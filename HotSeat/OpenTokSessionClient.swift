//
//  OpenTokAPIService.swift
//  HotSeat
//
//  Created by Dhruv Sangvikar on 3/28/19.
//  Copyright © 2019 Miguel Salinas. All rights reserved.
//

import Foundation
import OpenTok

class OpenTokSessionClient {
    var kApiKey = "46295492"
    
    var session: OTSession
    var publisher: OTPublisher
    var subscribers: [OTSubscriber] = []
    var delegate: UIViewController
    
    init(sessionId: String, delegate: UIViewController) {
        self.delegate = delegate
        session = OTSession(apiKey: kApiKey, sessionId: sessionId, delegate: delegate as! OTSessionDelegate)!
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        publisher = OTPublisher(delegate: delegate as! OTPublisherKitDelegate, settings: settings)!
    }
    
    func doConnect(withToken token: String) {
        var error: OTError?
        defer {
            processError(error)
        }
        session.connect(withToken: token, error: &error)
    }
    
    func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }

        session.publish(publisher, error: &error)
    }
    
    func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        guard let subscriber = OTSubscriber(stream: stream, delegate: delegate as? OTSubscriberKitDelegate)
            else {
                print("Error while subscribing")
                return
        }
        session.subscribe(subscriber, error: &error)
        subscribers.append(subscriber)
    }
    
    func cleanupSubscriber(_ stream: OTStream) {
        subscribers = subscribers.filter { $0.stream?.streamId != stream.streamId }
    }
    
    private func processError(_ error: OTError?) {
        if let err = error {
            showAlert(errorStr: err.localizedDescription)
        }
    }
    
    private func showAlert(errorStr err: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: "Error", message: err, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.delegate.present(controller, animated: true, completion: nil)
        }
    }
}
