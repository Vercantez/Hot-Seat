//
//  CardsDataSource.swift
//  HotSeat
//
//  Created by Miguel Salinas on 3/28/19.
//  Copyright © 2019 Miguel Salinas. All rights reserved.
//

import UIKit
import OpenTok

class CardsDataSource: NSObject, UICollectionViewDataSource {
    var cards: [OTSubscriber?] = []
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .gray
        if let streamView = cards[indexPath.row]?.view {
            streamView.frame = cell.bounds
            let overlayimg = UIImage(named: "Streamoverlay-Rahim")
            let overlayview = UIImageView(image: overlayimg)
            overlayview.frame = cell.bounds
            streamView.addSubview(overlayview)
            cell.addSubview(streamView)
        } else {
            // dummy card
            let index = indexPath.item % 4
            let dummyCardImageName = "profile0" + String(index)
            let dummyCard = UIImage(named: dummyCardImageName)
            let dummyCardView = UIImageView(image: dummyCard)
            dummyCardView.frame = cell.bounds
            cell.addSubview(dummyCardView)
        }
        return cell
    }
    
}
