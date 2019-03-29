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
        cell.backgroundColor = .green
        if let streamView = cards[indexPath.row]?.view {
            streamView.frame = cell.bounds
            cell.addSubview(streamView)
        }
        return cell
    }
    
}
