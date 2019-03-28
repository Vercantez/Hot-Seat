//
//  SecondViewController.swift
//  HotSeat
//
//  Created by Miguel Salinas on 3/27/19.
//  Copyright © 2019 Miguel Salinas. All rights reserved.
//

import UIKit
import OpenTok

var kApiKey = "46295492"
var kSessionId = "2_MX40NjI5NTQ5Mn5-MTU1MzczMDg3NjAxNH5uS0I0L0tXQWNPN0R1NjlPSy9iTUZmOUN-fg"
var kToken = "T1==cGFydG5lcl9pZD00NjI5NTQ5MiZzaWc9MDA1OWM1NzlhM2U2NzEyNjU4YWY2YmM3MDJiM2E3MDIzNTAwZmU0NzpzZXNzaW9uX2lkPTJfTVg0ME5qSTVOVFE1TW41LU1UVTFNemN6TURnM05qQXhOSDV1UzBJMEwwdFhRV05QTjBSMU5qbFBTeTlpVFVabU9VTi1mZyZjcmVhdGVfdGltZT0xNTUzNzg5ODI0Jm5vbmNlPTAuMjA2NjQ4MjI0OTAwNjI5NCZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNTU2MzgxODIyJmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9"

class DatingRoomViewController: UICollectionViewController {
    lazy var session: OTSession = {
        return OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)!
    }()
    
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    var subscribers: [OTSubscriber] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        doConnect()
    }
    
    fileprivate func doConnect() {
        var error: OTError?
        defer {
            processError(error)
        }
        session.connect(withToken: kToken, error: &error)
    }
    
    fileprivate func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }
        session.publish(publisher, error: &error)
        
        collectionView?.reloadData()
    }
    
    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        guard let subscriber = OTSubscriber(stream: stream, delegate: self)
            else {
                print("Error while subscribing")
                return
        }
        session.subscribe(subscriber, error: &error)
        subscribers.append(subscriber)
        collectionView?.reloadData()
    }
    
    fileprivate func cleanupSubscriber(_ stream: OTStream) {
        subscribers = subscribers.filter { $0.stream?.streamId != stream.streamId }
        collectionView?.reloadData()
    }
    
    fileprivate func processError(_ error: OTError?) {
        if let err = error {
            showAlert(errorStr: err.localizedDescription)
        }
    }
    
    fileprivate func showAlert(errorStr err: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: "Error", message: err, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - UICollectionView methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subscribers.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)
        let videoView: UIView? = {
            if (indexPath.row == 0) {
                return publisher.view
            } else {
                let sub = subscribers[indexPath.row - 1]
                return sub.view
            }
        }()
        
        if let viewToAdd = videoView {
            viewToAdd.frame = cell.bounds
            cell.addSubview(viewToAdd)
        }
        return cell
    }
}

// MARK: - OTSession delegate callbacks
extension DatingRoomViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        doPublish()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        doSubscribe(stream)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        cleanupSubscriber(stream)
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }
}

// MARK: - OTPublisher delegate callbacks
extension DatingRoomViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

// MARK: - OTSubscriber delegate callbacks
extension DatingRoomViewController: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("Subscriber connected")
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
    func subscriberVideoDataReceived(_ subscriber: OTSubscriber) {
    }
}
