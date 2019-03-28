//
//  SecondViewController.swift
//  HotSeat
//
//  Created by Miguel Salinas on 3/27/19.
//  Copyright © 2019 Miguel Salinas. All rights reserved.
//

import UIKit
import OpenTok

class DatingRoomViewController: UIViewController {
    
    @IBOutlet weak var daterVideoArea: UIView!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var openTokServiceClient: OpenTokSessionClient?
    // Ideally should be obtained from server.
    var kSessionId = "2_MX40NjI5NTQ5Mn5-MTU1MzczMDg3NjAxNH5uS0I0L0tXQWNPN0R1NjlPSy9iTUZmOUN-fg"
    var kToken = "T1==cGFydG5lcl9pZD00NjI5NTQ5MiZzaWc9MDA1OWM1NzlhM2U2NzEyNjU4YWY2YmM3MDJiM2E3MDIzNTAwZmU0NzpzZXNzaW9uX2lkPTJfTVg0ME5qSTVOVFE1TW41LU1UVTFNemN6TURnM05qQXhOSDV1UzBJMEwwdFhRV05QTjBSMU5qbFBTeTlpVFVabU9VTi1mZyZjcmVhdGVfdGltZT0xNTUzNzg5ODI0Jm5vbmNlPTAuMjA2NjQ4MjI0OTAwNjI5NCZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNTU2MzgxODIyJmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9"
    // end of keys
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openTokServiceClient = OpenTokSessionClient(sessionId: kSessionId, delegate: self)
        openTokServiceClient?.doConnect(withToken: kToken)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.itemSize = CGSize(width: collectionView.bounds.size.width - 12, height: collectionView.bounds.size.height - 5)
    }
    
    func reloadCollectionView() {
        collectionView.isHidden = openTokServiceClient?.subscribers.count == 0
        collectionView.reloadData()
    }
}

extension DatingRoomViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        openTokServiceClient?.doPublish()
        if let pubView = openTokServiceClient?.publisher.view {
            pubView.frame = daterVideoArea.bounds
            daterVideoArea.addSubview(pubView)
        }
        reloadCollectionView()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
        reloadCollectionView()
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        openTokServiceClient?.doSubscribe(stream)
        let subscriber = openTokServiceClient?.findSubscriber(byStreamId: stream.streamId)
        reloadCollectionView()
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        openTokServiceClient?.cleanupSubscriber(stream)
        reloadCollectionView()
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }
}

extension DatingRoomViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

extension DatingRoomViewController: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("Subscriber connected")
        reloadCollectionView()
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
    func subscriberVideoDataReceived(_ subscriber: OTSubscriber) {
    }
}

extension DatingRoomViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = openTokServiceClient?.subscribers.count ?? 1
        return count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subscriberCell", for: indexPath) as! SubscriberCollectionCell
        cell.subscriber = openTokServiceClient!.subscribers[indexPath]
        return cell
    }
}

extension DatingRoomViewController: UICollectionViewDelegate {
}
