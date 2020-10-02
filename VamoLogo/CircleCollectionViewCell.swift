//
//  CircleCollectionViewCell.swift
//  VamoLogo
//
//  Created by Leonardo Mello on 01/10/20.
//  Copyright © 2020 Leonardo Mello. All rights reserved.
//

import Foundation
import UIKit

class CircleCollectionViewCell: UICollectionViewCell {
    
    
    static let identifier = "CircleCollectionViewCell"
    
    
    //IMAGEM DA SUGESTÃO
    private let myImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = .blue
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(myImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        myImageView.frame = contentView.bounds
    }
    
    public func configure(with name: String){
        myImageView.image = UIImage(named: name)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        myImageView.image = nil
    }
    
    
}
