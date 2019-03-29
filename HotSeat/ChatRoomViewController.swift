//
//  ChatRoomViewController.swift
//  HotSeat
//
//  Created by Miguel Salinas on 3/28/19.
//  Copyright © 2019 Miguel Salinas. All rights reserved.
//

import UIKit
import OpenTok

class ChatRoomViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var chatCollectionView: UICollectionView!
    @IBOutlet var cardsCollectionView: UICollectionView!
    @IBOutlet var daterView: UIView!
    let chatDataSource = ChatViewDataSource()
    let cardsDataSource = CardsDataSource()
    
    var openTokServiceClient: OpenTokSessionClient?
    // Ideally should be obtained from server.
    var kSessionId = "2_MX40NjI5NTQ5Mn5-MTU1MzczMDg3NjAxNH5uS0I0L0tXQWNPN0R1NjlPSy9iTUZmOUN-fg"
    var kToken = "T1==cGFydG5lcl9pZD00NjI5NTQ5MiZzaWc9MDA1OWM1NzlhM2U2NzEyNjU4YWY2YmM3MDJiM2E3MDIzNTAwZmU0NzpzZXNzaW9uX2lkPTJfTVg0ME5qSTVOVFE1TW41LU1UVTFNemN6TURnM05qQXhOSDV1UzBJMEwwdFhRV05QTjBSMU5qbFBTeTlpVFVabU9VTi1mZyZjcmVhdGVfdGltZT0xNTUzNzg5ODI0Jm5vbmNlPTAuMjA2NjQ4MjI0OTAwNjI5NCZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNTU2MzgxODIyJmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9"
    // end of keys
    
    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        openTokServiceClient = OpenTokSessionClient(sessionId: kSessionId, delegate: self)
        openTokServiceClient?.doConnect(withToken: kToken)
        
        chatCollectionView.dataSource = self.chatDataSource
        
        navigationController?.isNavigationBarHidden = true
        
        chatCollectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        let maskLayer = CAGradientLayer()
        
        maskLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        
        maskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        maskLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        maskLayer.colors = [UIColor(white: 1.0, alpha: 1.0).cgColor, UIColor(white: 0.0, alpha: 0.0).cgColor]
        //maskLayer.locations = [0.0, 1.0]
        maskLayer.bounds = CGRect(x: 0, y: 0, width: self.chatCollectionView.frame.width, height: self.chatCollectionView.frame.height)

        self.chatCollectionView.layer.mask = maskLayer

        startChatScript(time: 0.5)
        
        self.cardsCollectionView.dataSource = self.cardsDataSource
        self.cardsDataSource.cards.append(nil)
        self.cardsDataSource.cards.append(nil)
        self.cardsDataSource.cards.append(nil)

        self.cardsDataSource.cards.append(nil)

        self.cardsDataSource.cards.append(nil)

        //self.cardsCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    func startChatScript(time: Double) {
        let timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) { (timer) in
            self.chatDataSource.messages.insert("test", at: 0)
            self.chatCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            
            let interval = Double.random(in: 1.0..<4.0)
            self.startChatScript(time: interval)

        }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func pageOffset(offset: CGPoint) -> CGPoint {
        let cardWidth = 332 + 12
        // let point be current point + half of card width / card width all times card width
        let currentWidth = offset.x
        let index = Int((currentWidth + CGFloat(cardWidth/2))/CGFloat(cardWidth))
        let newPoint = CGPoint(x: CGFloat(index * cardWidth), y: CGFloat(integerLiteral: 0))
        return newPoint
    }

