//
//  OcrTextView.swift
//  VamoLogo
//
//  Created by Leonardo Mello on 11/08/20.
//  Copyright © 2020 Leonardo Mello. All rights reserved.
//

import UIKit

class OcrTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: .zero, textContainer: textContainer)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.borderColor = UIColor.systemTeal.cgColor
        font = .systemFont(ofSize: 16.0)
    }
}

