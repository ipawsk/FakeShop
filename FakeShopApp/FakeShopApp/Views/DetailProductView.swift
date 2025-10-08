//
//  DetailProductView.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

import UIKit

class DetailProductView: UIViewController {
    
    var product: Product
    let repo: ProductRepository
    var prefetchImage: UIImage?
        
    let contentView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 18)
        label.numberOfLines = 2
        label.textColor = .darkText
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 14)
        label.numberOfLines = 0
        label.textColor = .darkText
        label.backgroundColor = .clear
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 25)
        label.numberOfLines = 2
        label.textColor = .systemRed
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var favButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Agregar a favoritos", for: .normal)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 10
        button.semanticContentAttribute = .forceLeftToRight
        button.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        configureView()
        configData()
    }
    
    init (product: Product, repo: ProductRepository = FakeStoreProductRepository()) {
        self.product = product
        self.prefetchImage = nil
        self.repo = repo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        view.backgroundColor = UIColor(
            red: 242/255.0,
            green: 235/255.0,
            blue: 228/255.0,
            alpha: 1.0
        )
        navigationItem.largeTitleDisplayMode = .never
        view.addSubview(contentView)
        contentView.addSubview(productImageView)
        
        view.addSubview(productNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(priceLabel)
        view.addSubview(favButton)
        
        NSLayoutConstraint.activate([
            
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            contentView.heightAnchor.constraint(equalToConstant: 300),
            
            productImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 12),
            productImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            productImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            productNameLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 30),
            productNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            productNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            priceLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 16),
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            favButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            favButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            favButton.widthAnchor.constraint(equalToConstant: 200),
            favButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configData() {
        productNameLabel.text = product.title
        descriptionLabel.text = product.description
        priceLabel.text = "$\(product.price)"
        
        if let img = prefetchImage {
            productImageView.image = img
        } else if let url = URL(string: product.image) {
            ImageDownloader.setImage(into: productImageView, from: url)
        }
        
        updateFavoriteButton(isFavorite: product.isFavorite ?? false)
    }
    
    @objc private func toggleFavorite() {
        favButton.isEnabled = false
        Task {
            do {
                let newValue = try await repo.toggleFavorite(id: product.id) // Core Data
                await MainActor.run {
                    product.isFavorite = newValue
                    updateFavoriteButton(isFavorite: newValue)
                    favButton.isEnabled = true
                }
            }
        }
    }
    
    private func updateFavoriteButton(isFavorite: Bool) {
        let title = isFavorite ? "Agregado a favoritos" : "Agregar a favoritos"
        let img   = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
        favButton.setTitle(title, for: .normal)
        favButton.setImage(img, for: .normal)
        favButton.backgroundColor = isFavorite ? .gray : .systemRed
    }
}