//        if !decelerate {
//            scrollView.setContentOffset(pageOffset(offset: scrollView.contentOffset), animated: true)


    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet var inputBarBottomConstraint: NSLayoutConstraint!

    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.inputBarBottomConstraint?.constant = 50.0
            } else {
                self.inputBarBottomConstraint?.constant = (endFrame?.size.height ?? 84.0) - 34.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    var currentIndex = 0
    @IBAction func tap() {
        //openTokServiceClient?.sendSignal(withType: "right")
        animate("")
    }
    

    func animate(_ direction: String) {
        if direction == "right" {
        let nextCardView = self.cardsCollectionView.cellForItem(at: IndexPath(item: self.currentIndex + 1, section: 0))! as! SubscriberCollectionCell
        let cardview = self.cardsCollectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0))! as! SubscriberCollectionCell
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            cardview.frame.origin.x -= (cardview.frame.width) + 50
            cardview.transform = CGAffineTransform(rotationAngle: (-3.14159/18.0))
            
        }) { (finished) in
            self.cardsCollectionView.scrollToItem(at: IndexPath(item: self.currentIndex + 1, section: 0), at: .centeredHorizontally, animated: true)
            self.currentIndex += 1
            
            // Use UIBezierPath as an easy way to create the CGPath for the layer.
            // The path should be the entire circle.
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: nextCardView.loadingAnimation.frame.size.width / 2.0, y: nextCardView.loadingAnimation.frame.size.height / 2.0), radius: (nextCardView.loadingAnimation.frame.size.width - 10)/2, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
            
            // Setup the CAShapeLayer with the path, colors, and line width
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = UIColor.white.cgColor
            circleLayer.lineWidth = 3.0;
            
            // Don't draw the circle initially
            circleLayer.strokeEnd = 0.0
            
            // Add the circleLayer to the view's layer's sublayers
            nextCardView.loadingAnimation.layer.addSublayer(circleLayer)
            nextCardView.loadingAnimation.transform = CGAffineTransform(rotationAngle: (-3.14159/2))
            
            // We want to animate the strokeEnd property of the circleLayer
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            
            let duration = 3.0
            // Set the animation duration appropriately
            animation.duration = duration
            
            // Animate from 0 (no circle) to 1 (full circle)
            animation.fromValue = 0
            animation.toValue = 1
            
            // Do a linear animation (i.e. the speed of the animation stays the same)
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            
            // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
            // right value when the animation ends.
            circleLayer.strokeEnd = 1.0
            
            // Do the actual animation
            circleLayer.add(animation, forKey: "animateCircle")
            
            
            
            //self.cardsDataSource.cards.removeFirst()
            //self.cardsCollectionView.deleteItems(at: [IndexPath(item: 0, section: 0)])
        }
    }
        else {
            let nextCardView = self.cardsCollectionView.cellForItem(at: IndexPath(item: self.currentIndex + 1, section: 0))! as! SubscriberCollectionCell
            let cardview = self.cardsCollectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0))! as! SubscriberCollectionCell
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                cardview.frame.origin.y -= (cardview.frame.height) + 50
                //cardview.transform = CGAffineTransform(rotationAngle: (-3.14159/18.0))
                
            }) { (finished) in
                self.cardsCollectionView.scrollToItem(at: IndexPath(item: self.currentIndex + 1, section: 0), at: .centeredHorizontally, animated: true)
                self.currentIndex += 1
                
                // Use UIBezierPath as an easy way to create the CGPath for the layer.
                // The path should be the entire circle.
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: nextCardView.loadingAnimation.frame.size.width / 2.0, y: nextCardView.loadingAnimation.frame.size.height / 2.0), radius: (nextCardView.loadingAnimation.frame.size.width - 10)/2, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
                
                // Setup the CAShapeLayer with the path, colors, and line width
                let circleLayer = CAShapeLayer()
                circleLayer.path = circlePath.cgPath
                circleLayer.fillColor = UIColor.clear.cgColor
                circleLayer.strokeColor = UIColor.white.cgColor
                circleLayer.lineWidth = 3.0;
                
                // Don't draw the circle initially
                circleLayer.strokeEnd = 0.0
                
                // Add the circleLayer to the view's layer's sublayers
                nextCardView.loadingAnimation.layer.addSublayer(circleLayer)
                nextCardView.loadingAnimation.transform = CGAffineTransform(rotationAngle: (-3.14159/2))
                
                // We want to animate the strokeEnd property of the circleLayer
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                
                let duration = 3.0
                // Set the animation duration appropriately
                animation.duration = duration
                
                // Animate from 0 (no circle) to 1 (full circle)
                animation.fromValue = 0
                animation.toValue = 1
                
                // Do a linear animation (i.e. the speed of the animation stays the same)
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                
                // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
                // right value when the animation ends.
                circleLayer.strokeEnd = 1.0
                
                // Do the actual animation
                circleLayer.add(animation, forKey: "animateCircle")
                
                
                
                //self.cardsDataSource.cards.removeFirst()
                //self.cardsCollectionView.deleteItems(at: [IndexPath(item: 0, section: 0)])
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChatRoomViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        openTokServiceClient?.doPublish()
        if let pubView = openTokServiceClient?.publisher.view {
            pubView.frame = daterView.bounds
            daterView.addSubview(pubView)
        }
        //reloadCollectionView()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
        //reloadCollectionView()
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        openTokServiceClient?.doSubscribe(stream)
        let subscriber = openTokServiceClient?.findSubscriber(byStreamId: stream.streamId)
        self.cardsDataSource.cards.append(subscriber!.1)
        self.cardsCollectionView.insertItems(at: [IndexPath(item: 2, section: 0)])
        //reloadCollectionView()
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        openTokServiceClient?.cleanupSubscriber(stream)
        //reloadCollectionView()
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }
    
    func session(_ session: OTSession, receivedSignalType type: String?, from connection: OTConnection?, with string: String?) {
        guard let t = type else {
            return
        }
        animate(t)
//            openTokServiceClient?.publisher.publishVideo = false
//            openTokServiceClient?.publisher.publishAudio = false
    }
}

extension ChatRoomViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

extension ChatRoomViewController: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("Subscriber connected")
        //reloadCollectionView()
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
    func subscriberVideoDataReceived(_ subscriber: OTSubscriber) {
    }
}
