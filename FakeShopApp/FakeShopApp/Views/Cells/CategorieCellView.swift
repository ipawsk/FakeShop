//
//  CategorieCellView.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

import UIKit

class CategorieCellView: UICollectionViewCell {
    
    private let catNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Poppins-SemiBold", size: 16)
        label.textColor = .darkText
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? .systemBrown : .clear
            contentView.layer.borderColor = (isSelected ? UIColor.systemBrown : UIColor.lightGray).cgColor
            catNameLabel.textColor = isSelected ? .white : .label }
    }
    
    private func setupUI() {
        contentView.addSubview(catNameLabel)
        
        NSLayoutConstraint.activate([
            catNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            catNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            catNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            catNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.clipsToBounds = true
    }
    
    func configureData(with categorieName: String) {
        catNameLabel.text = categorieName.capitalized
    }
}
