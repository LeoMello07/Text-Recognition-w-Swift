//
//  OcrTextView.swift
//  VamoLogo
//
//  Created by Leonardo Mello on 11/08/20.
//  Copyright © 2020 Leonardo Mello. All rights reserved.
//

import UIKit

class OcrTextView: UITextView {
    
    let newSwiftColor = UIColor(red: 5, green: 92, blue: 8)
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: .zero, textContainer: textContainer)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.borderWidth = 2
        layer.cornerRadius = 15
        layer.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        layer.borderColor = newSwiftColor.cgColor
        font = .systemFont(ofSize: 24.0)
    }
}

