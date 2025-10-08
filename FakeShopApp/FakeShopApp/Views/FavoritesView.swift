//
//  FavoritesView.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

import UIKit

class FavoritesView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let viewModel: FavoritesViewModel
    var products: [Product] = []
    
    init(viewModel: FavoritesViewModel) {
           self.viewModel = viewModel
           super.init(nibName: nil, bundle: nil)
       }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    lazy var productsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 30, bottom: 16, right: 30)
        layout.itemSize = CGSize(width: 150, height: 200)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProductCellView.self, forCellWithReuseIdentifier: "ProductCell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favsBindingData()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getFavoritos()
    }
    
    func configureView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Favorites"
        view.backgroundColor = UIColor(
            red: 242/255.0,
            green: 235/255.0,
            blue: 228/255.0,
            alpha: 1.0
        )

        view.addSubview(productsCollectionView)
        
        NSLayoutConstraint.activate([
            productsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            productsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK:  - CollectionviewDataSource & CollectionViewDelegate
    let dummyProducts = ["Computer", "Mobile", "Laptop"]

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCellView
        let favsProduct = products[indexPath.row]
        cell.configureData(title: favsProduct.title, imageURL: favsProduct.image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.item]
        let detail = DetailProductView(product: product)
        if let cell = collectionView.cellForItem(at: indexPath) as? ProductCellView {
            detail.prefetchImage = cell.productImageView.image
        }
        navigationController?.pushViewController(detail, animated: true)
    }
}
