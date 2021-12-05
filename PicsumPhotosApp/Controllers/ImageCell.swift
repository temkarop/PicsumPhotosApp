//
//  ImageCell.swift
//  PicsumPhotosApp
//
//  Created by Артем Ропавка on 16.11.2021.
//

import UIKit
import Nuke

class ImageCell: UICollectionViewCell {
    
    static let cellId = "ImageCell"
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    var photo: UnsplashPhoto! {
        didSet {
            let photoUrl = photo.urls["regular"]
            guard let imageUrl = photoUrl, let url = URL(string: imageUrl) else { return }
            Nuke.loadImage(with: url, into: imageView)
        }
    }
}
