//
//  ItemCollectionViewCell.swift
//  DmmItemSearchAction
//
//  Created by cano on 2020/01/18.
//  Copyright © 2020 cano. All rights reserved.
//

import UIKit
import AlamofireImage
import RxSwift
import RxCocoa

class ItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var item: ItemEntity!
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(_ data: ItemDomainModel) {
        self.item = data.item
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.text = data.item.title
        
        if let smallImageURL = self.item.imageURL?.large {
            let url = URL(string: smallImageURL)!
            self.imageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "no_image"), imageTransition: .crossDissolve(1))
        }
    }
    
    func clear() {
        self.imageView.image = nil
        self.titleLabel.text = ""
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.layer.masksToBounds = false
        self.imageView.layer.cornerRadius = self.imageView.frame.width/2
        self.imageView.clipsToBounds = true
    }
}
