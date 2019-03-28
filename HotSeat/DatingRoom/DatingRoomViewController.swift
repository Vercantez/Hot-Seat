//
//  SecondViewController.swift
//  HotSeat
//
//  Created by Miguel Salinas on 3/27/19.
//  Copyright © 2019 Miguel Salinas. All rights reserved.
//

import UIKit
import OpenTok

class DatingRoomViewController: UICollectionViewController {
    
    // Ideally should be obtained from server.
    var kSessionId = "2_MX40NjI5NTQ5Mn5-MTU1MzczMDg3NjAxNH5uS0I0L0tXQWNPN0R1NjlPSy9iTUZmOUN-fg"
    var kToken = "T1==cGFydG5lcl9pZD00NjI5NTQ5MiZzaWc9MDA1OWM1NzlhM2U2NzEyNjU4YWY2YmM3MDJiM2E3MDIzNTAwZmU0NzpzZXNzaW9uX2lkPTJfTVg0ME5qSTVOVFE1TW41LU1UVTFNemN6TURnM05qQXhOSDV1UzBJMEwwdFhRV05QTjBSMU5qbFBTeTlpVFVabU9VTi1mZyZjcmVhdGVfdGltZT0xNTUzNzg5ODI0Jm5vbmNlPTAuMjA2NjQ4MjI0OTAwNjI5NCZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNTU2MzgxODIyJmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9"
    
    var openTokServiceClient: OpenTokSessionClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openTokServiceClient = OpenTokSessionClient(sessionId: kSessionId, delegate: self)
        openTokServiceClient?.doConnect(withToken: kToken)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Just to stop")
    }
    
    // MARK: - UICollectionView methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return openTokServiceClient?.subscribers.count ?? 0 + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)
        let videoView: UIView? = {
            if (indexPath.row == 0) {
                return openTokServiceClient?.publisher.view
            } else {
                let sub = openTokServiceClient!.subscribers[indexPath.row - 1]
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
        openTokServiceClient?.doPublish()
        if let pubView = openTokServiceClient?.publisher.view {
            pubView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            pubView.layer.zPosition = 1
            view.addSubview(pubView)
        }
        collectionView?.reloadData()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        openTokServiceClient?.doSubscribe(stream)
        collectionView?.reloadData()
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        openTokServiceClient?.cleanupSubscriber(stream)
        collectionView?.reloadData()
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
