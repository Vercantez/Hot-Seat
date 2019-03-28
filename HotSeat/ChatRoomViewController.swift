//
//  ChatRoomViewController.swift
//  HotSeat
//
//  Created by Miguel Salinas on 3/28/19.
//  Copyright © 2019 Miguel Salinas. All rights reserved.
//

import UIKit

class ChatRoomViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var chatCollectionView: UICollectionView!
    @IBOutlet var cardsCollectionView: UICollectionView!
    @IBOutlet var chatTextField: UITextField!
    let chatDataSource = ChatViewDataSource()
    let cardsDataSource = CardsDataSource()
    
    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            self.chatDataSource.messages.insert("test", at: 0)
            self.chatCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])

        }
        
        self.cardsCollectionView.dataSource = self.cardsDataSource
        self.cardsDataSource.cards.append("test card")
        self.cardsDataSource.cards.append("test card")
        //self.cardsCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    func pageOffset(offset: CGPoint) -> CGPoint {
        let cardWidth = 332 + 12
        // let point be current point + half of card width / card width all times card width
        let currentWidth = offset.x
        let index = Int((currentWidth + CGFloat(cardWidth/2))/CGFloat(cardWidth))
        let newPoint = CGPoint(x: CGFloat(index * cardWidth), y: CGFloat.zero)
        return newPoint
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollView.setContentOffset(pageOffset(offset: scrollView.contentOffset), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(pageOffset(offset: scrollView.contentOffset), animated: true)
    }
    
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
    
    @IBAction func tap() {
        chatTextField.resignFirstResponder()
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
