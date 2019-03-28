////
////  SubscriberCollectionCell.swift
////  HotSeat
////
////  Created by Dhruv Sangvikar on 3/28/19.
////  Copyright © 2019 Miguel Salinas. All rights reserved.
////
//
import UIKit
import OpenTok

class SubscriberCollectionCell: UICollectionViewCell {
    
    var subscriber: OTSubscriber?
    
    override func layoutSubviews() {
        if let sub = subscriber, let subView = sub.view {
            subView.frame = bounds
            contentView.insertSubview(subView, belowSubview: UIView())
        }
    }
}
