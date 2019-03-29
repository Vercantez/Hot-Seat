//
//  ChatViewDataSource.swift
//  HotSeat
//
//  Created by Miguel Salinas on 3/28/19.
//  Copyright © 2019 Miguel Salinas. All rights reserved.
//

import UIKit

class ChatViewDataSource: NSObject, UICollectionViewDataSource {
    var messages: [String] = []
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        if cell.subviews.count < 2 {
            let cardImg = UIImage(named: "chat\((messages.count - 1) % 8)")
            let imgView = UIImageView(image: cardImg)
            imgView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.addSubview(imgView)
        }
        return cell
    }
    
}
